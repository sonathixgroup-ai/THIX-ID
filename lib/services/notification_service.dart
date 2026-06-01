import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class NotificationService {
  NotificationService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _table = 'thix_notifications';
  static const Duration _broadcastPollInterval = Duration(seconds: 8);
  static const Duration _userPollInterval = Duration(seconds: 3);
  static const int _maxNotifications = 50;

  // ==========================================================================
  // STREAMS AVEC POLLING (sans Realtime)
  // ==========================================================================

  Stream<List<Map<String, dynamic>>> streamForHome({String? uid}) {
    if (uid == null || uid.trim().isEmpty) {
      return streamBroadcastOnly();
    }

    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    List<Map<String, dynamic>> personal = [];
    List<Map<String, dynamic>> broadcast = [];
    StreamSubscription? personalSub;
    StreamSubscription? broadcastSub;

    void emitMerged() {
      final merged = <Map<String, dynamic>>[...personal, ...broadcast];
      merged.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '');
        final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '');
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      final seenIds = <String>{};
      final unique = <Map<String, dynamic>>[];
      for (final item in merged) {
        final id = item['id']?.toString() ?? '';
        if (id.isEmpty || seenIds.add(id)) {
          unique.add(item);
        }
      }

      if (!controller.isClosed) controller.add(unique);
    }

    controller
      ..onListen = () {
        personalSub = streamForUser(uid).listen((data) {
          personal = data;
          emitMerged();
        });
        broadcastSub = streamBroadcastOnly().listen((data) {
          broadcast = data;
          emitMerged();
        });
      }
      ..onCancel = () async {
        await personalSub?.cancel();
        await broadcastSub?.cancel();
      };

    return controller.stream.distinct((prev, next) {
      if (prev.length != next.length) return false;
      for (int i = 0; i < prev.length; i++) {
        if (prev[i]['id'] != next[i]['id']) return false;
        if (prev[i]['read'] != next[i]['read']) return false;
      }
      return true;
    });
  }

  Stream<List<Map<String, dynamic>>> streamBroadcastOnly() {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? pollTimer;
    bool isCancelled = false;

    Future<void> fetch() async {
      if (isCancelled) return;
      try {
        final response = await _client
            .from(_table)
            .select('*')
            .filter('user_id', 'is', null)
            .order('created_at', ascending: false)
            .limit(_maxNotifications);
        final notifications = response is List
            ? response
                .map((e) => _normalizeRow(e as Map<String, dynamic>))
                .toList(growable: false)
            : <Map<String, dynamic>>[];

        if (!controller.isClosed) controller.add(notifications);
      } catch (e) {
        debugPrint('NotificationService: broadcast fetch failed err=$e');
        if (!controller.isClosed) controller.add([]);
      }
    }

    controller
      ..onListen = () {
        isCancelled = false;
        unawaited(fetch());
        pollTimer?.cancel();
        pollTimer = Timer.periodic(_broadcastPollInterval, (_) => unawaited(fetch()));
      }
      ..onCancel = () {
        isCancelled = true;
        pollTimer?.cancel();
      };

    return controller.stream;
  }

  Stream<List<Map<String, dynamic>>> streamForUser(String uid) {
    final authUid = _client.auth.currentUser?.id;
    final effectiveUid = (authUid != null && authUid != uid) ? authUid : uid;

    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? pollTimer;
    bool isCancelled = false;

    Future<void> fetch() async {
      if (isCancelled) return;
      try {
        final response = await _client
            .from(_table)
            .select('*')
            .eq('user_id', effectiveUid)
            .order('created_at', ascending: false)
            .limit(_maxNotifications);

        final notifications = response is List
            ? response
                .map((e) => _normalizeRow(e as Map<String, dynamic>))
                .toList(growable: false)
            : <Map<String, dynamic>>[];

        if (!controller.isClosed) controller.add(notifications);
      } catch (e) {
        debugPrint('NotificationService: user fetch failed uid=$effectiveUid err=$e');
        if (!controller.isClosed) controller.add([]);
      }
    }

    controller
      ..onListen = () {
        isCancelled = false;
        unawaited(fetch());
        pollTimer = Timer.periodic(_userPollInterval, (_) => unawaited(fetch()));
      }
      ..onCancel = () {
        isCancelled = true;
        pollTimer?.cancel();
      };

    return controller.stream;
  }

  Stream<int> streamUnreadCount(String uid) {
    return streamForUser(uid)
        .map((notifications) => notifications.where((n) => n['read'] != true).length)
        .distinct();
  }

  // ==========================================================================
  // MÉTHODES D'ACTION
  // ==========================================================================

  Future<void> add({
    required String toUid,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.from(_table).insert({
        'user_id': toUid,
        'type': type,
        'title': title,
        'body': body,
        'read': false,
        'data': data ?? {},
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('NotificationService: add failed, trying legacy schema. err=$e');
      await _client.from(_table).insert({
        'user_id': toUid,
        'title': title,
        'message': body,
        'seen': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  Future<void> markRead({
    required String uid,
    required String notificationId,
  }) async {
    try {
      await _client
          .from(_table)
          .update({'read': true})
          .eq('id', notificationId)
          .eq('user_id', uid);
    } catch (e) {
      debugPrint('NotificationService: markRead failed, trying legacy schema. err=$e');
      await _client
          .from(_table)
          .update({'seen': true})
          .eq('id', notificationId)
          .eq('user_id', uid);
    }
  }

  Future<void> markAllRead(String uid) async {
    try {
      await _client
          .from(_table)
          .update({'read': true})
          .eq('user_id', uid)
          .eq('read', false);
    } catch (e) {
      debugPrint('NotificationService: markAllRead failed, trying legacy schema. err=$e');
      await _client
          .from(_table)
          .update({'seen': true})
          .eq('user_id', uid)
          .eq('seen', false);
    }
  }

  // ==========================================================================
  // MÉTHODES PRIVÉES
  // ==========================================================================

  Map<String, dynamic> _normalizeRow(Map<String, dynamic> row) {
    final data = row['data'] is Map<String, dynamic>
        ? row['data'] as Map<String, dynamic>
        : row['payload'] is Map<String, dynamic>
            ? row['payload'] as Map<String, dynamic>
            : {};

    final read = (row['read'] as bool?) ?? (row['seen'] as bool?) ?? false;

    return {
      'id': row['id'],
      'user_id': row['user_id'],
      'type': (row['type'] ?? row['kind'] ?? 'generic').toString(),
      'title': (row['title'] ?? 'Notification').toString(),
      'body': (row['body'] ?? row['message'] ?? row['content'] ?? '').toString(),
      'read': read,
      'data': data,
      'created_at': row['created_at'],
    };
  }
}
