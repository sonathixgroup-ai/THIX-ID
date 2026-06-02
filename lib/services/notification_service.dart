import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class NotificationService {
  final SupabaseClient _client;

  NotificationService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  static const String _table = 'notifications';

  /// Normalise les données quel que soit le nom des colonnes (flexible)
  Map<String, dynamic> _normalizeRow(Map<String, dynamic> row) {
    final data = (row['data'] is Map)
        ? (row['data'] as Map).cast<String, dynamic>()
        : (row['payload'] is Map)
            ? (row['payload'] as Map).cast<String, dynamic>()
            : <String, dynamic>{};

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

  /// Stream de notifications avec polling (stable et simple)
  Stream<List<Map<String, dynamic>>> streamForUser(String uid) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? pollTimer;
    bool isActive = true;

    Future<void> fetch() async {
      if (!isActive || controller.isClosed) return;

      try {
        final rows = await _client
            .from(_table)
            .select('*')
            .eq('user_id', uid)
            .order('created_at', ascending: false)
            .limit(50);

        final list = (rows is List)
            ? rows
                .map((e) => _normalizeRow((e as Map).cast<String, dynamic>()))
                .toList()
            : <Map<String, dynamic>>[];

        if (!controller.isClosed) controller.add(list);
      } catch (e) {
        debugPrint('NotificationService: fetch failed for uid=$uid | error=$e');
        if (!controller.isClosed) controller.add([]);
      }
    }

    controller.onListen = () {
      isActive = true;
      unawaited(fetch());
      pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => unawaited(fetch()));
    };

    controller.onCancel = () {
      isActive = false;
      pollTimer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  /// Nombre de notifications non lues
  Stream<int> streamUnreadCount(String uid) {
    return streamForUser(uid)
        .map((rows) => rows.where((r) => (r['read'] as bool?) != true).length)
        .distinct();
  }

  /// Ajouter une notification
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
        'data': data ?? <String, dynamic>{},
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('NotificationService: add failed to=$toUid type=$type | error=$e');
      // Tentative legacy (anciens noms de colonnes)
      try {
        await _client.from(_table).insert({
          'user_id': toUid,
          'title': title,
          'message': body,
          'seen': false,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (e2) {
        debugPrint('NotificationService: legacy insert also failed | error=$e2');
        rethrow;
      }
    }
  }

  /// Marquer une notification comme lue
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
      debugPrint('NotificationService: markRead failed | error=$e');
      // Tentative legacy
      try {
        await _client
            .from(_table)
            .update({'seen': true})
            .eq('id', notificationId)
            .eq('user_id', uid);
      } catch (_) {}
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllRead(String uid) async {
    try {
      await _client
          .from(_table)
          .update({'read': true})
          .eq('user_id', uid)
          .eq('read', false);
    } catch (e) {
      debugPrint('NotificationService: markAllRead failed | error=$e');
      try {
        await _client
            .from(_table)
            .update({'seen': true})
            .eq('user_id', uid)
            .eq('seen', false);
      } catch (_) {}
    }
  }

  /// Supprimer une notification
  Future<void> delete(String notificationId, String uid) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', notificationId)
          .eq('user_id', uid);
    } catch (e) {
      debugPrint('NotificationService: delete failed | error=$e');
    }
  }
}
