import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle représentant un événement.
/// Utilise des types stricts et des getters sécurisés pour éviter les erreurs UI.
class EventItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final DateTime startsAt;
  final DateTime? endsAt;
  final bool isFree;
  final num? price;
  final String currency;
  final String eventType;
  final String? meetingLink;
  final String? coverImageBucket;
  final String? coverImagePath;
  final List<String> highlights;
  final bool isFeatured;
  final String status;
  final DateTime createdAt;

  // Champs de compatibilité / UI
  final int? participantCount;
  final String? registrationStatus;

  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.startsAt,
    this.endsAt,
    this.isFree = true,
    this.price,
    this.currency = 'USD',
    required this.eventType,
    this.meetingLink,
    this.coverImageBucket,
    this.coverImagePath,
    required this.highlights,
    this.isFeatured = false,
    this.status = 'published',
    required this.createdAt,
    this.participantCount,
    this.registrationStatus,
  });

  // ==========================================================================
  // GETTERS DE COMPATIBILITÉ (Pour résoudre les erreurs UI)
  // ==========================================================================
  
  DateTime get eventDate => startsAt;
  
  String get venue => location;
  
  num get priceAmount => price ?? 0;

  /// Étiquette de date pour l'affichage (ex: "12/04/2025 • 14:30")
  String get dateLabel {
    final d = startsAt.toLocal();
    final twoDigits = (int v) => v.toString().padLeft(2, '0');
    return '${twoDigits(d.day)}/${twoDigits(d.month)}/${d.year} • ${twoDigits(d.hour)}:${twoDigits(d.minute)}';
  }

  /// Étiquette de prix pour l'affichage (ex: "Gratuit" ou "50 USD")
  String get priceLabel => isFree ? 'Gratuit' : (price != null ? '$price $currency' : '');

  /// URL dynamique de l'image de couverture (Supabase Storage)
  String? get imageUrl {
    if (coverImageBucket == null || coverImagePath == null) return null;
    final supabaseUrl = Supabase.instance.client.supabaseUrl;
    return '$supabaseUrl/storage/v1/object/public/$coverImageBucket/$coverImagePath';
  }

  // ==========================================================================
  // FABRIQUE (JSON -> Objet)
  // ==========================================================================

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Sans titre',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Non précisé',
      category: json['category']?.toString() ?? 'Général',
      startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? '') ?? DateTime.now(),
      endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'].toString()) : null,
      isFree: json['is_free'] ?? true,
      price: json['price'] as num?,
      currency: json['currency']?.toString() ?? 'USD',
      eventType: json['event_type']?.toString() ?? 'online',
      meetingLink: json['meeting_link']?.toString(),
      coverImageBucket: json['cover_image_bucket']?.toString(),
      coverImagePath: json['cover_image_path']?.toString(),
      highlights: (json['highlights'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isFeatured: json['is_featured'] ?? false,
      status: json['status']?.toString() ?? 'published',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      participantCount: json['participant_count'] as int?,
      registrationStatus: json['registration_status']?.toString(),
    );
  }

  // ==========================================================================
  // SÉRIALISATION (Objet -> JSON)
  // ==========================================================================

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'location': location,
    'category': category,
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt?.toIso8601String(),
    'is_free': isFree,
    'price': price,
    'currency': currency,
    'event_type': eventType,
    'meeting_link': meetingLink,
    'cover_image_bucket': coverImageBucket,
    'cover_image_path': coverImagePath,
    'highlights': highlights,
    'is_featured': isFeatured,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'participant_count': participantCount,
    'registration_status': registrationStatus,
  };
}
