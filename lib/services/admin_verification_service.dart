import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/services/verification_status.dart';
import 'package:thix_id/supabase/supabase_config.dart';

@immutable
class VerificationQueueItem {
  final String table; // formations | experiences | profiles
  final int? linkedRowId; // bigint for formations/experiences
  final String userId; // profile id
  final String title;
  final Map<String, dynamic> payload;
  final VerificationStatus status;
  final DateTime? createdAt;

  const VerificationQueueItem({
    required this.table,
    required this.linkedRowId,
    required this.userId,
    required this.title,
    required this.payload,
    required this.status,
    required this.createdAt,
  });
}

class AdminVerificationService {
  final SupabaseClient _client;
  AdminVerificationService({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  static const formationsTable = 'formations';
  static const experiencesTable = 'experiences';
  static const profilesTable = 'profiles';

  Future<List<VerificationQueueItem>> fetchQueue({int limit = 250}) async {
    final items = <VerificationQueueItem>[];
    items.addAll(await _fetchLinked(table: formationsTable, limit: limit));
    items.addAll(await _fetchLinked(table: experiencesTable, limit: limit));
    items.addAll(await _fetchIdentity(limit: limit));
    items.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
    return items;
  }

  Future<List<VerificationQueueItem>> _fetchLinked({required String table, required int limit}) async {
    try {
      final rows = await _client.from(table).select('id,user_id,payload,created_at,updated_at').order('created_at', ascending: false).limit(limit);
      if (rows is! List) return const [];
      final list = rows.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList(growable: false);
      return list.map((r) {
        final payload = (r['payload'] is Map) ? (r['payload'] as Map).cast<String, dynamic>() : <String, dynamic>{};
        final status = VerificationStatusX.parse(payload['verification_status'] ?? payload['verificationStatus']);
        final title = (payload['name'] ?? payload['title'] ?? payload['degree'] ?? payload['company'] ?? payload['institution'] ?? '').toString().trim();
        final createdAt = DateTime.tryParse((r['created_at'] ?? '').toString());
        return VerificationQueueItem(
          table: table,
          linkedRowId: (r['id'] is int) ? r['id'] as int : int.tryParse((r['id'] ?? '').toString()),
          userId: (r['user_id'] ?? '').toString(),
          title: title.isEmpty ? table : title,
          payload: payload,
          status: status,
          createdAt: createdAt,
        );
      }).where((it) => it.status == VerificationStatus.pending).toList(growable: false);
    } catch (e) {
      debugPrint('AdminVerificationService: fetch linked failed table=$table err=$e');
      return const [];
    }
  }

  Future<List<VerificationQueueItem>> _fetchIdentity({required int limit}) async {
    try {
      final rows = await _client
          .from(profilesTable)
          .select('id,full_name,display_name,national_id_number,id_document_type,id_document_front_doc_id,id_document_back_doc_id,id_document_selfie_doc_id,id_verification_status,updated_at')
          .order('updated_at', ascending: false)
          .limit(limit);
      if (rows is! List) return const [];
      final list = rows.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList(growable: false);
      final out = <VerificationQueueItem>[];
      for (final r in list) {
        final status = VerificationStatusX.parse(r['id_verification_status']);
        final hasDocs = [r['id_document_front_doc_id'], r['id_document_back_doc_id'], r['id_document_selfie_doc_id']].any((v) => (v ?? '').toString().trim().isNotEmpty);
        if (!hasDocs) continue;
        if (status != VerificationStatus.pending) continue;
        final name = ((r['full_name'] ?? r['display_name']) ?? '').toString().trim();
        out.add(
          VerificationQueueItem(
            table: profilesTable,
            linkedRowId: null,
            userId: (r['id'] ?? '').toString(),
            title: name.isEmpty ? 'Identité nationale' : 'Identité — $name',
            payload: r,
            status: status,
            createdAt: DateTime.tryParse((r['updated_at'] ?? '').toString()),
          ),
        );
      }
      return out;
    } catch (e) {
      debugPrint('AdminVerificationService: fetch identity failed err=$e');
      return const [];
    }
  }

  Future<void> setStatus({required VerificationQueueItem item, required VerificationStatus status}) async {
    if (item.table == profilesTable) {
      await _client.from(profilesTable).update({'id_verification_status': status.value, 'updated_at': DateTime.now().toUtc().toIso8601String()}).eq('id', item.userId);
      return;
    }
    final id = item.linkedRowId;
    if (id == null) throw ArgumentError('Missing linkedRowId for ${item.table}');
    final next = {...item.payload, 'verification_status': status.value, 'verified_at': DateTime.now().toUtc().toIso8601String()};
    await _client.from(item.table).update({'payload': next, 'updated_at': DateTime.now().toUtc().toIso8601String()}).eq('id', id);
  }
}
