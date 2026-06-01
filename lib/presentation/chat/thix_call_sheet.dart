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
  int? _remoteUid;
  bool _isJoined = false;
  bool _micOn = true;
  bool _camOn = true;
  bool _connected = false;
  bool _ending = false;
  bool _isLoadingMedia = false;
  DateTime? _startedAt;
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
    _leaveChannel();
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

      await _initAgora();
      await _startCall();
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
    } finally {
      if (mounted) setState(() => _isLoadingMedia = false);
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

  Future<void> _initAgora() async {
    final channelName = 'call_${widget.callId}';
    
    // Initialiser Agora
    await AgoraRtcEngine.init(
      engineConfig: RtcEngineConfig(
        appId: '96ed392d17c74fe684bbb9d4a031ad12',
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    // Définir les callbacks
    AgoraRtcEngine.onJoinChannelSuccess = (connection, elapsed) {
      debugPrint('JoinChannel success');
      setState(() {
        _isJoined = true;
        _connected = true;
        _startedAt ??= DateTime.now();
      });
      _connectionTimeout?.cancel();
    };

    AgoraRtcEngine.onUserJoined = (connection, remoteUid, elapsed) {
      debugPrint('UserJoined: $remoteUid');
      setState(() => _remoteUid = remoteUid);
    };

    AgoraRtcEngine.onUserOffline = (connection, remoteUid, reason) {
      debugPrint('UserOffline: $remoteUid');
      _end(reason: 'user_left');
    };

    AgoraRtcEngine.onError = (err) {
      debugPrint('Agora error: $err');
      if (err != 0 && mounted) {
        _snack('Erreur Agora: $err');
        _end(reason: 'error');
      }
    };

    await AgoraRtcEngine.enableVideo();
    if (!_isVideo) {
      await AgoraRtcEngine.enableLocalVideo(false);
      await AgoraRtcEngine.muteLocalVideoStream(true);
    }

    await AgoraRtcEngine.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
    );

    _connectionTimeout = Timer(const Duration(seconds: 15), () {
      if (!_connected && mounted) {
        _snack('L\'utilisateur ne répond pas');
        _end(reason: 'timeout');
      }
    });
  }

  Future<void> _startCall() async {
    if (widget.isCaller) {
      try {
        await widget.calls.updateCallStatus(widget.callId, 'ringing');
      } catch (e) {
        debugPrint('updateCallStatus error: $e');
      }
    }
  }

  Future<void> _leaveChannel() async {
    try {
      await AgoraRtcEngine.leaveChannel();
      AgoraRtcEngine.destroy();
    } catch (e) {
      debugPrint('leaveChannel error: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _toggleMic() async {
    final enabled = !_micOn;
    await AgoraRtcEngine.muteLocalAudioStream(!enabled);
    setState(() => _micOn = enabled);
  }

  Future<void> _toggleCam() async {
    if (!_isVideo) return;
    final enabled = !_camOn;
    await AgoraRtcEngine.muteLocalVideoStream(!enabled);
    await AgoraRtcEngine.enableLocalVideo(enabled);
    setState(() => _camOn = enabled);
  }

  Future<void> _end({required String reason}) async {
    if (_ending) return;
    setState(() => _ending = true);
    _connectionTimeout?.cancel();

    try {
      await widget.calls.completeCall(
        callId: widget.callId,
        startedAt: _startedAt ?? DateTime.now(),
        endedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('completeCall error: $e');
    }

    await _leaveChannel();
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
            // Video view (simplifié pour éviter les erreurs de paramètres)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.black26,
                    child: _isLoadingMedia
                        ? const Center(child: CircularProgressIndicator())
                        : _isVideo && _remoteUid != null
                            ? Stack(
                                children: [
                                  // Vue distante - version simplifiée
                                  Container(
                                    color: Colors.black,
                                    child: const Center(
                                      child: Text('Vidéo distant', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  // Vue locale (pip)
                                  Positioned(
                                    bottom: 16,
                                    right: 16,
                                    child: Container(
                                      width: 100,
                                      height: 140,
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: Text('Vous', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Icon(
                                  Icons.graphic_eq_rounded,
                                  size: 64,
                                  color: scheme.primary.withOpacity(0.65),
                                ),
                              ),
                  ),
                ),
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                    label: _micOn ? 'Micro' : 'Muet',
                    onTap: _ending ? null : _toggleMic,
                  ),
                  const SizedBox(width: 12),
                  if (_isVideo)
                    _ControlButton(
                      icon: _camOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                      label: _camOn ? 'Cam' : 'Cam off',
                      onTap: _ending ? null : _toggleCam,
                    ),
                  if (_isVideo) const SizedBox(width: 12),
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

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ControlButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: scheme.outlineVariant.withOpacity(0.8)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: scheme.onSurface),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
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
