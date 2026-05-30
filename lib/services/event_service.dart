// ============================================================================
// FICHIER: lib/services/event_service.dart
// ============================================================================
import 'package:flutter/foundation.dart'; // Ajouté pour debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/models/event_item.dart';
import 'package:thix_id/models/event_registration.dart';

class EventService {
  final SupabaseClient _supabase;

  EventService(this._supabase);

  // ==========================================================================
  // ÉVÉNEMENTS
  // ==========================================================================

  /// Récupère les événements recommandés (limite optionnelle)
  Future<List<EventItem>> getRecommendedEvents({int limit = 4}) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('is_recommended', true)
          .order('event_date', ascending: true)
          .limit(limit);

      return response.map((json) => EventItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erreur getRecommendedEvents: $e');
      return [];
    }
  }

  /// Récupère les prochains événements (à venir, triés par date)
  Future<List<EventItem>> getUpcomingEvents({int limit = 10}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('events')
          .select()
          .gt('event_date', now)
          .order('event_date', ascending: true)
          .limit(limit);

      return response.map((json) => EventItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erreur getUpcomingEvents: $e');
      return [];
    }
  }

  /// Récupère tous les événements (pour la recherche)
  Future<List<EventItem>> getAllEvents({String? category, String? search}) async {
    try {
      var query = _supabase.from('events').select();
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      if (search != null && search.isNotEmpty) {
        query = query.ilike('title', '%$search%');
      }
      final response = await query.order('event_date', ascending: true);
      return response.map((json) => EventItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erreur getAllEvents: $e');
      return [];
    }
  }

  /// Récupère un événement par son ID
  Future<EventItem?> getEventById(String eventId) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('id', eventId)
          .maybeSingle();

      if (response == null) return null;
      return EventItem.fromJson(response);
    } catch (e) {
      debugPrint('Erreur getEventById: $e');
      return null;
    }
  }

  /// Récupère les catégories populaires (top 5 des plus utilisées)
  Future<List<String>> getPopularCategories() async {
    try {
      final response = await _supabase
          .from('events')
          .select('category')
          .limit(100);

      final Map<String, int> counts = {};
      for (var item in response) {
        final cat = item['category'] as String?;
        if (cat != null) {
          counts[cat] = (counts[cat] ?? 0) + 1;
        }
      }
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sorted.take(5).map((e) => e.key).toList();
    } catch (e) {
      debugPrint('Erreur getPopularCategories: $e');
      return [
        'Musique & Concerts',
        'Conférences & Séminaires',
        'Culture & Art',
        'Sport & Loisirs',
        'Festivals & Soirées',
      ];
    }
  }

  // ==========================================================================
  // RÉSERVATIONS (TICKETS)
  // ==========================================================================

  /// Récupère toutes les réservations d'un utilisateur
  Future<List<EventRegistration>> getUserRegistrations(String userId) async {
    try {
      final response = await _supabase
          .from('thix_event_tickets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) => EventRegistration.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erreur getUserRegistrations: $e');
      return [];
    }
  }

  /// Récupère une réservation par son ID
  Future<EventRegistration?> getRegistrationById(String registrationId) async {
    try {
      final response = await _supabase
          .from('thix_event_tickets')
          .select()
          .eq('id', registrationId)
          .maybeSingle();

      if (response == null) return null;
      return EventRegistration.fromJson(response);
    } catch (e) {
      debugPrint('Erreur getRegistrationById: $e');
      return null;
    }
  }

  /// Crée une nouvelle réservation
  Future<String> createRegistration(Map<String, dynamic> registrationData,
      {required String userId}) async {
    try {
      final data = {
        ...registrationData,
        'user_id': userId,
        'status': 'valid',
        'created_at': DateTime.now().toIso8601String(),
      };
      final response = await _supabase
          .from('thix_event_tickets')
          .insert(data)
          .select('ticket_code')
          .single();

      return response['ticket_code'] as String;
    } catch (e) {
      debugPrint('Erreur createRegistration: $e');
      throw Exception('Impossible de créer la réservation: $e');
    }
  }

  /// Annule une réservation
  Future<void> cancelRegistration(String registrationId) async {
    try {
      await _supabase
          .from('thix_event_tickets')
          .update({'status': 'cancelled'})
          .eq('id', registrationId);
    } catch (e) {
      debugPrint('Erreur cancelRegistration: $e');
      throw Exception('Impossible d\'annuler la réservation: $e');
    }
  }

  /// Vérifie si l'utilisateur a déjà un billet
  Future<bool> hasUserTicket(String userId, String eventId) async {
    try {
      final response = await _supabase
          .from('thix_event_tickets')
          .select('id')
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .eq('status', 'valid')
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Erreur hasUserTicket: $e');
      return false;
    }
  }

  // ==========================================================================
  // CODES PROMO
  // ==========================================================================

  /// Valide un code promo
  Future<double?> validatePromoCode(String code, String eventId) async {
    try {
      final response = await _supabase
          .from('promo_codes')
          .select()
          .eq('code', code)
          .eq('event_id', eventId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      final now = DateTime.now();
      final validUntil = DateTime.parse(response['valid_until'] as String);
      if (validUntil.isBefore(now)) return null;

      return (response['discount_percent'] as num).toDouble();
    } catch (e) {
      debugPrint('Erreur validatePromoCode: $e');
      return null;
    }
  }
}
