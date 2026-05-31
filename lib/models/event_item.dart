import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle robuste pour les événements.
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
  final String? coverImageBucket;
  final String? coverImagePath;

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
    this.coverImageBucket,
    this.coverImagePath,
  });

  // ==========================================================================
  // GETTERS DE COMPATIBILITÉ (Pour résoudre vos erreurs "undefined_getter")
  // ==========================================================================
  
  // Ces getters font le pont entre votre ancienne nomenclature et les nouveaux champs
  DateTime get eventDate => startsAt;
  String get venue => location;
  num get priceAmount => price ?? 0;
  
  // Générateur sécurisé d'URL d'image
  String? get coverImageUrl {
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
      coverImageBucket: json['cover_image_bucket']?.toString(),
      coverImagePath: json['cover_image_path']?.toString(),
    );
  }
}
