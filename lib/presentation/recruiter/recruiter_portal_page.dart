import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/nav.dart';
import 'package:thix_id/services/job_service.dart';
import 'package:thix_id/theme.dart';

class RecruiterPortalPage extends StatefulWidget {
  const RecruiterPortalPage({super.key});

  @override
  State<RecruiterPortalPage> createState() =>
      _RecruiterPortalPageState();
}

class _RecruiterPortalPageState
    extends State<RecruiterPortalPage> {
  final JobService _service = JobService();

  bool _loading = true;
  String? _error;

  int _tab = 0;

  List<Map<String, dynamic>> _myJobs = [];
  List<Map<String, dynamic>> _apps = [];

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
      final auth =
          context.read<AuthController>();

      final uid =
          auth.currentUser?.id ?? '';

      final jobs =
          await _service.listJobs();

      final mine = jobs
          .where(
            (j) =>
                (j.recruiterUserId ?? '') ==
                uid,
          )
          .map(
            (j) => {
              'id': j.id,
              'title': j.title,
              'company': j.company,
              'location': j.location,
              'status': j.status,
            },
          )
          .toList();

      final apps =
          await _service
              .listRecruiterApplications(
        recruiterUserId: uid,
      );

      if (!mounted) return;

      setState(() {
        _myJobs = mine;
        _apps = apps;
      });
    } catch (e) {
      debugPrint(
        'RecruiterPortalPage error: $e',
      );

      if (mounted) {
        setState(() {
          _error =
              'Erreur de chargement';
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
          'Recruiter Portal',
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
              : Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _tab = 0;
                                });
                              },
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    _tab == 0
                                        ? AdminCyberColors
                                            .electricBlue
                                        : AdminCyberColors
                                            .panel,
                              ),
                              child: const Text(
                                'My Jobs',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _tab = 1;
                                });
                              },
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    _tab == 1
                                        ? AdminCyberColors
                                            .electricBlue
                                        : AdminCyberColors
                                            .panel,
                              ),
                              child: const Text(
                                'Applications',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _tab == 0
                          ? _buildJobs()
                          : _buildApplications(),
                    ),
                  ],
                ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            AdminCyberColors
                .electricBlue,
        onPressed: () {
          context.go(
            AppRoutes.jobs,
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildJobs() {
    if (_myJobs.isEmpty) {
      return const Center(
        child: Text(
          'Aucun job',
          style: TextStyle(
            color:
                AdminCyberColors.textDim,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      itemCount: _myJobs.length,
      itemBuilder: (context, index) {
        final job = _myJobs[index];

        return Card(
          color: AdminCyberColors.panel,
          child: ListTile(
            leading: const Icon(
              Icons.work,
              color:
                  AdminCyberColors
                      .electricBlue,
            ),
            title: Text(
              (job['title'] ?? '')
                  .toString(),
              style: const TextStyle(
                color:
                    AdminCyberColors.text,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${job['company'] ?? ''} • ${job['location'] ?? ''}',
              style: const TextStyle(
                color:
                    AdminCyberColors
                        .textDim,
              ),
            ),
            trailing: Text(
              (job['status'] ?? '')
                  .toString(),
              style: const TextStyle(
                color:
                    AdminCyberColors
                        .neonCyan,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplications() {
    if (_apps.isEmpty) {
      return const Center(
        child: Text(
          'Aucune candidature',
          style: TextStyle(
            color:
                AdminCyberColors.textDim,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      itemCount: _apps.length,
      itemBuilder: (context, index) {
        final app = _apps[index];

        return Card(
          color: AdminCyberColors.panel,
          child: ListTile(
            leading: const Icon(
              Icons.people,
              color:
                  AdminCyberColors
                      .neonViolet,
            ),
            title: Text(
              (app['applicant_name'] ??
                      'Applicant')
                  .toString(),
              style: const TextStyle(
                color:
                    AdminCyberColors.text,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            subtitle: Text(
              (app['status'] ?? '')
                  .toString(),
              style: const TextStyle(
                color:
                    AdminCyberColors
                        .textDim,
              ),
            ),
          ),
        );
      },
    );
  }
}
