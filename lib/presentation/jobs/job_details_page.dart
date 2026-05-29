import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thix_id/nav.dart';
import 'package:thix_id/services/job_service.dart';
import 'package:thix_id/theme.dart';

class JobDetailsPage extends StatefulWidget {
  final String jobId;
  final bool applied;
  const JobDetailsPage({super.key, required this.jobId, this.applied = false});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final _service = JobService();
  Set<String> _saved = const {};

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final s = await _service.getSavedJobIdsRemote();
    if (!mounted) return;
    setState(() => _saved = s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? InstitutionalColors.civicBlueSoft : InstitutionalColors.civicBlue;
    final divider = isDark ? Colors.white.withOpacity(0.10) : LightModeColors.divider;

    return Scaffold(
      backgroundColor: isDark ? DarkModeColors.cyberDarkBlue : LightModeColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            _ThixInfoBackground(isDark: isDark),
            FutureBuilder(
              future: _service.fetchJob(widget.jobId),
              builder: (context, snap) {
                final job = snap.data;
                if (snap.connectionState != ConnectionState.done) return Center(child: CircularProgressIndicator(color: accent));
                if (job == null) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        _TopBar(title: 'Détails', accent: accent),
                        const SizedBox(height: AppSpacing.xl),
                        Text('Offre introuvable.', style: context.textStyles.titleMedium?.copyWith(color: cs.onSurface)),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => context.popOrGo(AppRoutes.jobs),
                            child: const Text('Retour'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final isSaved = _saved.contains(job.id);

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TopBar(title: 'Détails', accent: accent),
                            if (widget.applied) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  color: DarkModeColors.success.withOpacity(0.14),
                                  border: Border.all(color: DarkModeColors.success.withOpacity(0.35)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: DarkModeColors.success),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        'Candidature envoyée.',
                                        style: context.textStyles.bodyMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            if ((job.companyLogoUrl ?? '').trim().startsWith('http')) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                child: AspectRatio(
                                  aspectRatio: 16 / 7,
                                  child: Image.network(
                                    job.companyLogoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(color: Colors.grey.withOpacity(0.2), child: const Icon(Icons.business)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: cs.surface.withOpacity(isDark ? 0.55 : 0.92),
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                border: Border.all(color: divider),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(job.title, style: context.textStyles.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: cs.onSurface)),
                                  Text(job.company, style: context.textStyles.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.70), fontWeight: FontWeight.w700)),
                                  const SizedBox(height: AppSpacing.md),
                                  Wrap(
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.sm,
                                    children: [
                                      _InfoPill(icon: Icons.location_on_rounded, label: job.location, divider: divider, accent: accent),
                                      _InfoPill(icon: Icons.payments_rounded, label: job.salary, divider: divider, accent: accent),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text('Description', style: context.textStyles.titleMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(job.description, style: context.textStyles.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.74), height: 1.55)),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => context.push('/jobs/${job.id}/apply'),
                                    icon: const Icon(Icons.bolt_rounded),
                                    label: const Text('Postuler'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () async {
                                    await _service.toggleSavedRemote(jobId: job.id, save: !isSaved);
                                    await _loadSaved();
                                  },
                                  icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, color: accent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final Color accent;
  const _TopBar({required this.title, required this.accent});
  @override
  Widget build(BuildContext context) => Row(children: [IconButton(onPressed: () => context.popOrGo(AppRoutes.jobs), icon: Icon(Icons.arrow_back_ios_new_rounded, color: accent)), Text(title)]);
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color divider;
  final Color accent;
  const _InfoPill({required this.icon, required this.label, required this.divider, required this.accent});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), border: Border.all(color: divider)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: accent), const SizedBox(width: 4), Text(label)]),
      );
}

class _ThixInfoBackground extends StatelessWidget {
  final bool isDark;
  const _ThixInfoBackground({required this.isDark});
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (isDark ? DarkModeColors.primary : InstitutionalColors.navy).withOpacity(0.98),
              (isDark ? DarkModeColors.cyberDarkBlue : InstitutionalColors.navy2).withOpacity(0.94),
            ],
          ),
        ),
      );
}
