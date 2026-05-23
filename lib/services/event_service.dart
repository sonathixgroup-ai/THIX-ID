import 'dart:convert';

class EventItem {
  final String id;
  final String title;
  final String dateLabel;
  final DateTime startsAt;
  final String location;
  final String price;
  final String category;
  final String attendeesLabel;
  final String description;
  final List<String> highlights;
  final String imageAssetPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final String status;

  EventItem({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.startsAt,
    required this.location,
    required this.price,
    required this.category,
    required this.attendeesLabel,
    required this.description,
    required this.highlights,
    required this.imageAssetPath,
    required this.createdAt,
    required this.updatedAt,
    this.userId = 'system',
    this.status = 'active',
  });

  // Convertit l'objet en Map pour l'enregistrement JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateLabel': dateLabel,
        'startsAt': startsAt.toIso8601String(),
        'location': location,
        'price': price,
        'category': category,
        'attendeesLabel': attendeesLabel,
        'description': description,
        'highlights': highlights,
        'imageAssetPath': imageAssetPath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'userId': userId,
        'status': status,
      };

  // Crée un objet depuis une Map
  factory EventItem.fromJson(Map<String, dynamic> json) => EventItem(
        id: json['id'],
        title: json['title'],
        dateLabel: json['dateLabel'],
        startsAt: DateTime.parse(json['startsAt']),
        location: json['location'],
        price: json['price'],
        category: json['category'],
        attendeesLabel: json['attendeesLabel'],
        description: json['description'],
        highlights: List<String>.from(json['highlights']),
        imageAssetPath: json['imageAssetPath'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        userId: json['userId'] ?? 'system',
        status: json['status'] ?? 'active',
      );

  // Méthodes statiques pour gérer la liste (utilisées par ton EventService)
  static String encodeList(List<EventItem> list) =>
      json.encode(list.map((e) => e.toJson()).toList());

  static List<EventItem> decodeList(String raw) {
    if (raw.isEmpty) return [];
    final list = json.decode(raw) as List;
    return list.map((e) => EventItem.fromJson(e)).toList();
  }
}
