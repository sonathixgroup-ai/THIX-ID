import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/models/app_user.dart';
import 'package:thix_id/services/profile_service.dart';
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

  // Méthode de conversion indispensable pour éviter les erreurs de type
  AppUser _appUserFromProfileRow(Map<String, dynamic> row) {
    return AppUser(
      id: (row['user_id'] ?? row['id'] ?? '').toString(),
      thixId: (row['thix_id'] ?? 'THIX-PENDING').toString(),
      displayName: (row['display_name'] ?? 'Utilisateur').toString(),
      // Assurez-vous que ces champs correspondent à votre classe AppUser
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Future<AppUser?> fetchUserByUid(String uid) async {
    try {
      final row = await _client.from(_table).select('*').eq('id', uid).maybeSingle();
      if (row == null) return null;
      return _appUserFromProfileRow((row as Map).cast<String, dynamic>());
    } catch (e) {
      debugPrint('Erreur fetchUserByUid: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? thixChat,
  }) async {
    final sessionUid = _requireAuthedUid();
    final patch = <String, dynamic>{'updated_at': DateTime.now().toUtc().toIso8601String()};
    
    if (displayName != null) patch['display_name'] = displayName;
    if (thixChat != null) patch['thix_chat'] = thixChat;

    await _client.from(_table).update(patch).eq('id', sessionUid);
  }

  Future<String> ensureThixId({required String uid}) async {
    final sessionUid = _requireAuthedUid();
    final row = await _client.from(_table).select('thix_id').eq('id', sessionUid).maybeSingle();
    final existing = (row?['thix_id'] ?? '').toString().trim();
    
    if (existing.isNotEmpty && existing != 'THIX-PENDING') return existing;

    final candidate = ThixIdService.generate();
    await _client.from(_table).update({'thix_id': candidate}).eq('id', sessionUid);
    return candidate;
  }

  Future<String> assignRealThixIdIfMissing({required String uid}) async {
    final sessionUid = _requireAuthedUid();
    final row = await _client.from(_table).select('thix_id').eq('id', sessionUid).maybeSingle();
    final existing = (row?['thix_id'] ?? '').toString().trim();
    
    if (existing.isNotEmpty && existing != 'THIX-PENDING') return existing;

    final candidate = ThixIdService.generate();
    await _client.from(_table).update({'thix_id': candidate}).eq('id', sessionUid);
    return candidate;
  }
}
