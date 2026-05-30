import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ← ajout
import 'package:thix_id/nav.dart';
import 'package:thix_id/services/event_service.dart';
import 'package:thix_id/theme.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  final bool registered;
  const EventDetailsPage({super.key, required this.eventId, this.registered = false});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late final EventService _service;

  @override
  void initState() {
    super.initState();
    _service = EventService(Supabase.instance.client); // ← correction ligne 17
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder(
          future: _service.getEventById(widget.eventId),
          builder: (context, snap) {
            final event = snap.data;
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (event == null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _TopBar(eventId: widget.eventId),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Événement introuvable.',
                        style: context.textStyles.titleMedium
                            ?.copyWith(color: context.theme.colorScheme.onSurface)),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.popOrGo(AppRoutes.events),
                        child: const Text('Retour'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(eventId: widget.eventId),
                  if (widget.registered) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        color: LightModeColors.success.withValues(alpha: 0.10),
                        border: Border.all(
                            color: LightModeColors.success.withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: LightModeColors.success),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Inscription confirmée. Les infos pratiques seront envoyées au profil THIX ID.',
                              style: context.textStyles.bodyMedium?.copyWith(
                                  color: context.theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                          color: LightModeColors.accent.withValues(alpha: 0.5),
                          width: 1.5),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.theme.colorScheme.primary
                              .withValues(alpha: 0.45),
                          LightModeColors.accent.withValues(alpha: 0.22),
                          context.theme.colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -30,
                          child: Icon(Icons.shield_rounded,
                              size: 160,
                              color:
                                  LightModeColors.accent.withValues(alpha: 0.15)),
                        ),
                        Positioned(
                          left: AppSpacing.lg,
                          bottom: AppSpacing.lg,
                          right: AppSpacing.lg,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                  color: LightModeColors.accent,
                                ),
                                child: Text('THIX VERIFIED',
                                    style: context.textStyles.labelSmall
                                        ?.copyWith(
                                            color: const Color(0xFF0A2F5C),
                                            fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(event.title,
                                  style: context.textStyles.titleLarge
                                      ?.copyWith(
                                          color: context
                                              .theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w900)),
                              const SizedBox(height: AppSpacing.xs),
                              Text(event.category,
                                  style: context.textStyles.labelLarge
                                      ?.copyWith(
                                          color: LightModeColors.secondaryText,
                                          fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _InfoPill(
                          icon: Icons.event_available_rounded,
                          label: event.dateLabel),
                      _InfoPill(
                          icon: Icons.location_on_rounded,
                          label: event.location),
                      _InfoPill(
                          icon: Icons.payments_rounded,
                          label: event.price?.toString() ?? 'Gratuit'), // ← correction ligne 169
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('À propos',
                      style: context.textStyles.titleMedium?.copyWith(
                          color: context.theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(event.description,
                      style: context.textStyles.bodyMedium?.copyWith(
                          color: LightModeColors.secondaryText, height: 1.5)),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Highlights',
                      style: context.textStyles.titleMedium?.copyWith(
                          color: context.theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: AppSpacing.sm),
                  ...event.highlights.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.auto_awesome_rounded,
                                  size: 18, color: LightModeColors.accent),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                                child: Text(h,
                                    style: context.textStyles.bodyMedium
                                        ?.copyWith(
                                            color: LightModeColors.secondaryText,
                                            height: 1.45))),
                          ],
                        ),
                      )),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.push('/events/${event.id}/register'),
                      icon: const Icon(Icons.confirmation_number_rounded),
                      label: const Text('S’inscrire avec THIX ID'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => context.popOrGo(AppRoutes.events),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Retour aux événements'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String eventId;
  const _TopBar({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.popOrGo(AppRoutes.events),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        Expanded(
          child: Text('Détails',
              style: context.textStyles.titleLarge?.copyWith(
                  color: context.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;   // ← nommé
  final String label;    // ← nommé
  const _InfoPill({required this.icon, required this.label}); // ← constructeur correct

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: context.theme.dividerColor),
        color: context.theme.scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(label,
              style: context.textStyles.labelMedium?.copyWith(
                  color: context.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

extension _ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
}
