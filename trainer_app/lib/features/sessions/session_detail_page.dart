import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'sessions_providers.dart';

class SessionDetailPage extends ConsumerWidget {
  const SessionDetailPage({super.key, required this.logId});
  final String logId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Session Detail')),
      body: sessions.when(
        data: (list) {
          final log = list.firstWhere((l) => l.id == logId, orElse: () => throw StateError('not found'));
          final mins = (log.durationSec / 60).round();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Date', '${log.startedAt.day}/${log.startedAt.month}/${log.startedAt.year}'),
                _row('Duration', '$mins min'),
                if (log.rating != null) _row('Member Rating', '${'★' * log.rating!}${'☆' * (5 - log.rating!)}'),
                if (log.memberNotes?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  const Text('Member Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(log.memberNotes!),
                ],
                if (log.trainerNotes?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  const Text('Your Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(log.trainerNotes!),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.push('/sessions/${log.id}/notes'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Add Notes'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
