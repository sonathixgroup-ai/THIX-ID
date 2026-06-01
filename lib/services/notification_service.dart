import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/supabase/supabase_config.dart';
import 'dart:async';

class NotificationService {
  final SupabaseClient _client;
  NotificationService({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  static const String _table = 'notifications';

  Map<String, dynamic> _normalizeRow(Map<String, dynamic> r) {
    final data = (r['data'] is Map)
        ? (r['data'] as Map).cast<String, dynamic>()
        : (r['payload'] is Map)
            ? (r['payload'] as Map).cast<String, dynamic>()
            : const <String, dynamic>{};
    final read = (r['read'] as bool?) ?? (r['seen'] as bool?) ?? false;
    return <String, dynamic>{
      'id': r['id'],
      'user_id': r['user_id'],
      'type': (r['type'] ?? r['kind'] ?? 'generic').toString(),
      'title': (r['title'] ?? 'Notification').toString(),
      'body': (r['body'] ?? r['message'] ?? r['content'] ?? '').toString(),
      'read': read,
      'data': data,
      'created_at': r['created_at'],
    };
  }

  /// Stream de notifications par polling (sans Realtime).
  Stream<List<Map<String, dynamic>>> streamForUser(String uid) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? pollTimer;
    bool isActive = true;

    Future<void> fetch() async {
      if (!isActive) return;
      try {
        final rows = await _client.from(_table).select('*').eq('user_id', uid).order('created_at', ascending: false).limit(50);
        final list = (rows is List)
            ? rows.map((e) => _normalizeRow((e as Map).cast<String, dynamic>())).toList(growable: false)
            : const <Map<String, dynamic>>[];
        if (!controller.isClosed) controller.add(list);
      } catch (e) {
        debugPrint('NotificationService: fetch failed uid=$uid err=$e');
        if (!controller.isClosed) controller.add([]);
      }
    }

    controller.onListen = () {
      isActive = true;
      unawaited(fetch());
      pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => unawaited(fetch()));
    };

    controller.onCancel = () {
      isActive = false;
      pollTimer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  Stream<int> streamUnreadCount(String uid) {
    return streamForUser(uid)
        .map((rows) => rows.where((r) => (r['read'] as bool?) != true).length)
        .distinct();
  }

  Future<void> add({
    required String toUid,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      try {
        await _client.from(_table).insert({
          'user_id': toUid,
          'type': type,
          'title': title,
          'body': body,
          'read': false,
          'data': data ?? const <String, dynamic>{},
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
        return;
      } catch (e) {
        debugPrint('NotificationService: insert with (type,body,read,data) failed, retrying legacy columns. err=$e');
      }
      await _client.from(_table).insert({
        'user_id': toUid,
        'title': title,
        'message': body,
        'seen': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('NotificationService: add failed to=$toUid type=$type err=$e');
      rethrow;
    }
  }

  Future<void> markRead({required String uid, required String notificationId}) async {
    try {
      try {
        await _client.from(_table).update({'read': true}).eq('id', notificationId).eq('user_id', uid);
        return;
      } catch (e) {
        debugPrint('NotificationService: markRead set read=true failed, retry legacy. err=$e');
      }
      await _client.from(_table).update({'seen': true}).eq('id', notificationId).eq('user_id', uid);
    } catch (e) {
      debugPrint('NotificationService: markRead failed uid=$uid id=$notificationId err=$e');
    }
  }

  Future<void> markAllRead(String uid) async {
    try {
      try {
        await _client.from(_table).update({'read': true}).eq('user_id', uid).eq('read', false);
        return;
      } catch (e) {
        debugPrint('NotificationService: markAllRead set read=true failed, retry legacy. err=$e');
      }
      await _client.from(_table).update({'seen': true}).eq('user_id', uid).eq('seen', false);
    } catch (e) {
      debugPrint('NotificationService: markAllRead failed uid=$uid err=$e');
    }
  }
}
