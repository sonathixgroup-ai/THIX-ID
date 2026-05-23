import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thix_id/models/event_item.dart';
import 'package:thix_id/models/event_registration.dart';
import 'package:thix_id/nav.dart';
import 'package:thix_id/services/event_service.dart';
import 'package:thix_id/theme.dart';

class EventTicketPage extends StatefulWidget {
  final String eventId;
  final String registrationId;

  const EventTicketPage({super.key, required this.eventId, required this.registrationId});

  @override
  State<EventTicketPage> createState() => _EventTicketPageState();
}

class _EventTicketPageState extends State<EventTicketPage> {
  final _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<_TicketBundle?>(
          future: _load(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final bundle = snap.data;
            if (bundle == null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _TicketTopBar(),
                    const Spacer(),
                    Text('Billet introuvable.', style: context.textStyles.titleMedium?.copyWith(color: context.theme.colorScheme.onSurface, fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () => context.popOrGo('/events/${widget.eventId}'),
                      child: const Text('Retour à l’événement'),
                    ),
                    const Spacer(),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TicketTopBar(eventId: widget.eventId),
                  const SizedBox(height: AppSpacing.md),
                  Text('Billet', style: context.textStyles.titleLarge?.copyWith(color: context.theme.colorScheme.onSurface, fontWeight: FontWeight.w900)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Présente ce code à la porte.', style: context.textStyles.bodyMedium?.copyWith(color: LightModeColors.secondaryText, height: 1.5)),
                  const SizedBox(height: AppSpacing.lg),
                  _TicketCard(event: bundle.event, reg: bundle.reg),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/events/${widget.eventId}'),
                          icon: const Icon(Icons.event_rounded),
                          label: const Text('Détails'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // Placeholder: dans une version Supabase complète,
                            // on ferait ici un refresh / validation serveur.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Billet prêt. Montre le code à l’entrée.')),
                            );
                          },
                          icon: const Icon(Icons.verified_rounded),
                          label: const Text('Prêt à scanner'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<_TicketBundle?> _load() async {
    try {
      final event = await _eventService.fetchEvent(widget.eventId);
      final reg = await _eventService.fetchRegistrationById(widget.registrationId);
      if (event == null || reg == null) return null;
      if (reg.eventId != event.id) return null;
      return _TicketBundle(event: event, reg: reg);
    } catch (e) {
      debugPrint('EventTicketPage._load failed err=$e');
      return null;
    }
  }
}

class _TicketTopBar extends StatelessWidget {
  final String? eventId;
  const _TicketTopBar({this.eventId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.popOrGo(eventId == null ? AppRoutes.events : '/events/$eventId'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        Expanded(
          child: Text('THIX Ticket', style: context.textStyles.titleLarge?.copyWith(color: context.theme.colorScheme.onSurface, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final EventItem event;
  final EventRegistration reg;
  const _TicketCard({required this.event, required this.reg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: LightModeColors.accent.withValues(alpha: 0.50), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: LightModeColors.success),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(event.title, style: context.textStyles.titleMedium?.copyWith(color: context.theme.colorScheme.onSurface, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('${event.dateLabel} • ${event.location}', style: context.textStyles.bodyMedium?.copyWith(color: LightModeColors.secondaryText, height: 1.5)),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: reg.ticketCode,
                    drawText: false,
                    width: 520,
                    height: 96,
                    color: context.theme.colorScheme.onSurface,
                    errorBuilder: (context, error) => Text('Barcode error: $error', style: context.textStyles.bodySmall?.copyWith(color: context.theme.colorScheme.error)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SelectableText(
                  reg.ticketCode,
                  textAlign: TextAlign.center,
                  style: context.textStyles.titleSmall?.copyWith(color: context.theme.colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _TicketMetaRow(label: 'THIX ID', value: reg.attendeeThixId),
          const SizedBox(height: AppSpacing.sm),
          _TicketMetaRow(label: 'Billets', value: reg.tickets.toString()),
          if (reg.note != null && reg.note!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _TicketMetaRow(label: 'Note', value: reg.note!),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  color: LightModeColors.success.withValues(alpha: 0.12),
                  border: Border.all(color: LightModeColors.success.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: LightModeColors.success),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Valide', style: context.textStyles.labelLarge?.copyWith(color: context.theme.colorScheme.onSurface, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const Spacer(),
              Text('ID: ${reg.id}', style: context.textStyles.labelSmall?.copyWith(color: LightModeColors.secondaryText)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketMetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _TicketMetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(label, style: context.textStyles.labelLarge?.copyWith(color: LightModeColors.secondaryText, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: SelectableText(value, style: context.textStyles.bodyMedium?.copyWith(color: context.theme.colorScheme.onSurface, height: 1.4)),
        ),
      ],
    );
  }
}

class _TicketBundle {
  final EventItem event;
  final EventRegistration reg;
  const _TicketBundle({required this.event, required this.reg});
}

extension _ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
}
