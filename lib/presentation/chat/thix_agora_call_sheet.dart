import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thix_id/services/call_service.dart';
import 'package:thix_id/theme.dart';

class ThixCallSheet extends StatefulWidget {
  final String callId;
  final String otherUserId;
  final String kind;
  final bool isCaller;
  final CallService calls;

  const ThixCallSheet({
    super.key,
    required this.callId,
    required this.otherUserId,
    required this.kind,
    required this.isCaller,
    required this.calls,
  });

  @override
  State<ThixCallSheet> createState() => _ThixCallSheetState();
}

class _ThixCallSheetState extends State<ThixCallSheet> {
  bool _connected = false;
  bool _ending = false;
  bool _isLoadingMedia = false;
  String _errorMsg = '';
  Timer? _connectionTimeout;

  bool get _isVideo => widget.kind == 'video';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _connectionTimeout?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      setState(() => _isLoadingMedia = true);

      if (!kIsWeb) {
        final micGranted = await _requestPermission(Permission.microphone, 'microphone');
        if (!micGranted) throw Exception('Permission microphone refusée');
        if (_isVideo) {
          final camGranted = await _requestPermission(Permission.camera, 'caméra');
          if (!camGranted) throw Exception('Permission caméra refusée');
        }
      }

      // Simuler la connexion (à remplacer par la vraie logique Agora)
      _connectionTimeout = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _connected = true;
            _isLoadingMedia = false;
          });
        }
      });
    } catch (e) {
      debugPrint('ThixCallSheet: init failed $e');
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _isLoadingMedia = false;
        });
        _snack('Erreur: $e');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.pop();
        });
      }
    }
  }

  Future<bool> _requestPermission(Permission permission, String name) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _snack('Permission $name définitivement refusée');
      await openAppSettings();
      return false;
    }
    final result = await permission.request();
    return result.isGranted;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _end({required String reason}) async {
    if (_ending) return;
    setState(() => _ending = true);
    _connectionTimeout?.cancel();

    try {
      await widget.calls.completeCall(
        callId: widget.callId,
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('completeCall error: $e');
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isVideo ? 'Appel vidéo' : 'Appel audio',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _errorMsg.isNotEmpty
                              ? _errorMsg
                              : (_connected ? 'Connecté' : (widget.isCaller ? 'Appel en cours…' : 'Connexion…')),
                          style: TextStyle(color: scheme.onSurface.withOpacity(0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _ending ? null : () => _end(reason: 'closed'),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Center(
                child: _isLoadingMedia
                    ? const CircularProgressIndicator()
                    : Icon(
                        Icons.phone_in_talk_rounded,
                        size: 80,
                        color: scheme.primary.withOpacity(0.65),
                      ),
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _HangupButton(onTap: _ending ? null : () => _end(reason: 'hangup')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HangupButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _HangupButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: const Icon(Icons.call_end_rounded, size: 18),
        label: const Text('Raccrocher', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
