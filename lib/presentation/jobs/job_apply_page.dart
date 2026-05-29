import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/nav.dart';
import 'package:thix_id/services/document_service.dart';
import 'package:thix_id/services/job_service.dart';
import 'package:thix_id/services/profile_service.dart';
import 'package:thix_id/services/thix_id_service.dart';
import 'package:thix_id/theme.dart';

class JobApplyPage extends StatefulWidget {
  final String jobId;
  const JobApplyPage({super.key, required this.jobId});

  @override
  State<JobApplyPage> createState() => _JobApplyPageState();
}

class _JobApplyPageState extends State<JobApplyPage> {
  final _jobService = JobService();
  final _profileService = ProfileService();
  final _docService = DocumentService();
  final _thixCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  fp.PlatformFile? _resume;
  fp.PlatformFile? _video;
  List<fp.PlatformFile> _diplomas = const [];

  @override
  void dispose() {
    _thixCtrl.dispose();
    _messageCtrl.dispose();
    _portfolioCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthController>();
    final thixId = auth.currentUser?.thixId ?? '';
    if (_thixCtrl.text.trim().isEmpty && thixId.trim().isNotEmpty) {
      _thixCtrl.text = thixId;
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final canonical = ThixIdService.canonicalizeOrNull(_thixCtrl.text);
      if (canonical == null || !ThixIdService.isValid(canonical)) {
        setState(() => _error = 'THIX ID invalide. Exemple: ${ThixIdService.exampleV2}');
        return;
      }

      final profile = await _profileService.fetchPublicProfileByThixId(canonical);
      if (profile == null) {
        setState(() => _error = 'Aucun profil trouvé pour ce THIX ID.');
        return;
      }

      final uid = context.read<AuthController>().currentUser?.id;
      String? resumeUrl;
      String? videoUrl;
      final diplomaUrls = <String>[];

      if (uid != null && uid.trim().isNotEmpty) {
        resumeUrl = await _tryUpload(uid: uid, file: _resume, kind: 'resume');
        videoUrl = await _tryUpload(uid: uid, file: _video, kind: 'video_intro');
        for (final f in _diplomas) {
          final u = await _tryUpload(uid: uid, file: f, kind: 'diploma');
          if (u != null) diplomaUrls.add(u);
        }
      }

      await _jobService.submitApplication(
        jobId: widget.jobId,
        applicantThixId: canonical,
        message: _messageCtrl.text,
        portfolioUrl: _portfolioCtrl.text.trim().isEmpty ? null : _portfolioCtrl.text.trim(),
        videoIntroUrl: videoUrl,
        resumeUrl: resumeUrl,
        diplomaUrls: diplomaUrls,
      );
      if (!mounted) return;
      context.go('/jobs/${widget.jobId}?applied=1');
    } catch (e) {
      debugPrint('JobApplyPage.submit failed err=$e');
      if (!mounted) return;
      setState(() => _error = 'Erreur lors de la candidature.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _tryUpload({required String uid, required fp.PlatformFile? file, required String kind}) async {
    if (file == null) return null;
    try {
      const bucket = 'thix-job-applications';
      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = 'users/$uid/jobs/${widget.jobId}/$kind/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      final uploadedPath = await _docService.uploadPickedFileToBucket(bucketName: bucket, uid: uid, objectPath: path, file: file);
      try {
        return await _docService.createDownloadUrl(bucketName: bucket, storagePath: uploadedPath);
      } catch (_) {
        return Supabase.instance.client.storage.from(bucket).getPublicUrl(uploadedPath);
      }
    } catch (e) {
      debugPrint('JobApplyPage._tryUpload failed err=$e');
      return null;
    }
  }

  // --- Méthodes de picking de fichiers (inchangées) ---
  Future<void> _pickResume() async {
    final res = await fp.FilePicker.pickFiles(withData: kIsWeb, type: fp.FileType.custom, allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp']);
    if (res != null && res.files.isNotEmpty) setState(() => _resume = res.files.first);
  }

  Future<void> _pickVideo() async {
    final res = await fp.FilePicker.pickFiles(withData: kIsWeb, type: fp.FileType.video);
    if (res != null && res.files.isNotEmpty) setState(() => _video = res.files.first);
  }

  Future<void> _pickDiplomas() async {
    final res = await fp.FilePicker.pickFiles(withData: kIsWeb, allowMultiple: true, type: fp.FileType.custom, allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp']);
    if (res != null && res.files.isNotEmpty) setState(() => _diplomas = res.files);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final me = auth.currentUser;

    return Scaffold(
      backgroundColor: LearningCyberColors.bg0,
      body: SafeArea(
        child: FutureBuilder(
          future: _jobService.fetchJob(widget.jobId),
          builder: (context, snap) {
            final job = snap.data;
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: LearningCyberColors.neonCyan));
            }
            if (job == null) return const Center(child: Text('Offre introuvable.'));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(jobId: widget.jobId),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: LearningCyberColors.panel.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: LearningCyberColors.stroke.withOpacity(0.9), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        TextField(controller: _thixCtrl, decoration: const InputDecoration(labelText: 'THIX ID', filled: true)),
                        const SizedBox(height: AppSpacing.md),
                        TextField(controller: _messageCtrl, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Message (optional)', filled: true)),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: _loading ? null : _submit,
                          child: Text(_loading ? 'Envoi...' : 'Envoyer ma candidature'),
                        ),
                      ],
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
  final String jobId;
  const _TopBar({required this.jobId});
  @override
  Widget build(BuildContext context) => Row(children: [IconButton(onPressed: () => context.popOrGo('/jobs/$jobId'), icon: const Icon(Icons.arrow_back))]);
}
