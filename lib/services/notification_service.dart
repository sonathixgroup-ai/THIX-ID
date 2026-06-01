import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class NotificationService {
  NotificationService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _table = 'thix_notifications';
  static const Duration _pollInterval = Duration(seconds: 5);
  static const int _maxNotifications = 50;

  // ==========================================================================
  // STREAMS SIMPLES (polling uniquement, pas de Realtime)
  // ==========================================================================

  /// Stream des notifications personnelles (polling toutes les 5 secondes)
  Stream<List<Map<String, dynamic>>> streamForUser(String uid) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? pollTimer;
    bool isActive = true;

    Future<void> fetch() async {
      if (!isActive) return;
      try {
        final response = await _client
            .from(_table)
            .select('*')
            .eq('user_id', uid)
            .order('created_at', ascending: false)
            .limit(_maxNotifications);

        final notifications = response is List
            ? response
                .map((e) => _normalizeRow(e as Map<String, dynamic>))
                .toList(growable: false)
            : <Map<String, dynamic>>[];

        if (!controller.isClosed) controller.add(notifications);
      } catch (e) {
        debugPrint('NotificationService: fetch failed uid=$uid err=$e');
        if (!controller.isClosed) controller.add([]);
      }
    }

    controller.onListen = () {
      isActive = true;
      unawaited(fetch());
      pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(fetch()));
    };

    controller.onCancel = () {
      isActive = false;
      pollTimer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  /// Stream des notifications broadcast (user_id = null)
  Stream<List<Map<String, dynamic>>> streamBroadcastOnly() {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? pollTimer;
    bool isActive = true;

    Future<void> fetch() async {
      if (!isActive) return;
      try {
        final response = await _client
            .from(_table)
            .select('*')
            .is_('user_id', null)
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

    controller.onListen = () {
      isActive = true;
      unawaited(fetch());
      pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(fetch()));
    };

    controller.onCancel = () {
      isActive = false;
      pollTimer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  /// Stream des notifications personnelles + broadcast (mélangées)
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

    return controller.stream;
  }

  /// Stream du nombre de notifications non lues
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
      debugPrint('NotificationService: add failed err=$e');
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
      debugPrint('NotificationService: markRead failed err=$e');
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
      debugPrint('NotificationService: markAllRead failed err=$e');
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
