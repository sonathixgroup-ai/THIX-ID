import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/services/chat_service.dart';
import 'package:thix_id/supabase/supabase_config.dart';

// ============================================================================
// ENUMÉRATION DES SECTIONS
// ============================================================================

/// Sections de l'application pouvant afficher des badges de notification.
enum ThixSection {
  messages,
  info,
  events,
  formations,
  opportunities,
  jobs,
}

// ============================================================================
// MODÈLE DE DONNÉES
// ============================================================================

/// Compteurs de badges pour chaque section.
class SectionBadgeCounts {
  final int messages;
  final int info;
  final int events;
  final int formations;
  final int opportunities;
  final int jobs;

  const SectionBadgeCounts({
    required this.messages,
    required this.info,
    required this.events,
    required this.formations,
    required this.opportunities,
    required this.jobs,
  });

  /// Compteurs tous à zéro.
  static const zero = SectionBadgeCounts(
    messages: 0,
    info: 0,
    events: 0,
    formations: 0,
    opportunities: 0,
    jobs: 0,
  );

  /// Retourne le compteur pour une section donnée.
  int forSection(ThixSection section) {
    switch (section) {
      case ThixSection.messages:
        return messages;
      case ThixSection.info:
        return info;
      case ThixSection.events:
        return events;
      case ThixSection.formations:
        return formations;
      case ThixSection.opportunities:
        return opportunities;
      case ThixSection.jobs:
        return jobs;
    }
  }

  /// Crée une copie avec des valeurs modifiées.
  SectionBadgeCounts copyWith({
    int? messages,
    int? info,
    int? events,
    int? formations,
    int? opportunities,
    int? jobs,
  }) {
    return SectionBadgeCounts(
      messages: messages ?? this.messages,
      info: info ?? this.info,
      events: events ?? this.events,
      formations: formations ?? this.formations,
      opportunities: opportunities ?? this.opportunities,
      jobs: jobs ?? this.jobs,
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
  int get hashCode => Object.hash(messages, info, events, formations, opportunities, jobs);
}

// ============================================================================
// SERVICE PRINCIPAL
// ============================================================================

/// Service de gestion des compteurs de notifications.
///
/// Ce service permet de :
/// - Compter les nouveaux éléments depuis la dernière visite d'une section
/// - Marquer une section comme "vue"
/// - Streamer en temps réel les mises à jour des badges
class NotificationCountersService {
  NotificationCountersService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  // ==========================================================================
  // CONSTANTES
  // ==========================================================================

  static const String _prefsPrefix = 'thix_seen_section_v2';
  static const String _infoTable = 'thix_info_news';
  static const String _eventsTable = 'thix_events';
  static const String _opportunitiesTable = 'thix_opportunities';
  static const String _jobsTable = 'thix_job_offers';
  static const String _formationsTable = 'thix_trainings';
  static const Duration _pollingInterval = Duration(seconds: 3);
  static const int _maxCount = 999;

  // ==========================================================================
  // MÉTHODES PRIVÉES - STOCKAGE LOCAL
  // ==========================================================================

  String _prefKey(String uid, ThixSection section) => '$_prefsPrefix:$uid:${section.name}';

  /// Récupère la dernière date de visualisation d'une section.
  Future<DateTime> _getLastSeen(String uid, ThixSection section) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey(uid, section));
      if (raw != null) {
        final parsed = DateTime.tryParse(raw);
        if (parsed != null) return parsed;
      }
      // Première visite : ne compte que les éléments créés à partir de maintenant
      return DateTime.now().toUtc();
    } catch (e) {
      debugPrint('NotificationCountersService: getLastSeen failed err=$e');
      return DateTime.now().toUtc();
    }
  }

  /// Enregistre qu'une section a été vue.
  Future<void> _setLastSeen(String uid, ThixSection section) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey(uid, section), DateTime.now().toUtc().toIso8601String());
    } catch (e) {
      debugPrint('NotificationCountersService: setLastSeen failed uid=$uid section=${section.name} err=$e');
    }
  }

  // ==========================================================================
  // MÉTHODES PRIVÉES - COMPTAGE
  // ==========================================================================

  /// Compte les entrées d'une table créées après une date donnée.
  Future<int> _countSince({
    required String table,
    required DateTime since,
    String? filterColumn,
    Object? filterValue,
  }) async {
    try {
      var query = _client.from(table).select('id').gt('created_at', since.toIso8601String());
      if (filterColumn != null && filterValue != null) {
        query = query.eq(filterColumn, filterValue);
      }
      final res = await query.limit(_maxCount);
      return (res is List) ? res.length : 0;
    } catch (e) {
      debugPrint('NotificationCountersService: countSince failed table=$table err=$e');
      return 0;
    }
  }

  /// Compte les nouveaux messages (expéditeur différent de l'utilisateur).
  Future<int> _countMessagesSince({required String uid, required DateTime since}) async {
    try {
      // Vérifie si le schéma canonique existe
      bool useCanonical = true;
      try {
        await _client.from(ChatService.messagesTable).select('id').limit(1);
      } catch (_) {
        useCanonical = false;
      }

      if (useCanonical) {
        final res = await _client
            .from(ChatService.messagesTable)
            .select('id')
            .neq('sender_id', uid)
            .gt('created_at', since.toIso8601String())
            .limit(_maxCount);
        return (res is List) ? res.length : 0;
      } else {
        // Fallback pour l'ancien schéma
        final res = await _client
            .from(ChatService.chatsTable)
            .select('id')
            .neq('sender_id', uid)
            .gt('created_at', since.toIso8601String())
            .limit(_maxCount);
        return (res is List) ? res.length : 0;
      }
    } catch (e) {
      debugPrint('NotificationCountersService: countMessagesSince failed err=$e');
      return 0;
    }
  }

  /// Calcule tous les compteurs pour un utilisateur.
  Future<SectionBadgeCounts> _computeCounts(String uid) async {
    final [
      sinceMessages,
      sinceInfo,
      sinceEvents,
      sinceFormations,
      sinceOpportunities,
      sinceJobs,
    ] = await Future.wait([
      _getLastSeen(uid, ThixSection.messages),
      _getLastSeen(uid, ThixSection.info),
      _getLastSeen(uid, ThixSection.events),
      _getLastSeen(uid, ThixSection.formations),
      _getLastSeen(uid, ThixSection.opportunities),
      _getLastSeen(uid, ThixSection.jobs),
    ]);

    final results = await Future.wait([
      _countMessagesSince(uid: uid, since: sinceMessages),
      _countSince(table: _infoTable, since: sinceInfo),
      _countSince(table: _eventsTable, since: sinceEvents),
      _countSince(table: _formationsTable, since: sinceFormations),
      _countSince(table: _opportunitiesTable, since: sinceOpportunities),
      _countSince(table: _jobsTable, since: sinceJobs),
    ]);

    return SectionBadgeCounts(
      messages: results[0].clamp(0, _maxCount),
      info: results[1].clamp(0, _maxCount),
      events: results[2].clamp(0, _maxCount),
      formations: results[3].clamp(0, _maxCount),
      opportunities: results[4].clamp(0, _maxCount),
      jobs: results[5].clamp(0, _maxCount),
    );
  }

  // ==========================================================================
  // MÉTHODES PUBLIQUES
  // ==========================================================================

  /// Marque une section comme vue (réinitialise son badge).
  Future<void> markSectionSeen({
    required String uid,
    required ThixSection section,
  }) async {
    await _setLastSeen(uid, section);
  }

  /// Stream en temps réel des compteurs de badges.
  ///
  /// Utilise Realtime Supabase pour les mises à jour instantanées,
  /// avec fallback sur le polling si la connexion Realtime échoue.
  Stream<SectionBadgeCounts> streamCounts(String uid) {
    final controller = StreamController<SectionBadgeCounts>.broadcast();
    RealtimeChannel? channel;
    Timer? pollTimer;
    bool isPolling = false;
    bool isCancelled = false;

    // Émet les compteurs courants
    Future<void> emit() async {
      if (controller.isClosed) return;
      final counts = await _computeCounts(uid);
      if (!controller.isClosed) controller.add(counts);
    }

    // Démarre le polling (fallback)
    void startPolling() {
      if (isPolling || isCancelled) return;
      isPolling = true;
      pollTimer?.cancel();
      pollTimer = Timer.periodic(_pollingInterval, (_) => unawaited(emit()));
    }

    // Arrête le polling
    void stopPolling() {
      isPolling = false;
      pollTimer?.cancel();
      pollTimer = null;
    }

    // Nettoie les ressources
    Future<void> cleanup() async {
      isCancelled = true;
      stopPolling();
      if (channel != null) {
        await _client.removeChannel(channel!);
        channel = null;
      }
    }

    // Configure Realtime
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
          debugPrint('NotificationCountersService: realtime status=$status error=$error');
          final errorMsg = error?.toString().toLowerCase() ?? '';
          final isPermanent = errorMsg.contains('permission denied') ||
              errorMsg.contains('rls') ||
              errorMsg.contains('does not exist');

          if (isPermanent || status == RealtimeSubscribeStatus.channelError) {
            startPolling();
          }
        });

        // Première émission
        await emit();
      } catch (e) {
        debugPrint('NotificationCountersService: realtime setup failed err=$e');
        startPolling();
        await emit();
      }
    }

    // Gestion du cycle de vie du stream
    controller.onListen = () => unawaited(setupRealtime());
    controller.onCancel = () {
      unawaited(cleanup());
    };

    return controller.stream.distinct();
  }
}
