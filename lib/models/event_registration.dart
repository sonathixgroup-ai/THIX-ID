import 'package:flutter/foundation.dart';

@immutable
class EventRegistration {
  final String id;

  final String userId;
  final String eventId;

  final String ticketCode;
  final String attendeeThixId;

  final int tickets;

  final String status;

  final String? note;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const EventRegistration({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.ticketCode,
    required this.attendeeThixId,
    required this.tickets,
    required this.status,
    required this.createdAt,
    this.note,
    this.updatedAt,
  });

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  bool get isValid => status == 'valid';

  bool get isCancelled => status == 'cancelled';

  bool get isUsed => status == 'used';

  bool get isPending => status == 'pending';

  String get statusLabel {
    switch (status) {
      case 'valid':
        return 'Valide';

      case 'cancelled':
        return 'Annulé';

      case 'used':
        return 'Utilisé';

      case 'pending':
        return 'En attente';

      default:
        return status;
    }
  }

  // ===========================================================================
  // JSON
  // ===========================================================================

  factory EventRegistration.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventRegistration(
      id: json['id']?.toString() ?? '',

      userId:
          json['user_id']?.toString() ?? '',

      eventId:
          json['event_id']?.toString() ?? '',

      ticketCode:
          json['ticket_code']?.toString() ?? '',

      attendeeThixId:
          json['attendee_thix_id']
                  ?.toString() ??
              '',

      tickets:
          (json['tickets'] ?? 1) as int,

      status:
          json['status']?.toString() ??
              'valid',

      note: json['note']?.toString(),

      createdAt: DateTime.parse(
        json['created_at']
                ?.toString() ??
            DateTime.now()
                .toIso8601String(),
      ),

      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(
                  json['updated_at']
                      .toString(),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'ticket_code': ticketCode,
      'attendee_thix_id': attendeeThixId,
      'tickets': tickets,
      'status': status,
      'note': note,
      'created_at':
          createdAt.toIso8601String(),
      'updated_at':
          updatedAt?.toIso8601String(),
    };
  }

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  EventRegistration copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? ticketCode,
    String? attendeeThixId,
    int? tickets,
    String? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventRegistration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      ticketCode:
          ticketCode ?? this.ticketCode,
      attendeeThixId:
          attendeeThixId ??
              this.attendeeThixId,
      tickets: tickets ?? this.tickets,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return '''
EventRegistration(
  id: $id,
  eventId: $eventId,
  userId: $userId,
  ticketCode: $ticketCode,
  tickets: $tickets,
  status: $status
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EventRegistration &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
