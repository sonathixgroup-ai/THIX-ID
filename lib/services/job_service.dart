import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thix_id/models/job_application.dart';
import 'package:thix_id/models/job_posting.dart';
import 'package:thix_id/supabase/supabase_config.dart';

class JobService {
  static const String table = 'thix_job_offers';
  static const _kJobs = 'thix_jobs_v1';
  static const _kApplications = 'thix_job_applications_v1';

  Future<List<JobPosting>> listJobs() async {
    try {
      final res = await SupabaseService.select(table, select: '*', orderBy: 'created_at', ascending: false, limit: 200);
      final items = _mapRows(res);
      if (items.isNotEmpty) {
        await _cache(items);
        return items;
      }
    } catch (e) {
      debugPrint('JobService.listJobs supabase failed err=$e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kJobs);
      if (raw == null || raw.trim().isEmpty) return _seedJobs();
      final items = JobPosting.decodeList(raw);
      return items.isEmpty ? _seedJobs() : items;
    } catch (e) {
      debugPrint('JobService.listJobs failed err=$e');
      return _seedJobs();
    }
  }

  List<JobPosting> _mapRows(List<Map<String, dynamic>> rows) {
    final now = DateTime.now();
    List<String> listFrom(dynamic data) => (data is List) ? data.map((e) => e.toString()).toList() : [];

    return rows.map((r) {
      return JobPosting(
        id: r['id']?.toString() ?? _id('job'),
        recruiterUserId: r['recruiter_user_id']?.toString(),
        companyId: r['company_id']?.toString(),
        title: r['title']?.toString() ?? '—',
        company: r['company']?.toString() ?? '',
        companyLogoUrl: r['company_logo_url']?.toString(),
        isVerifiedEmployer: r['is_verified_employer'] ?? false,
        location: r['location']?.toString() ?? '',
        salary: r['salary']?.toString() ?? '—',
        salaryMin: r['salary_min'] as int?,
        salaryMax: r['salary_max'] as int?,
        salaryCurrency: r['salary_currency']?.toString(),
        type: r['type']?.toString() ?? 'Offre',
        workMode: r['work_mode']?.toString(),
        category: r['category']?.toString(),
        industry: r['industry']?.toString(),
        experienceLevel: r['experience_level']?.toString(),
        description: r['description']?.toString() ?? '',
        requirements: listFrom(r['requirements']),
        skills: listFrom(r['skills']),
        responsibilities: listFrom(r['responsibilities']),
        benefits: listFrom(r['benefits']),
        deadline: r['deadline'] != null ? DateTime.tryParse(r['deadline'].toString()) : null,
        status: r['status']?.toString() ?? 'approved',
        applicantsCount: r['applicants_count'] as int? ?? 0,
        isFeatured: r['is_featured'] ?? false,
        isSuggested: r['is_suggested'] ?? false,
        createdAt: DateTime.tryParse(r['created_at']?.toString() ?? '') ?? now,
        updatedAt: DateTime.tryParse(r['updated_at']?.toString() ?? '') ?? now,
      );
    }).toList();
  }

  // --- Reste des méthodes inchangées ---

  Future<void> _cache(List<JobPosting> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kJobs, JobPosting.encodeList(items));
    } catch (e) {
      debugPrint('JobService cache failed err=$e');
    }
  }

  Future<JobPosting?> fetchJob(String jobId) async {
    final all = await listJobs();
    return all.firstWhere((j) => j.id == jobId, orElse: () => null as dynamic);
  }

  Future<JobApplication> submitApplication({required String jobId, required String applicantThixId, String? message}) async {
    final now = DateTime.now();
    final app = JobApplication(id: _id('apply'), jobId: jobId, applicantThixId: applicantThixId.trim().toUpperCase(), message: message?.trim(), createdAt: now, updatedAt: now);
    // (Logique de sauvegarde locale ici)
    return app;
  }

  String _id(String prefix) => '${prefix}_${List.generate(10, (_) => Random.secure().nextInt(16).toRadixString(16)).join()}';

  List<JobPosting> _seedJobs() {
    final now = DateTime.now();
    // Créez un exemple complet ici en remplissant les 29 champs requis
    return [
      JobPosting(
        id: 'job_ops_director', recruiterUserId: null, companyId: null, title: 'Directeur des Opérations', company: 'Kamoto Copper Company',
        companyLogoUrl: null, isVerifiedEmployer: true, location: 'Kolwezi', salary: '$5,500 - $8,000', salaryMin: 5500, salaryMax: 8000,
        salaryCurrency: 'USD', type: 'Premium Gold', workMode: 'On-site', category: 'Mining', industry: 'Industrial', experienceLevel: 'Senior',
        description: 'Pilotez l’exécution...', requirements: ['10+ ans...'], skills: ['Management'], responsibilities: ['Reporting'], 
        benefits: ['Assurance'], deadline: null, status: 'approved', applicantsCount: 0, isFeatured: true, isSuggested: false, 
        createdAt: now, updatedAt: now
      ),
    ];
  }
}
