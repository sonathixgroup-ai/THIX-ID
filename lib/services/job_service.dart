import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/models/job_application.dart';
import 'package:thix_id/models/job_posting.dart';

class JobService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String table = 'thix_job_offers';

  /// Récupère la liste des jobs depuis Supabase
  Future<List<JobPosting>> listJobs() async {
    try {
      final response = await _client
          .from(table)
          .select('*')
          .order('created_at', ascending: false);

      // CORRECTION : Cast explicite pour éviter les erreurs de type
      return (response as List<dynamic>)
          .map((json) => JobPosting.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('JobService.listJobs error: $e');
      return _getFallbackJobs();
    }
  }

  /// Récupère un job par son ID
  Future<JobPosting?> fetchJob(String jobId) async {
    try {
      final data = await _client.from(table).select('*').eq('id', jobId).single();
      // CORRECTION : Utilisation de fromJson
      return JobPosting.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('JobService.fetchJob error: $e');
      return null;
    }
  }

  /// Soumet une candidature
  Future<JobApplication> submitApplication({
    required String jobId, 
    required String applicantThixId, 
    String? message
  }) async {
    try {
      final Map<String, dynamic> data = {
        'job_id': jobId,
        'applicant_thix_id': applicantThixId.trim().toUpperCase(),
        'message': message?.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client.from('thix_job_applications').insert(data);
      
      // Note : Assurez-vous que JobApplication a aussi un .fromJson()
      return JobApplication.fromJson(data);
    } catch (e) {
      debugPrint('JobService.submitApplication error: $e');
      throw Exception('Impossible de soumettre la candidature.');
    }
  }

  /// Données de secours sécurisées (n'utilise plus le constructeur directement)
  List<JobPosting> _getFallbackJobs() {
    return [
      JobPosting.fromJson({
        'id': 'job_fallback_001',
        'title': 'Directeur des Opérations',
        'company': 'Kamoto Copper Company',
        'location': 'Kolwezi',
        'status': 'approved',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
    ];
  }
}
