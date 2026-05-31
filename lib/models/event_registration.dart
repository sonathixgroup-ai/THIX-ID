import 'dart:convert';

/// Modèle représentant une inscription à un événement.
class EventRegistration {
  final String id;
  final String eventId;
  final String? userId;
  final String attendeeThixId;
  final int tickets;
  final String ticketCode;
  final String status;
  final DateTime? checkedInAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

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
  });

  // ==========================================================================
  // GETTERS DE COMPATIBILITÉ (pour éviter les erreurs UI)
  // ==========================================================================

  int get quantity => tickets;
  String get attendeeName => attendeeThixId;
  String get currency => 'USD';
  String get thixCode => ticketCode;
  bool get isCheckedIn => status == 'checked_in';
  bool get isCancelled => status == 'cancelled';

  // ==========================================================================
  // FABRIQUE (JSON -> Objet)
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
    );
  }

  // ==========================================================================
  // SÉRIALISATION (Objet -> JSON)
  // ==========================================================================

  Map<String, dynamic> toJson() => {
    'id': id,
    'event_id': eventId,
    'user_id': userId,
    'attendee_thix_id': attendeeThixId,
    'tickets': tickets,
    'ticket_code': ticketCode,
    'status': status,
    'checked_in_at': checkedInAt?.toIso8601String(),
    'note': note,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
