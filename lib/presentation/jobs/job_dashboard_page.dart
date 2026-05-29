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
  State<JobDashboardPage> createState() =>
      _JobDashboardPageState();
}

class _JobDashboardPageState
    extends State<JobDashboardPage> {
  final JobService _service = JobService();

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _apps = [];
  List<Map<String, dynamic>> _aiRecs = [];

  Set<String> _saved = {};

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
      final saved =
          await _service.getSavedJobIdsRemote();

      final appsRemote =
          await _service.listMyApplicationsRemote();

      final jobs = await _service.listJobs();

      final auth =
          context.read<AuthController>();

      final me = auth.currentUser;

      final profile = {
        'user_id': me?.id,
        'thix_id': me?.thixId,
      };

      final ai =
          await _service.aiRecommendJobs(
        userProfile: profile,
        jobs: jobs,
        limit: 8,
      );

      if (!mounted) return;

      setState(() {
        _saved = saved;
        _apps = appsRemote;
        _aiRecs = ai ?? [];
      });
    } catch (e) {
      debugPrint(
        'JobDashboardPage error: $e',
      );

      if (mounted) {
        setState(() {
          _error = 'Erreur de chargement';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AdminCyberColors.black,
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AdminCyberColors.text,
          ),
        ),
        title: Text(
          'Dashboard Jobs',
          style: context.textStyles.titleLarge
              ?.copyWith(
            color: AdminCyberColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(
              Icons.refresh,
              color:
                  AdminCyberColors.neonCyan,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    AdminCyberColors.neonCyan,
              ),
            )
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: context
                        .textStyles.bodyLarge
                        ?.copyWith(
                      color:
                          AdminCyberColors
                              .text,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding:
                        const EdgeInsets.all(
                      AppSpacing.lg,
                    ),
                    children: [
                      _buildSavedCard(),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildApplicationsCard(),
                      const SizedBox(
                        height: 20,
                      ),
                      _buildAISection(),
                    ],
                  ),
                ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            AdminCyberColors
                .electricBlue,
        onPressed: () {
          context.go(AppRoutes.jobs);
        },
        child: const Icon(
          Icons.work,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSavedCard() {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AdminCyberColors.panel,
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color:
              AdminCyberColors.stroke,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bookmark,
            color:
                AdminCyberColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Jobs sauvegardés: ${_saved.length}',
              style: const TextStyle(
                color:
                    AdminCyberColors.text,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsCard() {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AdminCyberColors.panel,
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color:
              AdminCyberColors.stroke,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Mes candidatures',
            style: context
                .textStyles.titleMedium
                ?.copyWith(
              color:
                  AdminCyberColors.text,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (_apps.isEmpty)
            const Text(
              'Aucune candidature',
              style: TextStyle(
                color: AdminCyberColors
                    .textDim,
              ),
            )
          else
            ..._apps.map((app) {
              return ListTile(
                contentPadding:
                    EdgeInsets.zero,
                leading: const Icon(
                  Icons.description,
                  color: AdminCyberColors
                      .neonCyan,
                ),
                title: Text(
                  (app['job_title'] ??
                          'Job')
                      .toString(),
                  style: const TextStyle(
                    color:
                        AdminCyberColors
                            .text,
                  ),
                ),
                subtitle: Text(
                  (app['status'] ??
                          'pending')
                      .toString(),
                  style: const TextStyle(
                    color:
                        AdminCyberColors
                            .textDim,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAISection() {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AdminCyberColors.panel,
        borderRadius:
            BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color:
              AdminCyberColors.stroke,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color:
                    AdminCyberColors
                        .neonViolet,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Recommendations',
                style: context
                    .textStyles
                    .titleMedium
                    ?.copyWith(
                  color:
                      AdminCyberColors
                          .text,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_aiRecs.isEmpty)
            const Text(
              'Aucune recommandation',
              style: TextStyle(
                color:
                    AdminCyberColors
                        .textDim,
              ),
            )
          else
            ..._aiRecs.map((job) {
              final id =
                  (job['job_id'] ?? '')
                      .toString();

              return Card(
                color:
                    AdminCyberColors
                        .panelHi,
                child: ListTile(
                  onTap: () {
                    context.push(
                      '/jobs/$id',
                    );
                  },
                  leading: const Icon(
                    Icons.work,
                    color:
                        AdminCyberColors
                            .electricBlue,
                  ),
                  title: Text(
                    (job['title'] ??
                            '')
                        .toString(),
                    style:
                        const TextStyle(
                      color:
                          AdminCyberColors
                              .text,
                    ),
                  ),
                  subtitle: Text(
                    '${job['company'] ?? ''} • ${job['location'] ?? ''}',
                    style:
                        const TextStyle(
                      color:
                          AdminCyberColors
                              .textDim,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
