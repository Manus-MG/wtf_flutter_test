import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(callNotifierProvider.notifier).initCall(widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ready to Join?')),
      body: switch (callState.phase) {
        CallPhase.loading => const Center(child: CircularProgressIndicator()),
        CallPhase.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Color(0xFFD92D20)),
                const SizedBox(height: 16),
                Text(callState.error ?? 'Unknown error'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.read(callNotifierProvider.notifier).initCall(widget.requestId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        _ => _PreJoinContent(requestId: widget.requestId),
      },
    );
  }
}

class _PreJoinContent extends ConsumerWidget {
  const _PreJoinContent({required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callNotifierProvider);
    final notifier = ref.read(callNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.videocam_outlined, size: 80, color: Color(0xFF1769E0)),
          const SizedBox(height: 24),
          Text('Ready to join?', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Check mic and camera before joining.', style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DeviceToggle(
                icon: callState.isAudioMuted ? Icons.mic_off : Icons.mic,
                label: callState.isAudioMuted ? 'Mic Off' : 'Mic On',
                onTap: () => notifier.toggleAudio(),
                active: !callState.isAudioMuted,
              ),
              const SizedBox(width: 24),
              _DeviceToggle(
                icon: callState.isVideoMuted ? Icons.videocam_off : Icons.videocam,
                label: callState.isVideoMuted ? 'Cam Off' : 'Cam On',
                onTap: () => notifier.toggleVideo(),
                active: !callState.isVideoMuted,
              ),
            ],
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: callState.phase == CallPhase.loading
                ? null
                : () async {
                    await notifier.joinCall();
                    if (context.mounted) {
                      context.pushReplacement('/call/in-call/$requestId');
                    }
                  },
            icon: const Icon(Icons.call),
            label: const Text('Join Call'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DeviceToggle extends StatelessWidget {
  const _DeviceToggle({required this.icon, required this.label, required this.onTap, required this.active});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1769E0).withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? const Color(0xFF1769E0) : Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: active ? const Color(0xFF1769E0) : Colors.grey),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: active ? const Color(0xFF1769E0) : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
