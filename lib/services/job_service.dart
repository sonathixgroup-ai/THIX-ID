import 'package:flutter/foundation.dart';
import 'package:thix_id/models/job_posting.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class JobService {
  static const String table = 'thix_job_offers';

  Future<List<JobPosting>> listJobs() async {
    try {
      final res = await SupabaseService.select(table, select: '*', orderBy: 'created_at', ascending: false);
      // Correction ici :
      return (res as List).map((row) => JobPosting.fromSupabase(row as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Erreur : $e');
      return [];
    }
  }

  Future<JobPosting?> fetchJob(String jobId) async {
    try {
      final data = await SupabaseService.select(table, select: '*', filter: {'id': jobId});
      if (data.isEmpty) return null;
      // Correction ici :
      return JobPosting.fromSupabase(data.first as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
