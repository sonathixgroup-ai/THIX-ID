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

  final String status;
  final int applicantsCount;

  final bool isFeatured;
  final bool isSuggested;

  final DateTime createdAt;
  final DateTime updatedAt;

  const JobPosting({
    required this.id,

    this.recruiterUserId,
    this.companyId,

    this.title = '',
    this.company = '',
    this.companyLogoUrl,

    this.isVerifiedEmployer = false,

    this.location = '',
    this.salary = '',

    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,

    this.type = '',

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

    this.status = 'active',
    this.applicantsCount = 0,

    this.isFeatured = false,
    this.isSuggested = false,

    required this.createdAt,
    required this.updatedAt,
  });

  factory JobPosting.fromSupabase(Map<String, dynamic> r) {
    return JobPosting(
      id: r['id']?.toString() ?? '',

      recruiterUserId: r['recruiter_user_id']?.toString(),
      companyId: r['company_id']?.toString(),

      title: r['title']?.toString() ?? '',
      company: r['company']?.toString() ?? '',
      companyLogoUrl: r['company_logo_url']?.toString(),

      isVerifiedEmployer: r['is_verified_employer'] ?? false,

      location: r['location']?.toString() ?? '',
      salary: r['salary']?.toString() ?? '',

      salaryMin: r['salary_min'],
      salaryMax: r['salary_max'],
      salaryCurrency: r['salary_currency']?.toString(),

      type: r['type']?.toString() ?? '',

      workMode: r['work_mode']?.toString(),
      category: r['category']?.toString(),
      industry: r['industry']?.toString(),
      experienceLevel: r['experience_level']?.toString(),

      description: r['description']?.toString() ?? '',

      requirements: List<String>.from(r['requirements'] ?? []),
      skills: List<String>.from(r['skills'] ?? []),
      responsibilities: List<String>.from(r['responsibilities'] ?? []),
      benefits: List<String>.from(r['benefits'] ?? []),

      deadline: r['deadline'] != null
          ? DateTime.tryParse(r['deadline'].toString())
          : null,

      status: r['status']?.toString() ?? 'active',

      applicantsCount: r['applicants_count'] ?? 0,

      isFeatured: r['is_featured'] ?? false,
      isSuggested: r['is_suggested'] ?? false,

      createdAt: DateTime.tryParse(
            r['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),

      updatedAt: DateTime.tryParse(
            r['updated_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recruiter_user_id': recruiterUserId,
      'company_id': companyId,
      'title': title,
      'company': company,
      'company_logo_url': companyLogoUrl,
      'is_verified_employer': isVerifiedEmployer,
      'location': location,
      'salary': salary,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salary_currency': salaryCurrency,
      'type': type,
      'work_mode': workMode,
      'category': category,
      'industry': industry,
      'experience_level': experienceLevel,
      'description': description,
      'requirements': requirements,
      'skills': skills,
      'responsibilities': responsibilities,
      'benefits': benefits,
      'deadline': deadline?.toIso8601String(),
      'status': status,
      'applicants_count': applicantsCount,
      'is_featured': isFeatured,
      'is_suggested': isSuggested,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory JobPosting.fromJson(String source) =>
      JobPosting.fromSupabase(jsonDecode(source));
}
