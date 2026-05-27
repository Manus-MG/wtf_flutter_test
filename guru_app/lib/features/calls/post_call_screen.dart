import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'call_providers.dart';

class PostCallScreen extends ConsumerWidget {
  const PostCallScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callNotifierProvider);
    final durationSec = callState.startedAt != null && callState.endedAt != null
        ? callState.endedAt!.difference(callState.startedAt!).inSeconds
        : 0;
    final mins = (durationSec / 60).round();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF12B76A)),
              const SizedBox(height: 24),
              const Text('Session ended', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Duration: $mins min', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('Session saved to your logs.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              if (callState.sessionLogId != null)
                FilledButton.icon(
                  icon: const Icon(Icons.star_border),
                  label: const Text('Rate This Session'),
                  onPressed: () => context.go('/sessions/${callState.sessionLogId}/rate'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/home'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
