import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thix_id/models/event_item.dart';
import 'package:thix_id/models/event_registration.dart';

class EventService {
  static const _kEvents = 'thix_events_v1';
  static const _kRegistrations = 'thix_event_registrations_v1';

  Future<List<EventItem>> listEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kEvents);
      if (raw == null || raw.trim().isEmpty) {
        final seeded = _seedEvents();
        await prefs.setString(_kEvents, EventItem.encodeList(seeded));
        return seeded;
      }
      final items = EventItem.decodeList(raw);
      if (items.isEmpty) {
        final seeded = _seedEvents();
        await prefs.setString(_kEvents, EventItem.encodeList(seeded));
        return seeded;
      }
      return items;
    } catch (e) {
      debugPrint('EventService.listEvents failed err=$e');
      return _seedEvents();
    }
  }

  Future<EventItem?> fetchEvent(String eventId) async {
    final id = eventId.trim();
    if (id.isEmpty) return null;
    final all = await listEvents();
    for (final e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<EventRegistration> register({
    required String eventId,
    required String attendeeThixId,
    required int tickets,
    String? note,
  }) async {
    final now = DateTime.now();
    final reg = EventRegistration(
      id: _id('reg'),
      eventId: eventId,
      attendeeThixId: attendeeThixId.trim().toUpperCase(),
      tickets: tickets <= 0 ? 1 : tickets,
      ticketCode: _ticketCode(eventId: eventId, attendeeThixId: attendeeThixId),
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRegistrations);
      final list = (raw == null || raw.trim().isEmpty) ? <EventRegistration>[] : EventRegistration.decodeList(raw).toList(growable: true);
      list.insert(0, reg);
      await prefs.setString(_kRegistrations, EventRegistration.encodeList(list));
    } catch (e) {
      debugPrint('EventService.register failed (local write) err=$e');
    }
    return reg;
  }

  Future<EventRegistration?> fetchRegistrationById(String registrationId) async {
    final id = registrationId.trim();
    if (id.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRegistrations);
      if (raw == null || raw.trim().isEmpty) return null;
      final list = EventRegistration.decodeList(raw);
      for (final r in list) {
        if (r.id == id) return r;
      }
      return null;
    } catch (e) {
      debugPrint('EventService.fetchRegistrationById failed err=$e');
      return null;
    }
  }

  String _ticketCode({required String eventId, required String attendeeThixId}) {
    // Lisible, scannable et unique (best-effort) sans dépendance externe.
    // Exemple: THIXT-EVT-9F3A2C7B4D
    final rnd = Random.secure();
    final token = List.generate(10, (_) => rnd.nextInt(16).toRadixString(16)).join().toUpperCase();
    final evt = eventId.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    final evtShort = evt.length <= 6 ? evt : evt.substring(0, 6);
    return 'THIXT-$evtShort-$token';
  }

  String _id(String prefix) {
    final rnd = Random.secure();
    final n = List.generate(10, (_) => rnd.nextInt(16).toRadixString(16)).join();
    return '${prefix}_$n';
  }

  List<EventItem> _seedEvents() {
    final now = DateTime.now();
    DateTime d(int days, int hour) => DateTime(now.year, now.month, now.day).add(Duration(days: days, hours: hour));
    return [
      EventItem(
        id: 'evt_ai_masterclass',
        title: 'Masterclass Intelligence Artificielle',
        dateLabel: '15 Oct 2024 • 10:00',
        startsAt: d(2, 10),
        location: 'Silikin Village, Kinshasa',
        price: 'Gratuit',
        category: 'Formation',
        attendeesLabel: '120 inscrits',
        description:
            'Session intensive (niveau pro) : LLMs, gouvernance, sécurité des données et mise en production. Accès prioritaire aux profils THIX vérifiés.',
        highlights: const ['Ateliers pratiques', 'Accès replay', 'Certificat de participation'],
        imageAssetPath: 'assets/images/African_businessman_in_suit_grayscale_1775573970767.jpg',
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      EventItem(
        id: 'evt_entrepreneurs_gala',
        title: 'Gala des Entrepreneurs THIX',
        dateLabel: '20 Oct 2024 • 19:00',
        startsAt: d(7, 19),
        location: 'Pullman Grand Hotel',
        price: '50 USD',
        category: 'Networking',
        attendeesLabel: '45 places restantes',
        description:
            'Soirée premium: networking sécurisé, matching pro, tables thématiques. Contrôle d’accès THIX ID à l’entrée (anti-fraude + liste blanche).',
        highlights: const ['Networking premium', 'Invités institutionnels', 'Badges THIX'],
        imageAssetPath: 'assets/images/Senior_professional_man_grayscale_1775573975687.jpg',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      EventItem(
        id: 'evt_design_thinking',
        title: 'Atelier Design Thinking',
        dateLabel: '22 Oct 2024 • 09:00',
        startsAt: d(9, 9),
        location: 'En ligne (Zoom)',
        price: '10 USD',
        category: 'Atelier',
        attendeesLabel: '300 inscrits',
        description:
            'Atelier structuré: idéation, prototypage, validation, pitch. Un THIX ID valide est requis pour recevoir le lien sécurisé.',
        highlights: const ['Templates fournis', 'Exercices en groupe', 'Accès ressources'],
        imageAssetPath: 'assets/images/tech_conference_stage_audience_grayscale_1778649599691.jpg',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      EventItem(
        id: 'evt_mines_energy_forum',
        title: 'Forum Mines & Énergie',
        dateLabel: '05 Nov 2024 • 08:30',
        startsAt: d(23, 8),
        location: "L'Hôtel Fleuve Congo",
        price: '100 USD',
        category: 'Conférence',
        attendeesLabel: 'Sold Out',
        description:
            'Forum stratégique: supply chain, cybersécurité industrielle, conformité, ESG. Accréditations THIX requises pour les zones restreintes.',
        highlights: const ['Conférences', 'Panels', 'Accréditations'],
        imageAssetPath: 'assets/images/Office_team_grayscale_1775574009745.jpg',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
