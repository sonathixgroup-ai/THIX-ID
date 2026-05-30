// ============================================================================
// FICHIER: lib/services/event_service.dart
// ============================================================================
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/models/event_item.dart';
import 'package:thix_id/models/event_registration.dart';

class EventService {
  final SupabaseClient _supabase;

  EventService(this._supabase);

  // ==========================================================================
  // ÉVÉNEMENTS
  // ==========================================================================

  Future<List<EventItem>> getRecommendedEvents({int limit = 4}) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('is_recommended', true)
          .order('event_date', ascending: true)
          .limit(limit);

      return (response as List)
          .map((json) => EventItem.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur getRecommendedEvents: $e');
      return [];
    }
  }

  Future<List<EventItem>> getUpcomingEvents({int limit = 10}) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('events')
          .select()
          .gt('event_date', now)
          .order('event_date', ascending: true)
          .limit(limit);

      return (response as List)
          .map((json) => EventItem.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur getUpcomingEvents: $e');
      return [];
    }
  }

  Future<List<EventItem>> getAllEvents({
    String? category,
    String? search,
  }) async {
    try {
      PostgrestFilterBuilder query =
          _supabase.from('events').select();

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (search != null && search.isNotEmpty) {
        query = query.ilike('title', '%$search%');
      }

      final response =
          await query.order('event_date', ascending: true);

      return (response as List)
          .map((json) => EventItem.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur getAllEvents: $e');
      return [];
    }
  }

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

  Future<List<String>> getPopularCategories() async {
    try {
      final List response = await _supabase
          .from('events')
          .select('category')
          .limit(100);

      final Map<String, int> counts = {};

      for (final item in response) {
        final category = item['category']?.toString();

        if (category != null && category.isNotEmpty) {
          counts[category] = (counts[category] ?? 0) + 1;
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
  // RÉSERVATIONS
  // ==========================================================================

  Future<List<EventRegistration>> getUserRegistrations(
      String userId) async {
    try {
      final response = await _supabase
          .from('thix_event_tickets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => EventRegistration.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur getUserRegistrations: $e');
      return [];
    }
  }

  Future<EventRegistration?> getRegistrationById(
      String registrationId) async {
    try {
      final response = await _supabase
          .from('thix_event_tickets')
          .select()
          .eq('id', registrationId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return EventRegistration.fromJson(response);
    } catch (e) {
      debugPrint('Erreur getRegistrationById: $e');
      return null;
    }
  }

  Future<String> createRegistration(
    Map<String, dynamic> registrationData, {
    required String userId,
  }) async {
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

      return response['ticket_code']?.toString() ?? '';
    } catch (e) {
      debugPrint('Erreur createRegistration: $e');
      throw Exception(
        'Impossible de créer la réservation',
      );
    }
  }

  Future<void> cancelRegistration(
      String registrationId) async {
    try {
      await _supabase
          .from('thix_event_tickets')
          .update({
        'status': 'cancelled',
      }).eq('id', registrationId);
    } catch (e) {
      debugPrint('Erreur cancelRegistration: $e');
      throw Exception(
        'Impossible d\'annuler la réservation',
      );
    }
  }

  Future<bool> hasUserTicket(
    String userId,
    String eventId,
  ) async {
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

  Future<bool> registerForEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      final alreadyRegistered = await hasUserTicket(
        userId,
        eventId,
      );

      if (alreadyRegistered) {
        return false;
      }

      final ticketCode =
          'THIX-${DateTime.now().millisecondsSinceEpoch}';

      await _supabase
          .from('thix_event_tickets')
          .insert({
        'user_id': userId,
        'event_id': eventId,
        'ticket_code': ticketCode,
        'status': 'valid',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Erreur registerForEvent: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTicketByCode(
      String ticketCode) async {
    try {
      final response = await _supabase
          .from('thix_event_tickets')
          .select()
          .eq('ticket_code', ticketCode)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Erreur getTicketByCode: $e');
      return null;
    }
  }

  // ==========================================================================
  // CODES PROMO
  // ==========================================================================

  Future<double?> validatePromoCode(
    String code,
    String eventId,
  ) async {
    try {
      final response = await _supabase
          .from('promo_codes')
          .select()
          .eq('code', code)
          .eq('event_id', eventId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final validUntil = DateTime.tryParse(
        response['valid_until']?.toString() ?? '',
      );

      if (validUntil == null) {
        return null;
      }

      if (validUntil.isBefore(DateTime.now())) {
        return null;
      }

      return (response['discount_percent'] as num)
          .toDouble();
    } catch (e) {
      debugPrint('Erreur validatePromoCode: $e');
      return null;
    }
  }
}
