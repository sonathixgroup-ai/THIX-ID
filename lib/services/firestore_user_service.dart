import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/models/app_user.dart';
import 'package:thix_id/services/profile_service.dart';
import 'package:thix_id/services/supabase_safe_write.dart';
import 'package:thix_id/services/thix_id_service.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class FirestoreUserService {
  final SupabaseClient _client;
  final ProfileService _profiles;

  FirestoreUserService({SupabaseClient? client, ProfileService? profiles})
      : _client = client ?? SupabaseConfig.client,
        _profiles = profiles ?? ProfileService();

  static const _table = ProfileService.table;

  String _requireAuthedUid() {
    final uid = _client.auth.currentSession?.user.id;
    if (uid == null || uid.trim().isEmpty) {
      throw StateError('Non authentifié.');
    }
    return uid;
  }

  // ==========================================================================
  // MÉTHODES DE LECTURE (à garder telles quelles)
  // ==========================================================================

  Future<AppUser?> fetchUserByUid(String uid) async {
    // ... votre code existant (non modifié)
    return null; // placeholder
  }

  Future<AppUser?> fetchUserByThixId(String thixId) async {
    // ... votre code existant
    return null;
  }

  Future<List<AppUser>> searchUsers(String query, {int limit = 12, String? excludeUid}) async {
    // ... votre code existant
    return [];
  }

  // ==========================================================================
  // MÉTHODES DE MISE À JOUR CORRIGÉES (sans countryCode)
  // ==========================================================================

  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? photoUrl,
    String? thixChat,
    String? registrationStatus,
    // Ajoutez ici les autres champs que vous utilisez
  }) async {
    final sessionUid = _requireAuthedUid();
    final patch = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (displayName != null) patch['display_name'] = displayName;
    if (bio != null) patch['bio'] = bio;
    if (photoUrl != null) patch['photo_url'] = photoUrl;
    if (thixChat != null) patch['thix_chat'] = thixChat;
    if (registrationStatus != null) patch['registration_status'] = registrationStatus;

    try {
      await _client.from(_table).update(patch).eq('id', sessionUid);
    } catch (e) {
      debugPrint('FirestoreUserService.updateProfile error: $e');
      rethrow;
    }
  }

  /// Assure qu'un THIX ID existe (sans countryCode)
  Future<String> ensureThixId({required String uid}) async {
    final sessionUid = _requireAuthedUid();
    try {
      final row = await _client.from(_table).select('thix_id').eq('id', sessionUid).maybeSingle();
      final existing = (row?['thix_id'] ?? '').toString().trim();
      if (existing.isNotEmpty && existing != 'THIX-PENDING') return existing;

      final candidate = ThixIdService.generate(); // ✅ sans countryCode
      await _client.from(_table).update({'thix_id': candidate}).eq('id', sessionUid);
      return candidate;
    } catch (e) {
      debugPrint('FirestoreUserService.ensureThixId error: $e');
      return 'THIX-PENDING';
    }
  }

  /// Assigne un THIX ID réel si manquant (sans countryCode)
  Future<String> assignRealThixIdIfMissing({required String uid}) async {
    final sessionUid = _requireAuthedUid();
    try {
      // Vérifier si déjà présent
      final row = await _client.from(_table).select('thix_id').eq('id', sessionUid).maybeSingle();
      final existing = (row?['thix_id'] ?? '').toString().trim();
      if (existing.isNotEmpty && existing != 'THIX-PENDING' && existing != 'THIX-000000') {
        return existing;
      }
      // Générer un nouveau
      final candidate = ThixIdService.generate(); // ✅ sans countryCode
      await _client.from(_table).update({'thix_id': candidate}).eq('id', sessionUid);
      return candidate;
    } catch (e) {
      debugPrint('FirestoreUserService.assignRealThixIdIfMissing error: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // AUTRES MÉTHODES (activateAfterPayment, addPaymentTransaction, etc.)
  // ==========================================================================
  // À conserver telles quelles, mais retirez tout appel à countryCode si présent
}
