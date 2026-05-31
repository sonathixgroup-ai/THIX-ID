import 'package:supabase_flutter/supabase_flutter.dart';

class EventRegistration {
  final String id;
  final String eventId;
  final String? userId;
  final String attendeeThixId;
  final int tickets; // Utilisé pour la quantité
  final String ticketCode;
  final String status;
  final DateTime? checkedInAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final num? price; // Ajouté pour calculer le prix total

  const EventRegistration({
    required this.id,
    required this.eventId,
    this.userId,
    required this.attendeeThixId,
    required this.tickets,
    required this.ticketCode,
    required this.status,
    this.checkedInAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.price,
  });

  // ==========================================================================
  // GETTERS DE COMPATIBILITÉ (Corrige les erreurs de votre UI)
  // ==========================================================================
  
  int get quantity => tickets;
  String get thixCode => ticketCode;
  String get attendeeName => attendeeThixId;
  
  // Calcul du prix total si le prix est connu
  num get totalPrice => tickets * (price ?? 0);

  // ==========================================================================
  // FABRIQUE
  // ==========================================================================

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      attendeeThixId: json['attendee_thix_id']?.toString() ?? '',
      tickets: (json['tickets'] is num) ? (json['tickets'] as num).toInt() : 1,
      ticketCode: json['ticket_code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'registered',
      checkedInAt: json['checked_in_at'] != null 
          ? DateTime.tryParse(json['checked_in_at'].toString()) 
          : null,
      note: json['note']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      price: json['price'] as num?,
    );
  }
}
