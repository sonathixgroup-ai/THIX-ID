
import 'package:flutter/foundation.dart';

class EventItem {
  final String id;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final DateTime? eventDate;
  final String? venue;
  final double? priceAmount;
  final bool isRecommended;

  EventItem({
    required this.id,
    required this.title,
    this.description,
    this.coverImageUrl,
    this.eventDate,
    this.venue,
    this.priceAmount,
    this.isRecommended = false,
  });

  // Cette méthode est cruciale : elle convertit les données JSON de Supabase en objet Dart
  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Sans titre',
      description: json['description'],
      // Ajustez les clés ('cover_image_url') selon les noms exacts de vos colonnes Supabase
      coverImageUrl: json['cover_image_url'] ?? json['image_url'], 
      eventDate: json['event_date'] != null 
          ? DateTime.tryParse(json['event_date'].toString()) 
          : null,
      venue: json['venue'],
      priceAmount: (json['price_amount'] as num?)?.toDouble() ?? 0.0,
      isRecommended: json['is_recommended'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'event_date': eventDate?.toIso8601String(),
      'venue': venue,
      'price_amount': priceAmount,
      'is_recommended': isRecommended,
    };
  }
}
