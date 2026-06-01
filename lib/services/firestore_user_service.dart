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

  // ==========================================================================
  // MÉTHODES DE CONVERSION
  // ==========================================================================

  AppUser _appUserFromProfileRow(Map<String, dynamic> row) {
    DateTime dt(Object? v) {
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    List<String> strList(Object? v) => (v is List) 
        ? v.whereType<String>().toList(growable: false) 
        : const <String>[];
        
    List<Map<String, dynamic>> mapList(Object? v) => (v is List) 
        ? v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false) 
        : const <Map<String, dynamic>>[];

    final accountTypeRaw = (row['account_type'] ?? row['accountType'] ?? 'personal').toString();
    final accountType = AccountType.values.firstWhere(
      (e) => e.name == accountTypeRaw,
      orElse: () => AccountType.personal,
    );

    return AppUser(
      id: (row['user_id'] ?? row['id'] ?? '').toString(),
      thixId: (row['thix_id'] ?? 'THIX-PENDING').toString(),
      thixChat: (row['thix_chat'] ?? '').toString(),
      thixScore: (row['thix_score'] as num?)?.toInt(),
      email: row['email']?.toString() ?? '',
      phone: row['phone']?.toString(),
      displayName: (row['display_name'] ?? 'Utilisateur THIX').toString(),
      accountType: accountType,
      photoUrl: (row['photo_url'] ?? row['avatar_url'])?.toString(),
      bio: row['bio']?.toString(),
      countryOrOrigin: row['country_or_origin']?.toString(),
      contactPhone: row['contact_phone']?.toString(),
      maritalStatus: row['marital_status']?.toString(),
      gender: row['gender']?.toString(),
      occupation: (row['occupation'] ?? row['occupation_title'])?.toString(),
      profession: (row['profession'] ?? row['job_title'])?.toString(),
      dateOfBirth: row['date_of_birth']?.toString(),
      placeOfBirth: row['place_of_birth']?.toString(),
      nationality: row['nationality']?.toString(),
      address: row['address']?.toString(),
      fatherName: row['father_name']?.toString(),
      motherName: row['mother_name']?.toString(),
      emergencyContactName: row['emergency_contact_name']?.toString(),
      emergencyContactPhone: row['emergency_contact_phone']?.toString(),
      emergencyContactRelation: row['emergency_contact_relation']?.toString(),
      registrationStatus: row['registration_status']?.toString(),
      education: mapList(row['education']),
      experience: mapList(row['experience']),
      skills: mapList(row['skills']),
      enrollments: mapList(row['enrollments']),
      languages: strList(row['languages']),
      biometricsEnabled: (row['biometrics_enabled'] as bool?) ?? true,
      twoFaEnabled: (row['two_fa_enabled'] as bool?) ?? false,
      createdAt: dt(row['created_at']),
      updatedAt: dt(row['updated_at']),
    );
  }

  // ==========================================================================
  // MÉTHODES DE LECTURE
  // ==========================================================================

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

  Future<AppUser?> fetchUserByThixId(String thixId) async {
    final normalized = thixId.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    try {
      final row = await _client.from(_table).select('*').eq('thix_id', normalized).maybeSingle();
      if (row == null) return null;
      return _appUserFromProfileRow((row as Map).cast<String, dynamic>());
    } catch (e) {
      debugPrint('Erreur fetchUserByThixId: $e');
      return null;
    }
  }

  Future<List<AppUser>> searchUsers(String query, {int limit = 12, String? excludeUid}) async {
    final q = query.trim();
    if (q.isEmpty) return const <AppUser>[];
    try {
      final like = '%$q%';
      final rows = await _client
          .from(_table)
          .select('id, display_name, thix_id, thix_chat, avatar_url')
          .or('display_name.ilike.$like,thix_id.ilike.$like,thix_chat.ilike.$like')
          .limit(limit);
      if (rows is! List) return const [];
      final list = rows.whereType<Map>().map((m) => _appUserFromProfileRow(m.cast<String, dynamic>())).toList(growable: false);
      if (excludeUid == null || excludeUid.trim().isEmpty) return list;
      final ex = excludeUid.trim();
      return list.where((u) => u.id != ex).toList(growable: false);
    } catch (e) {
      debugPrint('Erreur searchUsers: $e');
      return const [];
    }
  }

  // ==========================================================================
  // MÉTHODES POUR LE DASHBOARD (addPaymentTransaction, streamPayments, logSecurityEvent, streamSecurityEvents)
  // ==========================================================================

  Future<void> addPaymentTransaction({
    required String uid,
    required String title,
    required num amount,
    String currency = 'USD',
    String method = 'Simulé',
    String status = 'paid',
    String? transactionRef,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final txRef = transactionRef ?? 'tx_${DateTime.now().millisecondsSinceEpoch}_${uid.substring(0, uid.length >= 6 ? 6 : uid.length)}';
      await _client.from('thix_payments').insert({
        'user_id': uid,
        'tx_ref': txRef,
        'method': '$method • $title',
        'amount': amount,
        'currency': currency,
        'status': status,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      if (meta != null && meta.isNotEmpty) {
        try {
          await _client.from('thix_payment_meta').insert({
            'user_id': uid,
            'tx_ref': txRef,
            'meta': meta,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('FirestoreUserService: addPaymentTransaction failed uid=$uid err=$e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamPayments(String uid) async* {
    while (true) {
      try {
        final rows = await _client.from('thix_payments').select('*').eq('user_id', uid).order('created_at', ascending: false).limit(50);
        if (rows is List) {
          yield rows.map((e) => (e as Map).cast<String, dynamic>()).toList(growable: false);
        } else {
          yield const <Map<String, dynamic>>[];
        }
      } catch (e) {
        debugPrint('FirestoreUserService: streamPayments failed uid=$uid err=$e');
        yield const <Map<String, dynamic>>[];
      }
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> logSecurityEvent({
    required String uid,
    required String type,
    String? label,
    Map<String, dynamic>? meta,
  }) async {
    try {
      await _client.from('thix_security_events').insert({
        'user_id': uid,
        'type': type,
        'label': label,
        'meta': meta ?? const <String, dynamic>{},
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('FirestoreUserService: logSecurityEvent failed uid=$uid err=$e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamSecurityEvents(String uid) async* {
    while (true) {
      try {
        final rows = await _client.from('thix_security_events').select('*').eq('user_id', uid).order('created_at', ascending: false).limit(40);
        if (rows is List) {
          yield rows.map((e) => (e as Map).cast<String, dynamic>()).toList(growable: false);
        } else {
          yield const <Map<String, dynamic>>[];
        }
      } catch (e) {
        debugPrint('FirestoreUserService: streamSecurityEvents failed uid=$uid err=$e');
        yield const <Map<String, dynamic>>[];
      }
      await Future<void>.delayed(const Duration(seconds: 4));
    }
  }

  // ==========================================================================
  // MÉTHODES DE MISE À JOUR
  // ==========================================================================

  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? thixChat,
  }) async {
    final sessionUid = _requireAuthedUid();
    final patch = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    
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
