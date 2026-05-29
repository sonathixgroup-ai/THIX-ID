import 'dart:convert';

class JobPosting {
  // Vos champs...
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String description;
  final List<String> requirements;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JobPosting({
    required this.id,
    this.title = '—',
    this.company = '',
    this.location = '',
    this.salary = '—',
    this.type = 'Offre',
    this.description = '',
    this.requirements = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Cette usine gère les champs manquants sans erreur
  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: json['id']?.toString() ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? '—',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '—',
      type: json['type'] ?? 'Offre',
      description: json['description'] ?? '',
      requirements: (json['requirements'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static List<JobPosting> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.map((m) => JobPosting.fromJson(m)).toList();
  }

  static String encodeList(List<JobPosting> items) => 
      jsonEncode(items.map((e) => e.toJson()).toList());

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'company': company, 'location': location,
    'salary': salary, 'type': type, 'description': description,
    'requirements': requirements, 'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
