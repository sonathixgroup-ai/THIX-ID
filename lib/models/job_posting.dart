import 'dart:convert';

class JobPosting {
  final String id;
  final String? recruiterUserId;
  final String? companyId;
  final String title;
  final String company;
  final String? companyLogoUrl;
  final bool isVerifiedEmployer;
  final String location;
  final String salary;
  final int? salaryMin;
  final int? salaryMax;
  final String? salaryCurrency;
  final String type;
  final String? workMode;
  final String? category;
  final String? industry;
  final String? experienceLevel;
  final String description;
  final List<String> requirements;
  final List<String> skills;
  final List<String> responsibilities;
  final List<String> benefits;
  final DateTime? deadline;
  final String? status;
  final int? applicantsCount;
  final bool isFeatured;
  final bool isSuggested;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JobPosting({
    required this.id,
    this.recruiterUserId,
    this.companyId,
    required this.title,
    required this.company,
    this.companyLogoUrl,
    this.isVerifiedEmployer = false,
    required this.location,
    required this.salary,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,
    required this.type,
    this.workMode,
    this.category,
    this.industry,
    this.experienceLevel,
    required this.description,
    required this.requirements,
    required this.skills,
    required this.responsibilities,
    required this.benefits,
    this.deadline,
    this.status,
    this.applicantsCount = 0,
    this.isFeatured = false,
    this.isSuggested = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // CETTE MÉTHODE RÉSOUT TOUTES VOS ERREURS
  static JobPosting fromSupabase(Map<String, dynamic> r) {
    return JobPosting(
      id: (r['id'] ?? '').toString(),
      recruiterUserId: r['recruiter_user_id']?.toString(),
      companyId: r['company_id']?.toString(),
      title: (r['title'] ?? 'Sans titre').toString(),
      company: (r['company'] ?? 'Entreprise').toString(),
      companyLogoUrl: r['company_logo_url']?.toString(),
      isVerifiedEmployer: r['is_verified_employer'] == true,
      location: (r['location'] ?? 'Non spécifié').toString(),
      salary: (r['salary'] ?? 'À négocier').toString(),
      salaryMin: r['salary_min'] as int?,
      salaryMax: r['salary_max'] as int?,
      salaryCurrency: r['salary_currency']?.toString(),
      type: (r['type'] ?? 'Offre').toString(),
      workMode: r['work_mode']?.toString(),
      category: r['category']?.toString(),
      industry: r['industry']?.toString(),
      experienceLevel: r['experience_level']?.toString(),
      description: (r['description'] ?? '').toString(),
      requirements: (r['requirements'] as List?)?.map((e) => e.toString()).toList() ?? [],
      skills: (r['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      responsibilities: (r['responsibilities'] as List?)?.map((e) => e.toString()).toList() ?? [],
      benefits: (r['benefits'] as List?)?.map((e) => e.toString()).toList() ?? [],
      deadline: r['deadline'] != null ? DateTime.tryParse(r['deadline'].toString()) : null,
      status: r['status']?.toString(),
      applicantsCount: (r['applicants_count'] ?? 0) as int?,
      isFeatured: r['is_featured'] == true,
      isSuggested: r['is_suggested'] == true,
      createdAt: DateTime.tryParse(r['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(r['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
