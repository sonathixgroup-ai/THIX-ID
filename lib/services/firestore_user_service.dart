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
  // CONVERSION
  // ==========================================================================

  AppUser _appUserFromProfileRow(Map<String, dynamic> row) {
    DateTime dt(Object? v) {
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    List<String> strList(Object? v) => (v is List) ? v.whereType<String>().toList(growable: false) : const <String>[];
    List<Map<String, dynamic>> mapList(Object? v) => (v is List) ? v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false) : const <Map<String, dynamic>>[];

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
  // LECTURE
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
  // MÉTHODES POUR LE DASHBOARD
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
    debugPrint('addPaymentTransaction: uid=$uid, title=$title, amount=$amount');
  }

  Stream<List<Map<String, dynamic>>> streamPayments(String uid) async* {
    yield [];
  }

  Future<void> logSecurityEvent({
    required String uid,
    required String type,
    String? label,
    Map<String, dynamic>? meta,
  }) async {
    debugPrint('logSecurityEvent: uid=$uid, type=$type');
  }

  Stream<List<Map<String, dynamic>>> streamSecurityEvents(String uid) async* {
    yield [];
  }

  // ==========================================================================
  // MISE À JOUR SIMPLIFIÉE
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

  // ==========================================================================
  // MISE À JOUR COMPLÈTE (pour le dashboard)
  // ==========================================================================

  Future<void> updateProfileFull({
    required String uid,
    String? fullName,
    String? competence,
    String? bio,
    String? countryOrOrigin,
    String? contactPhone,
    String? maritalStatus,
    String? gender,
    String? occupation,
    String? profession,
    String? dateOfBirth,
    String? placeOfBirth,
    String? nationality,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? originProvince,
    String? originTerritory,
    String? originSector,
    String? residenceCountry,
    String? residenceProvince,
    String? residenceTerritory,
    String? residenceCity,
    String? residenceCommune,
    String? residenceQuarter,
    String? bloodGroup,
    bool? hasPhysicalDisability,
    String? physicalDisabilityDescription,
    String? nationalityNumber,
    String? idDocumentType,
    String? idDocumentIssueDate,
    String? idDocumentExpiryDate,
    String? idDocumentIssuePlace,
    String? idDocumentFrontDocId,
    String? idDocumentBackDocId,
    String? idDocumentSelfieDocId,
    String? idVerificationStatus,
    List<String>? languages,
    List<Map<String, dynamic>>? languagesDetailed,
    String? photoUrl,
    bool? biometricsEnabled,
    bool? twoFaEnabled,
  }) async {
    final sessionUid = _requireAuthedUid();
    final patch = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    
    // N'ajouter que les champs non nuls
    if (fullName != null) patch['full_name'] = fullName;
    if (competence != null) patch['competence'] = competence;
    if (bio != null) patch['bio'] = bio;
    if (countryOrOrigin != null) patch['country_or_origin'] = countryOrOrigin;
    if (contactPhone != null) patch['contact_phone'] = contactPhone;
    if (maritalStatus != null) patch['marital_status'] = maritalStatus;
    if (gender != null) patch['gender'] = gender;
    if (occupation != null) patch['occupation'] = occupation;
    if (profession != null) patch['profession'] = profession;
    if (dateOfBirth != null) patch['date_of_birth'] = dateOfBirth;
    if (placeOfBirth != null) patch['place_of_birth'] = placeOfBirth;
    if (nationality != null) patch['nationality'] = nationality;
    if (address != null) patch['address'] = address;
    if (emergencyContactName != null) patch['emergency_contact_name'] = emergencyContactName;
    if (emergencyContactPhone != null) patch['emergency_contact_phone'] = emergencyContactPhone;
    if (emergencyContactRelation != null) patch['emergency_contact_relation'] = emergencyContactRelation;
    if (originProvince != null) patch['origin_province'] = originProvince;
    if (originTerritory != null) patch['origin_territory'] = originTerritory;
    if (originSector != null) patch['origin_sector'] = originSector;
    if (residenceCountry != null) patch['residence_country'] = residenceCountry;
    if (residenceProvince != null) patch['residence_province'] = residenceProvince;
    if (residenceTerritory != null) patch['residence_territory'] = residenceTerritory;
    if (residenceCity != null) patch['residence_city'] = residenceCity;
    if (residenceCommune != null) patch['residence_commune'] = residenceCommune;
    if (residenceQuarter != null) patch['residence_quarter'] = residenceQuarter;
    if (bloodGroup != null) patch['blood_group'] = bloodGroup;
    if (hasPhysicalDisability != null) patch['has_physical_disability'] = hasPhysicalDisability;
    if (physicalDisabilityDescription != null) patch['physical_disability_description'] = physicalDisabilityDescription;
    if (nationalityNumber != null) patch['nationality_number'] = nationalityNumber;
    if (idDocumentType != null) patch['id_document_type'] = idDocumentType;
    if (idDocumentIssueDate != null) patch['id_document_issue_date'] = idDocumentIssueDate;
    if (idDocumentExpiryDate != null) patch['id_document_expiry_date'] = idDocumentExpiryDate;
    if (idDocumentIssuePlace != null) patch['id_document_issue_place'] = idDocumentIssuePlace;
    if (idDocumentFrontDocId != null) patch['id_document_front_doc_id'] = idDocumentFrontDocId;
    if (idDocumentBackDocId != null) patch['id_document_back_doc_id'] = idDocumentBackDocId;
    if (idDocumentSelfieDocId != null) patch['id_document_selfie_doc_id'] = idDocumentSelfieDocId;
    if (idVerificationStatus != null) patch['id_verification_status'] = idVerificationStatus;
    if (languages != null) patch['languages'] = languages;
    if (languagesDetailed != null) patch['languages_detailed'] = languagesDetailed;
    if (photoUrl != null) patch['avatar_url'] = photoUrl;
    if (biometricsEnabled != null) patch['biometrics_enabled'] = biometricsEnabled;
    if (twoFaEnabled != null) patch['two_fa_enabled'] = twoFaEnabled;

    try {
      if (patch.length > 1) { // plus que 'updated_at'
        await _client.from(_table).update(patch).eq('id', sessionUid);
      }
    } catch (e) {
      debugPrint('FirestoreUserService: updateProfileFull failed uid=$uid err=$e');
      // Ne pas relancer l'erreur pour ne pas casser l'UI
    }
  }

  // ==========================================================================
  // THIX ID
  // ==========================================================================

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
