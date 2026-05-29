  List<JobPosting> _mapRows(List<Map<String, dynamic>> rows) {
    final now = DateTime.now();

    return rows.map((r) {
      return JobPosting(
        // Utilisation de ?? pour fournir les valeurs obligatoires exigées par votre constructeur
        id: (r['id'] ?? _id('job')).toString(),
        recruiterUserId: r['recruiter_user_id']?.toString(),
        companyId: r['company_id']?.toString(),
        title: (r['title'] ?? '—').toString(),
        company: (r['company'] ?? '').toString(),
        companyLogoUrl: r['company_logo_url']?.toString(),
        isVerifiedEmployer: (r['is_verified_employer'] ?? false) as bool,
        location: (r['location'] ?? '').toString(),
        salary: (r['salary'] ?? '—').toString(),
        salaryMin: r['salary_min'] as int?,
        salaryMax: r['salary_max'] as int?,
        salaryCurrency: r['salary_currency']?.toString(),
        type: (r['type'] ?? 'Offre').toString(),
        workMode: r['work_mode']?.toString(),
        category: r['category']?.toString(),
        industry: r['industry']?.toString(),
        experienceLevel: r['experience_level']?.toString(),
        description: (r['description'] ?? '').toString(),
        requirements: (r['requirements'] is List) ? List<String>.from(r['requirements']) : [],
        skills: (r['skills'] is List) ? List<String>.from(r['skills']) : [],
        responsibilities: (r['responsibilities'] is List) ? List<String>.from(r['responsibilities']) : [],
        benefits: (r['benefits'] is List) ? List<String>.from(r['benefits']) : [],
        deadline: r['deadline'] != null ? DateTime.tryParse(r['deadline'].toString()) : null,
        status: (r['status'] ?? 'approved').toString(),
        applicantsCount: (r['applicants_count'] ?? 0) as int?,
        isFeatured: (r['is_featured'] ?? false) as bool,
        isSuggested: (r['is_suggested'] ?? false) as bool,
        createdAt: DateTime.tryParse(r['created_at']?.toString() ?? '') ?? now,
        updatedAt: DateTime.tryParse(r['updated_at']?.toString() ?? '') ?? now,
      );
    }).toList();
  }
