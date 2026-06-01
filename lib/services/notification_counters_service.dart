import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/services/chat_service.dart';
import 'package:thix_id/supabase/supabase_config.dart';

// ============================================================================
// ENUM ThixSection
// ============================================================================
enum ThixSection {
  messages,
  info,
  events,
  formations,
  opportunities,
  jobs,
}

// ============================================================================
// CLASSE SectionBadgeCounts
// ============================================================================
class SectionBadgeCounts {
  final int messages;
  final int info;
  final int events;
  final int formations;
  final int opportunities;
  final int jobs;

  const SectionBadgeCounts({
    this.messages = 0,
    this.info = 0,
    this.events = 0,
    this.formations = 0,
    this.opportunities = 0,
    this.jobs = 0,
  });

  static const zero = SectionBadgeCounts();

  factory SectionBadgeCounts.fromMap(Map<String, dynamic> map) {
    return SectionBadgeCounts(
      messages: (map['messages'] as num?)?.toInt() ?? 0,
      info: (map['info'] as num?)?.toInt() ?? 0,
      events: (map['events'] as num?)?.toInt() ?? 0,
      formations: (map['formations'] as num?)?.toInt() ?? 0,
      opportunities: (map['opportunities'] as num?)?.toInt() ?? 0,
      jobs: (map['jobs'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SectionBadgeCounts &&
        other.messages == messages &&
        other.info == info &&
        other.events == events &&
        other.formations == formations &&
        other.opportunities == opportunities &&
        other.jobs == jobs;
  }

  @override
  int get hashCode => Object.hash(
        messages,
        info,
        events,
        formations,
        opportunities,
        jobs,
      );
}

// ============================================================================
// SERVICE NotificationCountersService
// ============================================================================
class NotificationCountersService {
  NotificationCountersService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  // Constantes
  static const _pollingInterval = Duration(seconds: 30);
  static const _infoTable = 'info_articles';
  static const _eventsTable = 'events';
  static const _opportunitiesTable = 'opportunities';
  static const _jobsTable = 'jobs';
  static const _formationsTable = 'formations';

  // Clés SharedPreferences
  String _prefKey(String uid, ThixSection section) =>
      'last_seen_${uid}_${section.name}';

  // ==========================================================================
  // MÉTHODES PRIVÉES
  // ==========================================================================

  Future<DateTime?> _getLastSeen(String uid, ThixSection section) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ms = prefs.getInt(_prefKey(uid, section));
      if (ms == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (e) {
      debugPrint('getLastSeen error: $e');
      return null;
    }
  }

  Future<void> _setLastSeen(String uid, ThixSection section) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _prefKey(uid, section),
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('setLastSeen error: $e');
    }
  }

  Future<int> _countSince({
    required String table,
    required String uid,
    required DateTime? since,
    String? dateColumn,
  }) async {
    final col = dateColumn ?? 'created_at';
    try {
      var query = _client.from(table).select('id', count: CountOption.exact);
      
      if (since != null) {
        query = query.gt(col, since.toIso8601String());
      }
      
      final response = await query;
      return response.count ?? 0;
    } catch (e) {
      debugPrint('countSince error for $table: $e');
      return 0;
    }
  }

  Future<int> _countMessagesSince(String uid, DateTime? since) async {
    try {
      var query = _client
          .from(ChatService.messagesTable)
          .select('id', count: CountOption.exact)
          .eq('to_uid', uid);
      
      if (since != null) {
        query = query.gt('created_at', since.toIso8601String());
      }
      
      final response = await query;
      return response.count ?? 0;
    } catch (e) {
      debugPrint('countMessagesSince error: $e');
      return 0;
    }
  }

  Future<SectionBadgeCounts> _computeCounts(String uid) async {
    final now = DateTime.now();
    
    final messagesSince = await _getLastSeen(uid, ThixSection.messages);
    final infoSince = await _getLastSeen(uid, ThixSection.info);
    final eventsSince = await _getLastSeen(uid, ThixSection.events);
    final formationsSince = await _getLastSeen(uid, ThixSection.formations);
    final opportunitiesSince = await _getLastSeen(uid, ThixSection.opportunities);
    final jobsSince = await _getLastSeen(uid, ThixSection.jobs);

    final results = await Future.wait([
      _countMessagesSince(uid, messagesSince),
      _countSince(table: _infoTable, uid: uid, since: infoSince),
      _countSince(table: _eventsTable, uid: uid, since: eventsSince),
      _countSince(table: _formationsTable, uid: uid, since: formationsSince),
      _countSince(table: _opportunitiesTable, uid: uid, since: opportunitiesSince),
      _countSince(table: _jobsTable, uid: uid, since: jobsSince),
    ]);

    return SectionBadgeCounts(
      messages: results[0],
      info: results[1],
      events: results[2],
      formations: results[3],
      opportunities: results[4],
      jobs: results[5],
    );
  }

  // ==========================================================================
  // MÉTHODES PUBLIQUES
  // ==========================================================================

  Future<void> markSectionSeen({
    required String uid,
    required ThixSection section,
  }) async {
    await _setLastSeen(uid, section);
  }

  Stream<SectionBadgeCounts> streamCounts(String uid) {
    final controller = StreamController<SectionBadgeCounts>.broadcast();
    RealtimeChannel? channel;
    Timer? pollTimer;
    bool isPolling = false;
    bool isCancelled = false;

    Future<void> emit() async {
      if (controller.isClosed) return;
      final counts = await _computeCounts(uid);
      if (!controller.isClosed) controller.add(counts);
    }

    void startPolling() {
      if (isPolling || isCancelled) return;
      isPolling = true;
      pollTimer?.cancel();
      pollTimer = Timer.periodic(_pollingInterval, (_) => unawaited(emit()));
    }

    void stopPolling() {
      isPolling = false;
      pollTimer?.cancel();
      pollTimer = null;
    }

    Future<void> cleanup() async {
      isCancelled = true;
      stopPolling();
      if (channel != null) {
        await _client.removeChannel(channel!);
        channel = null;
      }
    }

    Future<void> setupRealtime() async {
      if (isCancelled) return;

      try {
        channel = _client.channel('thix:badge_counts:$uid');
        final tables = [
          _infoTable,
          _eventsTable,
          _opportunitiesTable,
          _jobsTable,
          _formationsTable,
          ChatService.messagesTable,
        ];

        for (final table in tables) {
          channel!.onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            callback: (_) => unawaited(emit()),
          );
        }

        await channel!.subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.channelError) {
            startPolling();
          }
        });

        await emit();
      } catch (e) {
        startPolling();
        await emit();
      }
    }

    controller.onListen = () => unawaited(setupRealtime());
    controller.onCancel = () => unawaited(cleanup());

    return controller.stream.distinct();
  }
}
