class MediaContent {
  final String id;
  final String title;
  final String? subtitle;
  final String type;
  final String? year;
  final String coverUrl;
  final String videoUrl;
  final int viewCount;
  final int? rankPosition;
  final bool isTrending;
  final bool isNewRelease;
  final bool isRecommended;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaContent({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    this.year,
    required this.coverUrl,
    required this.videoUrl,
    this.viewCount = 0,
    this.rankPosition,
    this.isTrending = false,
    this.isNewRelease = false,
    this.isRecommended = false,
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MediaContent.fromJson(Map<String, dynamic> json) {
    return MediaContent(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      type: json['type'] ?? '',
      year: json['year'],
      coverUrl: json['cover_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      viewCount: json['view_count'] ?? 0,
      rankPosition: json['rank_position'],
      isTrending: json['is_trending'] ?? false,
      isNewRelease: json['is_new_release'] ?? false,
      isRecommended: json['is_recommended'] ?? false,
      isPublished: json['is_published'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'type': type,
        'year': year,
        'cover_url': coverUrl,
        'video_url': videoUrl,
        'view_count': viewCount,
        'rank_position': rankPosition,
        'is_trending': isTrending,
        'is_new_release': isNewRelease,
        'is_recommended': isRecommended,
        'is_published': isPublished,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  String get rankDisplay => rankPosition != null ? '#$rankPosition' : '';
}
