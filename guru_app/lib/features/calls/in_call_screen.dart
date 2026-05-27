import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'call_providers.dart';

class InCallScreen extends ConsumerStatefulWidget {
  const InCallScreen({super.key, required this.requestId});
  final String requestId;

  @override
  ConsumerState<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends ConsumerState<InCallScreen> with WidgetsBindingObserver {
  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      // SDK handles reconnect automatically
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String get _elapsedStr {
    final m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callNotifierProvider);
    final notifier = ref.read(callNotifierProvider.notifier);

    // Auto-navigate to post-call on leave
    ref.listen(callNotifierProvider, (_, next) {
      if (next.phase == CallPhase.postCall && mounted) {
        context.pushReplacement('/call/post-call/${widget.requestId}');
      }
    });

    if (callState.phase == CallPhase.joining) {
      return const Scaffold(
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting...'),
          ],
        )),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video tiles
            _buildVideoGrid(callState),
            // Local video (pip)
            Positioned(
              top: 16,
              right: 16,
              width: 100,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: callState.localVideoTrack != null && !callState.isVideoMuted
                    ? HMSVideoView(track: callState.localVideoTrack!)
                    : Container(color: Colors.grey.shade800, child: const Icon(Icons.person, color: Colors.white, size: 40)),
              ),
            ),
            // Duration timer
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                  child: Text(_elapsedStr, style: const TextStyle(color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
                ),
              ),
            ),
            // Reconnecting overlay
            if (callState.phase == CallPhase.joining)
              Container(
                color: Colors.black54,
                child: const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Reconnecting...', style: TextStyle(color: Colors.white)),
                  ],
                )),
              ),
            // Controls bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ControlsBar(
                isAudioMuted: callState.isAudioMuted,
                isVideoMuted: callState.isVideoMuted,
                onToggleAudio: notifier.toggleAudio,
                onToggleVideo: notifier.toggleVideo,
                onSwitchCamera: notifier.switchCamera,
                onEndCall: notifier.endCall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid(CallState callState) {
    if (callState.remotePeers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, color: Colors.white54, size: 80),
            SizedBox(height: 16),
            Text('Waiting for other participant...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }
    final peer = callState.remotePeers.first;
    final videoTrack = peer.videoTrack;
    return videoTrack != null
        ? HMSVideoView(track: videoTrack)
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 50, child: Text(peer.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 40))),
                const SizedBox(height: 16),
                Text(peer.name, style: const TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.isAudioMuted,
    required this.isVideoMuted,
    required this.onToggleAudio,
    required this.onToggleVideo,
    required this.onSwitchCamera,
    required this.onEndCall,
  });

  final bool isAudioMuted;
  final bool isVideoMuted;
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleVideo;
  final VoidCallback onSwitchCamera;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Btn(icon: isAudioMuted ? Icons.mic_off : Icons.mic, label: isAudioMuted ? 'Unmute' : 'Mute', onTap: onToggleAudio),
          _Btn(icon: isVideoMuted ? Icons.videocam_off : Icons.videocam, label: isVideoMuted ? 'Video On' : 'Video Off', onTap: onToggleVideo),
          _Btn(icon: Icons.flip_camera_android, label: 'Flip', onTap: onSwitchCamera),
          _Btn(icon: Icons.call_end, label: 'End', onTap: onEndCall, color: const Color(0xFFD92D20)),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: c.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: c, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: c, fontSize: 12)),
        ],
      ),
    );
  }
}
