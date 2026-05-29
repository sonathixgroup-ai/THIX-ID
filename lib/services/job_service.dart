import 'package:flutter/foundation.dart';
import 'package:thix_id/models/job_posting.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class JobService {
  static const String table = 'thix_job_offers';

  Future<List<JobPosting>> listJobs() async {
    try {
      final res = await SupabaseService.select(
        table,
        select: '*',
        orderBy: 'created_at',
        ascending: false,
      );

      return (res as List)
          .map(
            (row) =>
                JobPosting.fromSupabase(row as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Erreur listJobs: $e');
      return [];
    }
  }

  Future<JobPosting?> fetchJob(String jobId) async {
    try {
      final data = await SupabaseService.select(
        table,
        select: '*',
        filter: {'id': jobId},
      );

      if (data == null || data.isEmpty) {
        return null;
      }

      return JobPosting.fromSupabase(
        data.first as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('Erreur fetchJob: $e');
      return null;
    }
  }
}
