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
          final log = list.firstWhere((l) => l.id == logId, orElse: () => throw StateError('Not found'));
          final mins = (log.durationSec / 60).round();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Date', value: _fmt(log.startedAt)),
                _InfoRow(label: 'Duration', value: '$mins min'),
                if (log.rating != null) _InfoRow(label: 'Rating', value: '${'★' * log.rating!}${'☆' * (5 - log.rating!)}'),
                if (log.memberNotes?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  const Text('Your Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(log.memberNotes!),
                ],
                if (log.trainerNotes?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  const Text('Trainer Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(log.trainerNotes!),
                ],
                if (log.rating == null) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.push('/sessions/${log.id}/rate'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: const Text('Rate This Session'),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
