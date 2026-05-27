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
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() { _timer?.cancel(); WidgetsBinding.instance.removeObserver(this); super.dispose(); }

  String get _time {
    final m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = ref.watch(callNotifierProvider);
    final n = ref.read(callNotifierProvider.notifier);

    ref.listen(callNotifierProvider, (_, next) {
      if (next.phase == CallPhase.postCall && mounted) {
        context.pushReplacement('/call/post-call/${widget.requestId}');
      }
    });

    if (cs.phase == CallPhase.joining) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 16),
        Text('Connecting...', style: TextStyle(color: Colors.white)),
      ])));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            cs.remotePeers.isEmpty
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.person_outline, color: Colors.white54, size: 80),
                    SizedBox(height: 16),
                    Text('Waiting for member...', style: TextStyle(color: Colors.white54)),
                  ]))
                : (cs.remotePeers.first.videoTrack != null
                    ? HMSVideoView(track: cs.remotePeers.first.videoTrack!)
                    : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        CircleAvatar(radius: 50, child: Text(cs.remotePeers.first.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 40))),
                        const SizedBox(height: 16),
                        Text(cs.remotePeers.first.name, style: const TextStyle(color: Colors.white, fontSize: 20)),
                      ]))),
            Positioned(
              top: 16, right: 16, width: 100, height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: cs.localVideoTrack != null && !cs.isVideoMuted
                    ? HMSVideoView(track: cs.localVideoTrack!)
                    : Container(color: Colors.grey.shade800, child: const Icon(Icons.person, color: Colors.white, size: 40)),
              ),
            ),
            Positioned(top: 16, left: 0, right: 0,
              child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                child: Text(_time, style: const TextStyle(color: Colors.white)),
              )),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent])),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Btn(icon: cs.isAudioMuted ? Icons.mic_off : Icons.mic, label: cs.isAudioMuted ? 'Unmute' : 'Mute', onTap: n.toggleAudio),
                    _Btn(icon: cs.isVideoMuted ? Icons.videocam_off : Icons.videocam, label: 'Video', onTap: n.toggleVideo),
                    _Btn(icon: Icons.flip_camera_android, label: 'Flip', onTap: n.switchCamera),
                    _Btn(icon: Icons.call_end, label: 'End', onTap: n.endCall, color: const Color(0xFFD92D20)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon; final String label; final VoidCallback onTap; final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: c.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(icon, color: c, size: 26)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: c, fontSize: 12)),
      ]),
    );
  }
}
