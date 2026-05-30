import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thix_id/models/event_item.dart';
import 'package:thix_id/services/event_service.dart';
import 'package:thix_id/theme.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = EventService(Supabase.instance.client);
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildFeaturedSection(context, service),
                    const SizedBox(height: AppSpacing.xl),
                    _buildCategoriesSection(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildUpcomingEventsSection(context, service),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded, color: Color(0xFF0A2F5C)),
        label: Text("Organiser", style: context.textStyles.labelLarge?.copyWith(color: const Color(0xFF0A2F5C))),
        backgroundColor: LightModeColors.accent,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A3D62), Color(0xFF0F2B4A)],
        ),
        border: const Border(bottom: BorderSide(color: LightModeColors.accent, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              Column(
                children: [
                  Text(
                    "THIX ID",
                    style: context.textStyles.labelSmall?.copyWith(
                      color: LightModeColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "ÉVÉNEMENTS",
                    style: context.textStyles.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: LightModeColors.accent.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: context.theme.colorScheme.primary, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher un forum, sommet...",
                      hintStyle: context.textStyles.bodyMedium?.copyWith(color: LightModeColors.hint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: LightModeColors.accent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.tune_rounded, color: Color(0xFF0A2F5C), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, EventService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "À la une",
              style: context.textStyles.headlineMedium?.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "Voir tout",
                style: context.textStyles.labelMedium?.copyWith(
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        FutureBuilder<List<EventItem>>(
          future: service.getRecommendedEvents(limit: 6), // ✅ remplacé listEvents
          builder: (context, snap) {
            final events = snap.data ?? const <EventItem>[];
            if (snap.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (events.isEmpty) {
              return Container(
                height: 140,
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: context.theme.dividerColor),
                ),
                child: Text(
                  'Aucun événement en vedette pour le moment.',
                  style: context.textStyles.bodyMedium?.copyWith(color: LightModeColors.secondaryText),
                ),
              );
            }
            return FeaturedEventsCarousel(
              events: events,
              onOpen: (e) => context.push('/events/${e.id}'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explorer par catégorie",
          style: context.textStyles.titleMedium?.copyWith(
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChipWidget(label: "Tous", selected: true),
              FilterChipWidget(label: "Conférences", selected: false),
              FilterChipWidget(label: "Formations", selected: false),
              FilterChipWidget(label: "Ateliers", selected: false),
              FilterChipWidget(label: "Networking", selected: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection(BuildContext context, EventService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Prochains Événements",
              style: context.textStyles.titleLarge?.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.theme.dividerColor),
              ),
              child: const Icon(Icons.swap_vert_rounded, color: LightModeColors.secondaryText, size: 20),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        FutureBuilder<List<EventItem>>(
          future: service.getUpcomingEvents(limit: 10), // ✅ remplacé listEvents
          builder: (context, snap) {
            final events = snap.data ?? const [];
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (events.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: Text('Aucun événement pour le moment.', style: context.textStyles.bodyMedium?.copyWith(color: LightModeColors.secondaryText)),
              );
            }

            return Column(
              children: events.map((e) => EventCard(
                title: e.title,
                date: _formatDate(e.eventDate), // ✅ calcul depuis eventDate
                location: e.location,
                price: event.price?.toString() ?? 'Gratuit',
                category: e.category,
                attendees: _formatAttendees(e), // ✅ généré
                imageAssetPath: null, // ou e.imageUrl si disponible
                onOpen: () => context.push('/events/${e.id}'),
              )).toList(growable: false),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAttendees(EventItem event) {
    // Simule un nombre de participants si non disponible
    return '${event.participantCount ?? 0} participants';
  }
}

// Le reste des classes (FilterChipWidget, EventCard, FeaturedEventsCarousel, etc.)
// reste inchangé, sauf si elles utilisent aussi des champs inexistants.
// Je les reproduis ci-dessous pour complétude, mais vous pouvez garder les vôtres.

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;

  const FilterChipWidget({super.key, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: selected ? LightModeColors.accent : context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: selected ? LightModeColors.accent : context.theme.dividerColor,
          width: 1.5,
        ),
        boxShadow: selected
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 3, offset: const Offset(0, 1))]
            : null,
      ),
      child: Text(
        label,
        style: context.textStyles.labelMedium?.copyWith(
          color: context.theme.colorScheme.onSurface,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String price;
  final String category;
  final String attendees;
  final String? imageAssetPath;
  final VoidCallback onOpen;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.price,
    required this.category,
    required this.attendees,
    this.imageAssetPath,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: LightModeColors.accent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onOpen,
            child: SizedBox(
              height: 160,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageAssetPath == null
                        ? Container(color: LightModeColors.hint)
                        : Image.asset(imageAssetPath!, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: LightModeColors.accent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4))],
                      ),
                      child: Text(
                        price,
                        style: context.textStyles.labelMedium?.copyWith(color: const Color(0xFF0A2F5C), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: AppSpacing.md,
                    left: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: LightModeColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        category,
                        style: context.textStyles.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.titleLarge?.copyWith(color: context.theme.colorScheme.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.event_available_rounded, size: 18, color: LightModeColors.accent),
                    const SizedBox(width: AppSpacing.sm),
                    Text(date, style: context.textStyles.bodyMedium?.copyWith(color: LightModeColors.secondaryText)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.business_center_rounded, size: 18, color: LightModeColors.accent),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        location,
                        style: context.textStyles.bodyMedium?.copyWith(color: LightModeColors.secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Divider(color: context.theme.dividerColor),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.groups_rounded, size: 20, color: context.theme.colorScheme.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(attendees, style: context.textStyles.labelLarge?.copyWith(color: context.theme.colorScheme.primary)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: LightModeColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: LightModeColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, size: 14, color: LightModeColors.success),
                          const SizedBox(width: AppSpacing.xs),
                          Text("Vérifié THIX", style: context.textStyles.labelSmall?.copyWith(color: LightModeColors.success)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Voir détails'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedEventsCarousel extends StatefulWidget {
  final List<EventItem> events;
  final ValueChanged<EventItem> onOpen;

  const FeaturedEventsCarousel({super.key, required this.events, required this.onOpen});

  @override
  State<FeaturedEventsCarousel> createState() => _FeaturedEventsCarouselState();
}

class _FeaturedEventsCarouselState extends State<FeaturedEventsCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.events.isEmpty) return;
      final next = (_index + 1) % widget.events.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.events.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final e = widget.events[i];
                return Padding(
                  padding: EdgeInsets.only(right: i == widget.events.length - 1 ? 0 : AppSpacing.md),
                  child: _FeaturedEventCard(event: e, onTap: () => widget.onOpen(e)),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.events.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: active ? 18 : 6,
                decoration: BoxDecoration(
                  color: active ? LightModeColors.accent : context.theme.dividerColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;
  const _FeaturedEventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: LightModeColors.accent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 22, offset: const Offset(0, 10))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (event.imageUrl != null) Image.network(event.imageUrl!, fit: BoxFit.cover) else Container(color: LightModeColors.secondary),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [context.theme.colorScheme.primary, context.theme.colorScheme.primary.withValues(alpha: 0.65), Colors.transparent],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(color: LightModeColors.accent, borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: Text('À LA UNE', style: context.textStyles.labelSmall?.copyWith(color: const Color(0xFF0A2F5C), fontWeight: FontWeight.w900)),
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Text(event.price?.toString() ?? 'Gratuit', style: context.textStyles.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, height: 1.15),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.timer_rounded, size: 18, color: LightModeColors.accent),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _formatDate(event.eventDate),
                          style: context.textStyles.labelLarge?.copyWith(color: LightModeColors.accent, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Icon(Icons.apartment_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          event.location,
                          style: context.textStyles.labelLarge?.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

extension ThemeHelper on BuildContext {
  ThemeData get theme => Theme.of(this);
}
