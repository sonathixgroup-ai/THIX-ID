import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thix_id/services/call_service.dart';
import 'package:thix_id/supabase/supabase_config.dart';
import 'package:thix_id/theme.dart';

/// Bottom-sheet that hosts a 1:1 WebRTC call (audio/video).
///
/// Signaling is done via Supabase Realtime using [CallService.signalsTable].
class ThixCallSheet extends StatefulWidget {
  final String callId;
  final String otherUserId;
  final String kind; // audio|video
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
  late final RTCVideoRenderer _local;
  late final RTCVideoRenderer _remote;
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  StreamSubscription<List<Map<String, dynamic>>>? _signalsSub;
  final Set<String> _handledSignalIds = <String>{};

  bool _micOn = true;
  bool _camOn = true;
  bool _connected = false;
  bool _ending = false;
  bool _isLoadingMedia = false;
  DateTime? _startedAt;
  String _errorMsg = '';

  // Pour le swap de caméra
  String? _currentCameraId;
  List<MediaDeviceInfo>? _cameras;
  bool _isFrontCamera = true;

  bool get _isVideo => widget.kind == 'video';

  @override
  void initState() {
    super.initState();
    _local = RTCVideoRenderer();
    _remote = RTCVideoRenderer();
    unawaited(_init());
  }

  @override
  void dispose() {
    unawaited(_signalsSub?.cancel());
    unawaited(_disposeRtc());
    _local.dispose();
    _remote.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      // 1. Permissions (mobile uniquement)
      if (!kIsWeb) {
        final micGranted = await _requestPermission(Permission.microphone, 'microphone');
        if (!micGranted) throw Exception('Permission microphone refusée');
        if (_isVideo) {
          final camGranted = await _requestPermission(Permission.camera, 'caméra');
          if (!camGranted) throw Exception('Permission caméra refusée');
        }
      }

      // 2. Initialiser les renderers
      await _local.initialize();
      await _remote.initialize();

      // 3. Configuration ICE (STUN + TURN via serveurs publics pour l'instant)
      final iceServers = await _getIceServers();

      // 4. Créer la connexion et obtenir les médias
      setState(() => _isLoadingMedia = true);
      await _preparePeer(iceServers);
      await _startSignalListener();

      // 5. Si caller, envoyer l'offre
      if (widget.isCaller) {
        await _makeOffer();
      }
    } catch (e) {
      debugPrint('ThixCallSheet: init failed err=$e');
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _isLoadingMedia = false;
        });
        _snack('Impossible de démarrer l’appel: $e');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.pop();
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingMedia = false);
    }
  }

  /// Demande une permission avec gestion du refus définitif
  Future<bool> _requestPermission(Permission permission, String name) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _snack('Permission $name définitivement refusée. Activez-la dans les paramètres.');
      await openAppSettings();
      return false;
    }
    final result = await permission.request();
    return result.isGranted;
  }

  Future<List<Map<String, dynamic>>> _getIceServers() async {
    return [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ];
  }

  Future<void> _preparePeer(List<Map<String, dynamic>> iceServers) async {
    final config = {
      'iceServers': iceServers,
      'sdpSemantics': 'unified-plan',
    };
    _pc = await createPeerConnection(config);

    _pc!.onIceCandidate = (RTCIceCandidate? c) {
      if (c == null || c.candidate == null || c.candidate?.isEmpty == true) return;
      unawaited(widget.calls.sendSignal(
        callId: widget.callId,
        toUserId: widget.otherUserId,
        type: 'candidate',
        payload: {
          'candidate': c.candidate,
          'sdpMid': c.sdpMid,
          'sdpMLineIndex': c.sdpMLineIndex,
        },
      ));
    };

    _pc!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ThixCallSheet: ICE state=$state');
    };

    _pc!.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('ThixCallSheet: pc connectionState=$state');
      if (!mounted) return;
      final ok = state == RTCPeerConnectionState.RTCPeerConnectionStateConnected;
      if (ok && !_connected) {
        setState(() {
          _connected = true;
          _startedAt ??= DateTime.now();
        });
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        unawaited(_end(reason: 'disconnected'));
      }
    };

    _pc!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isEmpty) return;
      _remote.srcObject = event.streams.first;
      if (mounted) setState(() {});
    };

    // Obtenir les médias
    final constraints = {
      'audio': true,
      'video': _isVideo,
    };
    
    MediaStream media;
    if (kIsWeb) {
      // Web: utiliser navigator.mediaDevices
      final mediaDevices = await navigator.mediaDevices;
      media = await mediaDevices.getUserMedia(constraints);
    } else {
      // Mobile: utiliser helper du package
      media = await navigator.mediaDevices!.getUserMedia(constraints);
    }
    
    _localStream = media;
    _local.srcObject = media;

    // Récupérer la liste des caméras pour le swap (si vidéo)
    if (_isVideo) {
      final mediaDevices = await navigator.mediaDevices;
      _cameras = await mediaDevices.enumerateDevices();
      final videoDevices = _cameras!.where((d) => d.kind == 'videoinput').toList();
      if (videoDevices.isNotEmpty) {
        _currentCameraId = videoDevices.first.deviceId;
        _isFrontCamera = !videoDevices.any((d) => d.label.toLowerCase().contains('back'));
      }
    }

    for (final track in media.getTracks()) {
      await _pc!.addTrack(track, media);
    }
  }

  Future<void> _swapCamera() async {
    if (!_isVideo || _localStream == null) return;
    final videoDevices = _cameras?.where((d) => d.kind == 'videoinput').toList() ?? [];
    if (videoDevices.length < 2) {
      _snack('Une seule caméra disponible');
      return;
    }
    // Basculer vers l'autre caméra
    final index = videoDevices.indexWhere((d) => d.deviceId == _currentCameraId);
    final nextIndex = (index + 1) % videoDevices.length;
    final nextDevice = videoDevices[nextIndex];
    _currentCameraId = nextDevice.deviceId;

    // Remplacer la piste vidéo
    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isNotEmpty) {
      final videoTrack = videoTracks.first;
      final mediaDevices = await navigator.mediaDevices;
      final newStream = await mediaDevices.getUserMedia({
        'audio': false,
        'video': {'deviceId': {'exact': nextDevice.deviceId}},
      });
      final newVideoTracks = newStream.getVideoTracks();
      if (newVideoTracks.isEmpty) return;
      final newVideoTrack = newVideoTracks.first;
      await _localStream!.removeTrack(videoTrack);
      await _localStream!.addTrack(newVideoTrack);
      await videoTrack.stop();

      // CORRECTION : attendre la liste des senders avant d'appeler firstWhere
      final senders = await _pc!.getSenders();
      final videoSender = senders.firstWhere((s) => s.track?.kind == 'video');
      await videoSender.replaceTrack(newVideoTrack);
      setState(() {});
    }
  }

  Future<void> _startSignalListener() async {
    final me = SupabaseConfig.client.auth.currentSession?.user;
    if (me == null) throw Exception('Not authenticated');
    _signalsSub = widget.calls.streamSignals(callId: widget.callId, forUserId: me.id).listen((signals) {
      for (final signal in signals.reversed) {
        final id = (signal['id'] ?? '').toString();
        if (id.isEmpty || _handledSignalIds.contains(id)) continue;
        _handledSignalIds.add(id);
        unawaited(_handleSignal(signal));
      }
    });
  }

  Future<void> _handleSignal(Map<String, dynamic> signal) async {
    try {
      final type = (signal['type'] as String?) ?? '';
      final payload = (signal['payload'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      if (_pc == null) return;

      if (type == 'offer') {
        final sdp = payload['sdp'] as String? ?? '';
        final sdpType = payload['type'] as String? ?? 'offer';
        final offer = RTCSessionDescription(sdp, sdpType);
        await _pc!.setRemoteDescription(offer);
        final answer = await _pc!.createAnswer();
        await _pc!.setLocalDescription(answer);
        await widget.calls.sendSignal(
          callId: widget.callId,
          toUserId: widget.otherUserId,
          type: 'answer',
          payload: {'sdp': answer.sdp, 'type': answer.type},
        );
      } else if (type == 'answer') {
        final sdp = payload['sdp'] as String? ?? '';
        final sdpType = payload['type'] as String? ?? 'answer';
        final answer = RTCSessionDescription(sdp, sdpType);
        await _pc!.setRemoteDescription(answer);
      } else if (type == 'candidate') {
        final candidate = payload['candidate'] as String? ?? '';
        final sdpMid = payload['sdpMid'] as String? ?? '';
        final sdpMLineIndex = (payload['sdpMLineIndex'] as num?)?.toInt() ?? 0;
        final cand = RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);
        await _pc!.addCandidate(cand);
      } else if (type == 'hangup' || type == 'decline') {
        await _end(reason: type);
      }
    } catch (e) {
      debugPrint('ThixCallSheet: handleSignal failed err=$e');
    }
  }

  Future<void> _makeOffer() async {
    if (_pc == null) return;
    final offer = await _pc!.createOffer({'offerToReceiveAudio': 1, 'offerToReceiveVideo': _isVideo ? 1 : 0});
    await _pc!.setLocalDescription(offer);
    await widget.calls.sendSignal(
      callId: widget.callId,
      toUserId: widget.otherUserId,
      type: 'offer',
      payload: {'sdp': offer.sdp, 'type': offer.type},
    );
  }

  Future<void> _disposeRtc() async {
    try {
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;

    try {
      await _pc?.close();
    } catch (_) {}
    _pc = null;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _toggleMic() async {
    final stream = _localStream;
    if (stream == null) return;
    final enabled = !_micOn;
    for (final track in stream.getAudioTracks()) {
      await track.enable(enabled);
    }
    setState(() => _micOn = enabled);
  }

  Future<void> _toggleCam() async {
    final stream = _localStream;
    if (stream == null) return;
    final enabled = !_camOn;
    for (final track in stream.getVideoTracks()) {
      await track.enable(enabled);
    }
    setState(() => _camOn = enabled);
  }

  Future<void> _end({required String reason}) async {
    if (_ending) return;
    setState(() => _ending = true);
    try {
      await widget.calls.sendSignal(
        callId: widget.callId,
        toUserId: widget.otherUserId,
        type: 'hangup',
        payload: {'reason': reason},
      );
    } catch (_) {}

    final started = _startedAt;
    if (started != null) {
      try {
        await widget.calls.completeCall(callId: widget.callId, startedAt: started, endedAt: DateTime.now());
      } catch (e) {
        debugPrint('ThixCallSheet: completeCall failed (ignored) err=$e');
      }
    } else {
      try {
        await widget.calls.setCallStatus(callId: widget.callId, status: 'declined');
      } catch (_) {}
    }

    await _disposeRtc();
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
          border: Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6))),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isVideo ? 'Appel vidéo' : 'Appel audio', style: context.textStyles.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(
                          _errorMsg.isNotEmpty
                              ? _errorMsg
                              : (_connected ? 'Connecté' : (widget.isCaller ? 'Appel en cours…' : 'Connexion…')),
                          style: context.textStyles.labelSmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.60), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  _Action(
                    icon: Icons.close_rounded,
                    tooltip: 'Fermer',
                    onTap: _ending ? null : () { unawaited(_end(reason: 'closed')); },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.35)),
                    child: _isLoadingMedia
                        ? const Center(child: CircularProgressIndicator())
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_isVideo)
                                RTCVideoView(_remote, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                              else
                                Center(
                                  child: Icon(Icons.graphic_eq_rounded, size: 64, color: scheme.primary.withValues(alpha: 0.65)),
                                ),
                              if (_isVideo)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    child: SizedBox(
                                      width: 120,
                                      height: 160,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7))),
                                          child: RTCVideoView(_local, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Pill(
                    icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                    label: _micOn ? 'Micro' : 'Muet',
                    onTap: _ending ? null : () { unawaited(_toggleMic()); },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (_isVideo)
                    _Pill(
                      icon: _camOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                      label: _camOn ? 'Cam' : 'Cam off',
                      onTap: _ending ? null : () { unawaited(_toggleCam()); },
                    ),
                  if (_isVideo && _cameras != null && _cameras!.length > 1)
                    const SizedBox(width: AppSpacing.sm),
                  if (_isVideo && _cameras != null && _cameras!.length > 1)
                    _Pill(
                      icon: Icons.switch_camera_rounded,
                      label: 'Swap',
                      onTap: _ending ? null : () { unawaited(_swapCamera()); },
                    ),
                  if (_isVideo) const SizedBox(width: AppSpacing.sm),
                  _Hangup(onTap: _ending ? null : () { unawaited(_end(reason: 'hangup')); }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  
  const _Action({required this.icon, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 18, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  
  const _Pill({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.8)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: scheme.onSurface),
                const SizedBox(width: 8),
                Text(label, style: context.textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hangup extends StatelessWidget {
  final VoidCallback? onTap;
  
  const _Hangup({required this.onTap});

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: Icon(Icons.call_end_rounded, size: 18, color: scheme.onError),
        label: Text('Raccrocher', style: context.textStyles.labelLarge?.copyWith(color: scheme.onError, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
