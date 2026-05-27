import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'call_providers.dart';

class PreJoinScreen extends ConsumerStatefulWidget {
  const PreJoinScreen({super.key, required this.requestId});
  final String requestId;

  @override
  ConsumerState<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends ConsumerState<PreJoinScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await [Permission.camera, Permission.microphone].request();
      if (mounted) {
        ref.read(callNotifierProvider.notifier).initCall(widget.requestId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callNotifierProvider);
    final notifier = ref.read(callNotifierProvider.notifier);
    final theme = Theme.of(context);

    if (callState.phase == CallPhase.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (callState.phase == CallPhase.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFD92D20)),
          const SizedBox(height: 16),
          Text(callState.error ?? 'Unknown error'),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => notifier.initCall(widget.requestId), child: const Text('Retry')),
        ])),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ready to Join?')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_outlined, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text('Ready to join?', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Check mic and camera.', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Toggle(icon: callState.isAudioMuted ? Icons.mic_off : Icons.mic, label: callState.isAudioMuted ? 'Off' : 'On', active: !callState.isAudioMuted, onTap: notifier.toggleAudio),
                const SizedBox(width: 24),
                _Toggle(icon: callState.isVideoMuted ? Icons.videocam_off : Icons.videocam, label: callState.isVideoMuted ? 'Off' : 'On', active: !callState.isVideoMuted, onTap: notifier.toggleVideo),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.call),
              label: const Text('Join Call'),
              onPressed: () async {
                await notifier.joinCall();
                if (context.mounted) context.pushReplacement('/call/in-call/${widget.requestId}');
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: const Color(0xFFE50914)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => context.pop(), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.icon, required this.label, required this.active, required this.onTap});
  final IconData icon; final String label; final bool active; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE50914).withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? const Color(0xFFE50914) : Colors.grey.shade300),
        ),
        child: Column(children: [
          Icon(icon, size: 32, color: active ? const Color(0xFFE50914) : Colors.grey),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: active ? const Color(0xFFE50914) : Colors.grey)),
        ]),
      ),
    );
  }
}
