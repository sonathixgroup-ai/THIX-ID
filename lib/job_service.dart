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
    // 1) Supabase first (Admin-created offers)
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
      if (raw == null || raw.trim().isEmpty) {
        final seeded = _seedJobs();
        await prefs.setString(_kJobs, JobPosting.encodeList(seeded));
        return seeded;
      }
      final items = JobPosting.decodeList(raw);
      if (items.isEmpty) {
        final seeded = _seedJobs();
        await prefs.setString(_kJobs, JobPosting.encodeList(seeded));
        return seeded;
      }
      return items;
    } catch (e) {
      debugPrint('JobService.listJobs failed err=$e');
      return _seedJobs();
    }
  }

  List<JobPosting> _mapRows(List<Map<String, dynamic>> rows) {
    final now = DateTime.now();
    DateTime parseDate(dynamic v) {
      if (v == null) return now;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? now;
    }

    String pick(Map<String, dynamic> r, List<String> keys, {String fallback = ''}) {
      for (final k in keys) {
        final v = r[k];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return fallback;
    }

    return rows.map((r) {
      final id = pick(r, const ['id', 'uuid'], fallback: _id('job'));
      final title = pick(r, const ['title', 'position', 'job_title', 'name'], fallback: '—');
      final company = pick(r, const ['company', 'employer', 'organization'], fallback: '');
      final location = pick(r, const ['location', 'city', 'address'], fallback: '');
      final salary = pick(r, const ['salary', 'reward_label', 'compensation'], fallback: '—');
      final type = pick(r, const ['type', 'category', 'contract_type'], fallback: 'Offre');
      final description = pick(r, const ['description', 'content'], fallback: '');
      // Requirements: best-effort array
      final reqRaw = r['requirements'];
      final requirements = (reqRaw is List)
          ? reqRaw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList(growable: false)
          : const <String>[];

      return JobPosting(
        id: id,
        title: title,
        company: company,
        location: location,
        salary: salary,
        type: type,
        description: description,
        requirements: requirements,
        createdAt: parseDate(r['created_at'] ?? r['createdAt']),
        updatedAt: parseDate(r['updated_at'] ?? r['updatedAt']),
      );
    }).toList(growable: false);
  }

  Future<void> _cache(List<JobPosting> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kJobs, JobPosting.encodeList(items));
    } catch (e) {
      debugPrint('JobService cache failed err=$e');
    }
  }

  Future<JobPosting?> fetchJob(String jobId) async {
    final id = jobId.trim();
    if (id.isEmpty) return null;
    final all = await listJobs();
    for (final j in all) {
      if (j.id == id) return j;
    }
    return null;
  }

  Future<JobApplication> submitApplication({
    required String jobId,
    required String applicantThixId,
    String? message,
  }) async {
    final now = DateTime.now();
    final app = JobApplication(
      id: _id('apply'),
      jobId: jobId,
      applicantThixId: applicantThixId.trim().toUpperCase(),
      message: message?.trim().isEmpty ?? true ? null : message!.trim(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kApplications);
      final list = (raw == null || raw.trim().isEmpty) ? <JobApplication>[] : JobApplication.decodeList(raw).toList(growable: true);
      list.insert(0, app);
      await prefs.setString(_kApplications, JobApplication.encodeList(list));
    } catch (e) {
      debugPrint('JobService.submitApplication failed (local write) err=$e');
    }
    return app;
  }

  String _id(String prefix) {
    final rnd = Random.secure();
    final n = List.generate(10, (_) => rnd.nextInt(16).toRadixString(16)).join();
    return '${prefix}_$n';
  }

  List<JobPosting> _seedJobs() {
    final now = DateTime.now();
    return [
      JobPosting(
        id: 'job_ops_director',
        title: 'Directeur des Opérations',
        company: 'Kamoto Copper Company',
        location: 'Kolwezi, Lualaba',
        salary: r'$5,500 - $8,000',
        type: 'Premium Gold',
        description:
            'Pilotez l’exécution opérationnelle d’un site minier stratégique. Collaboration étroite avec la sécurité, la conformité et les équipes terrain. Poste certifié THIX (KYC entreprise + audits).',
        requirements: const [
          '10+ ans en opérations/industrie lourde',
          'Expérience gestion multi-sites',
          'Culture HSE et conformité',
          'Leadership & reporting',
        ],
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      JobPosting(
        id: 'job_cyber_expert',
        title: 'Expert en Cybersécurité',
        company: 'Ministère du Numérique',
        location: 'Kinshasa, Gombe',
        salary: r'$3,200 - $5,000',
        type: 'Gouvernement',
        description:
            'Renforcez la posture cyber nationale: SOC, gestion des vulnérabilités, réponse à incident, politiques et audits. Dossiers sensibles – vérification THIX ID obligatoire.',
        requirements: const [
          'SOC / IR / Threat intel',
          'Sécurité Cloud & IAM',
          'Rédaction de politiques',
          'Capacité de travail en environnement régulé',
        ],
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      JobPosting(
        id: 'job_infra_pm',
        title: 'Chef de Projet Infrastructure',
        company: 'Vodacom RDC',
        location: 'Lubumbashi',
        salary: r'$4,000+',
        type: 'Temps Plein',
        description:
            'Conduisez des programmes d’infrastructure critique (réseaux, data centers edge, résilience). Rigueur, gouvernance et coordination multi-équipes.',
        requirements: const [
          'PMO/Delivery en télécoms ou IT',
          'Gestion risques & dépendances',
          'Pilotage fournisseurs',
        ],
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      JobPosting(
        id: 'job_risk_analyst',
        title: 'Analyste Senior Risques',
        company: 'Rawbank',
        location: 'Kinshasa',
        salary: r'$2,800 - $4,500',
        type: 'Hybride',
        description:
            'Analyse des risques, conformité, scoring et gouvernance. Collaboration avec cybersécurité et fraude. Priorité aux profils certifiés THIX.',
        requirements: const [
          'Banque/finance – risk/compliance',
          'Analyse data & reporting',
          'Gestion incidents fraude',
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
