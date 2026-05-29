import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/models/job_application.dart';
import 'package:thix_id/models/job_posting.dart';

class JobService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String table = 'thix_job_offers';

  /// Récupère la liste complète des offres d'emploi
  Future<List<JobPosting>> listJobs() async {
    try {
      final response = await _client
          .from(table)
          .select('*')
          .order('created_at', ascending: false);

      // On utilise votre méthode fromJson optimisée
      return (response as List<dynamic>)
          .map((json) => JobPosting.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('JobService.listJobs error: $e');
      return [];
    }
  }

  /// Récupère les détails d'un job par son ID
  Future<JobPosting?> fetchJob(String jobId) async {
    try {
      final data = await _client
          .from(table)
          .select('*')
          .eq('id', jobId)
          .single();
          
      return JobPosting.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('JobService.fetchJob error: $e');
      return null;
    }
  }

  /// Récupère les IDs des jobs sauvegardés pour l'utilisateur actuel
  Future<Set<String>> getSavedJobIdsRemote() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};

    try {
      final data = await _client
          .from('saved_jobs')
          .select('job_id')
          .eq('user_id', userId);

      return (data as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>)['job_id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('JobService.getSavedJobIdsRemote error: $e');
      return {};
    }
  }

  /// Ajoute/Supprime un job des favoris
  Future<void> toggleSavedRemote({required String jobId, required bool save}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Utilisateur non connecté');

    try {
      if (save) {
        await _client.from('saved_jobs').insert({
          'user_id': userId,
          'job_id': jobId,
        });
      } else {
        await _client
            .from('saved_jobs')
            .delete()
            .eq('user_id', userId)
            .eq('job_id', jobId);
      }
    } catch (e) {
      debugPrint('JobService.toggleSavedRemote error: $e');
      rethrow;
    }
  }

  /// Soumet une nouvelle candidature
  Future<void> submitApplication({
    required String jobId,
    required String applicantThixId,
    String? message,
  }) async {
    try {
      await _client.from('thix_job_applications').insert({
        'job_id': jobId,
        'applicant_thix_id': applicantThixId.trim().toUpperCase(),
        'message': message?.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('JobService.submitApplication error: $e');
      rethrow;
    }
  }
}
