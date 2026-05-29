import 'dart:convert';

class JobPosting {
  // ... (Gardez tous vos champs `final` ici, sans rien changer) ...
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
    this.salary = 'Non spécifié',
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,
    this.type = 'Offre',
    this.workMode,
    this.category,
    this.industry,
    this.experienceLevel,
    this.description = '',
    this.requirements = const [],
    this.skills = const [],
    this.responsibilities = const [],
    this.benefits = const [],
    this.deadline,
    this.status = 'approved',
    this.applicantsCount = 0,
    this.isFeatured = false,
    this.isSuggested = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // C'EST CETTE MÉTHODE QUI RÉGLE VOS 321 ERREURS
  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: (json['id'] ?? '').toString(),
      recruiterUserId: json['recruiter_user_id']?.toString(),
      companyId: json['company_id']?.toString(),
      title: (json['title'] ?? 'Sans titre').toString(),
      company: (json['company'] ?? 'Entreprise inconnue').toString(),
      companyLogoUrl: json['company_logo_url']?.toString(),
      isVerifiedEmployer: (json['is_verified_employer'] ?? false) == true,
      location: (json['location'] ?? 'Non spécifié').toString(),
      salary: (json['salary'] ?? 'À négocier').toString(),
      salaryMin: json['salary_min'] is int ? json['salary_min'] : null,
      salaryMax: json['salary_max'] is int ? json['salary_max'] : null,
      salaryCurrency: json['salary_currency']?.toString(),
      type: (json['type'] ?? 'Offre').toString(),
      workMode: json['work_mode']?.toString(),
      category: json['category']?.toString(),
      industry: json['industry']?.toString(),
      experienceLevel: json['experience_level']?.toString(),
      description: (json['description'] ?? '').toString(),
      requirements: (json['requirements'] as List?)?.map((e) => e.toString()).toList() ?? [],
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      responsibilities: (json['responsibilities'] as List?)?.map((e) => e.toString()).toList() ?? [],
      benefits: (json['benefits'] as List?)?.map((e) => e.toString()).toList() ?? [],
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'].toString()) : null,
      status: (json['status'] ?? 'approved').toString(),
      applicantsCount: json['applicants_count'] is int ? json['applicants_count'] : 0,
      isFeatured: (json['is_featured'] ?? false) == true,
      isSuggested: (json['is_suggested'] ?? false) == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
