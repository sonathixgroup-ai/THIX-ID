import 'dart:async'; // ✅ INDISPENSABLE pour unawaited
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/services/chat_service.dart';
import 'package:thix_id/supabase/supabase_config.dart';

// ... (Gardez votre Enum et votre Classe SectionBadgeCounts tels quels) ...

class NotificationCountersService {
  NotificationCountersService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  // ... (Gardez vos constantes et vos méthodes privées : _prefKey, _getLastSeen, _setLastSeen) ...

  // ... (Gardez vos méthodes de comptage : _countSince, _countMessagesSince, _computeCounts) ...

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
    // Utilisation d'un StreamController avec gestion propre du cycle de vie
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
