import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/nav.dart';
import 'package:thix_id/services/job_service.dart';
import 'package:thix_id/theme.dart';

class JobDashboardPage extends StatefulWidget {
  const JobDashboardPage({super.key});

  @override
  State<JobDashboardPage> createState() => _JobDashboardPageState();
}

class _JobDashboardPageState extends State<JobDashboardPage> {
  final _service = JobService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _apps = const [];
  Set<String> _saved = const {};
  List<Map<String, dynamic>> _aiRecs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final saved = await _service.getSavedJobIdsRemote();
      final appsRemote = await _service.listMyApplicationsRemote();
      final appsLocal = await _service.listLocalApplications();
      final merged = <Map<String, dynamic>>[
        ...appsRemote,
        ...appsLocal.map((e) => e.toJson()),
      ];
      final jobs = await _service.listJobs();
      final auth = context.read<AuthController>();
      final me = auth.currentUser;
      final profile = {
        'user_id': me?.id,
        'thix_id': me?.thixId,
        'account_type': me?.accountType.name,
        'registration_status': me?.registrationStatus,
        'skills': me?.skills ?? const [],
        'languages': me?.languages ?? const [],
      };
      final ai = await _service.aiRecommendJobs(userProfile: profile, jobs: jobs, limit: 8) ?? [];
      if (!mounted) return;
      setState(() {
        _saved = saved;
        _apps = merged;
        _aiRecs = ai;
      });
    } catch (e) {
      debugPrint('JobDashboardPage.load failed err=$e');
      if (mounted) setState(() => _error = 'Erreur de chargement.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LearningCyberColors.bg0,
      body: SafeArea(
        child: Stack(
          children: [
            const _JobsBackground(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.popOrGo(AppRoutes.jobs),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LearningCyberColors.text),
                      ),
                      Expanded(
                        child: Text('Dashboard Emploi', style: context.textStyles.titleLarge?.copyWith(color: LearningCyberColors.text, fontWeight: FontWeight.w900)),
                      ),
                      IconButton(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh_rounded, color: LearningCyberColors.neonCyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_loading)
                    const Expanded(child: Center(child: CircularProgressIndicator(color: LearningCyberColors.neonCyan)))
                  else if (_error != null)
                    Expanded(child: Center(child: Text(_error!, style: context.textStyles.bodyLarge?.copyWith(color: LearningCyberColors.textDim))))
                  else
                    Expanded(
                      child: ListView(
                        children: [
                          _GlassPanel(
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: LearningCyberColors.success),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: Text('Suivi candidatures, sauvegardes et recommandations AI', style: context.textStyles.bodyMedium?.copyWith(color: LearningCyberColors.text, fontWeight: FontWeight.w800))),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _SectionHeader(title: 'AI recommendations', icon: Icons.auto_awesome_rounded, action: null),
                          const SizedBox(height: AppSpacing.sm),
                          if (_aiRecs.isEmpty)
                            _EmptyStateCard(label: 'Aucune recommandation.')
                          else
                            ..._aiRecs.map((r) {
                              final id = (r['job_id'] ?? '').toString();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _GlassTile(
                                  onTap: id.trim().isEmpty ? null : () => context.push('/jobs/$id'),
                                  leading: const Icon(Icons.work_rounded, color: LearningCyberColors.neonCyan),
                                  title: 'Job #$id',
                                  subtitle: 'Score ${r['score'] ?? ''}',
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: LearningCyberColors.textDim),
                                ),
                              );
                            }),
                          const SizedBox(height: AppSpacing.lg),
                          _SectionHeader(title: 'Saved jobs', icon: Icons.bookmark_rounded, action: Text('${_saved.length}', style: context.textStyles.labelLarge?.copyWith(color: LearningCyberColors.textDim))),
                          const SizedBox(height: AppSpacing.sm),
                          _GlassPanel(
                            child: _saved.isEmpty
                                ? Text('Aucun job sauvegardé.', style: context.textStyles.bodyMedium?.copyWith(color: LearningCyberColors.textDim))
                                : Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: _saved.take(24).map((id) => _NeonPill(label: id, onTap: () => context.push('/jobs/$id'))).toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Composants de design ---

class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: LearningCyberColors.panel.withOpacity(0.70),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: LearningCyberColors.stroke.withOpacity(0.9)),
        ),
        child: child,
      );
}

class _GlassTile extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  const _GlassTile({required this.onTap, required this.leading, required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: LearningCyberColors.panelHi.withOpacity(0.78),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: LearningCyberColors.stroke.withOpacity(0.8)),
          ),
          child: Row(children: [leading, const SizedBox(width: AppSpacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(subtitle)])), trailing]),
        ),
      );
}

class _NeonPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NeonPill({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: LearningCyberColors.neonCyan.withOpacity(0.65)),
            color: LearningCyberColors.neonCyan.withOpacity(0.12),
          ),
          child: Text(label, style: context.textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
        ),
      );
}

class _JobsBackground extends StatelessWidget {
  const _JobsBackground();
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(gradient: LearningCyberGradients.background()),
        child: const Stack(children: []),
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? action;
  const _SectionHeader({required this.title, required this.icon, required this.action});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: LearningCyberColors.neonCyan), const SizedBox(width: 8), Text(title)]);
}

class _EmptyStateCard extends StatelessWidget {
  final String label;
  const _EmptyStateCard({required this.label});
  @override
  Widget build(BuildContext context) => _GlassPanel(child: Text(label));
}
