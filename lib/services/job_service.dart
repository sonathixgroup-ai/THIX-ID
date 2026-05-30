import 'package:flutter/foundation.dart';
import 'package:thix_id/models/job_posting.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class JobService {
  static const String table = 'thix_job_offers';

  /// LISTE DES EMPLOIS
  Future<List<JobPosting>> listJobs() async {
    try {
      final response = await SupabaseService.select(
        table,
        select: '*',
        orderBy: 'created_at',
        ascending: false,
      );

      if (response == null) {
        return [];
      }

      return (response as List)
          .map(
            (item) => JobPosting.fromSupabase(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Erreur listJobs: $e');
      return [];
    }
  }

  /// UN SEUL EMPLOI
  Future<JobPosting?> fetchJob(String jobId) async {
    try {
      final response = await SupabaseService.select(
        table,
        select: '*',
        filters: {
          'id': jobId,
        },
      );

      if (response == null || response.isEmpty) {
        return null;
      }

      return JobPosting.fromSupabase(
        response.first as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('Erreur fetchJob: $e');
      return null;
    }
  }

  /// AJOUTER EMPLOI
  Future<bool> createJob(JobPosting job) async {
    try {
      await SupabaseService.insert(
        table,
        job.toMap(),
      );

      return true;
    } catch (e) {
      debugPrint('Erreur createJob: $e');
      return false;
    }
  }

  /// MODIFIER EMPLOI
  Future<bool> updateJob(JobPosting job) async {
    try {
      await SupabaseService.update(
        table,
        data: job.toMap(),
        filters: {
          'id': job.id,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Erreur updateJob: $e');
      return false;
    }
  }

  /// SUPPRIMER EMPLOI
  Future<bool> deleteJob(String jobId) async {
    try {
      await SupabaseService.delete(
        table,
        filters: {
          'id': jobId,
        },
      );

      return true;
    } catch (e) {
      debugPrint('Erreur deleteJob: $e');
      return false;
    }
  }

  /// LISTE DES CANDIDATURES DU RECRUTEUR
  Future<List<Map<String, dynamic>>> listRecruiterApplications({
    required String recruiterUserId,
  }) async {
    try {
      final response = await SupabaseService.select(
        'job_applications',
        select: '*',
        filters: {
          'recruiter_user_id': recruiterUserId,
        },
        orderBy: 'created_at',
        ascending: false,
      );

      if (response == null) {
        return [];
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint(
        'Erreur listRecruiterApplications: $e',
      );

      return [];
    }
  }
  /// JOBS SAUVEGARDÉS
  Future<Set<String>> getSavedJobIdsRemote() async {
    try {
      final response = await SupabaseService.select(
        'saved_jobs',
        select: '*',
      );

      if (response == null) {
        return {};
      }

      return (response as List)
          .map(
            (e) => (e['job_id'] ?? '').toString(),
          )
          .toSet();
    } catch (e) {
      debugPrint('Erreur getSavedJobIdsRemote: $e');
      return {};
    }
  }

  /// MES CANDIDATURES DISTANTES
  Future<List<Map<String, dynamic>>> listMyApplicationsRemote() async {
    try {
      final response = await SupabaseService.select(
        'job_applications',
        select: '*',
        orderBy: 'created_at',
        ascending: false,
      );

      if (response == null) {
        return [];
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erreur listMyApplicationsRemote: $e');
      return [];
    }
  }

  /// CANDIDATURES LOCALES
  Future<List<JobPosting>> listLocalApplications() async {
    try {
      return [];
    } catch (e) {
      debugPrint('Erreur listLocalApplications: $e');
      return [];
    }
  }

  /// RECOMMANDATION AI
  Future<List<Map<String, dynamic>>?> aiRecommendJobs({
    required Map<String, dynamic> userProfile,
    required List<JobPosting> jobs,
    int limit = 8,
  }) async {
    try {
      return jobs.take(limit).map((job) {
        return {
          'job_id': job.id,
          'title': job.title,
          'company': job.company,
          'location': job.location,
          'salary': job.salary,
        };
      }).toList();
    } catch (e) {
      debugPrint('Erreur aiRecommendJobs: $e');
      return [];
    }
  }
}
