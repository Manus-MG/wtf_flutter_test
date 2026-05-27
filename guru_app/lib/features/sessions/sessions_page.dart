import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wtf_shared/shared.dart';
import 'sessions_providers.dart';

class SessionsPage extends ConsumerWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(sessionFilterProvider);
    final sessions = ref.watch(filteredSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Sessions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: SessionFilter.values.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(f)),
                      selected: filter == f,
                      onSelected: (_) => ref.read(sessionFilterProvider.notifier).state = f,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: sessions.when(
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_note_outlined,
                    title: 'No sessions yet',
                    message: 'Schedule your first call',
                    action: TextButton(
                      onPressed: () => context.push('/schedule'),
                      child: const Text('Schedule Now'),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _SessionTile(log: list[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(title: 'Error', message: e.toString(), icon: Icons.error_outline),
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(SessionFilter f) {
    switch (f) {
      case SessionFilter.all: return 'All';
      case SessionFilter.last7Days: return 'Last 7 Days';
      case SessionFilter.thisMonth: return 'This Month';
    }
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.log});
  final SessionLog log;

  @override
  Widget build(BuildContext context) {
    final mins = (log.durationSec / 60).round();

    return Card(
      child: ListTile(
        onTap: () => GoRouter.of(context).push('/sessions/${log.id}'),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1769E0).withValues(alpha: 0.1),
          child: const Icon(Icons.videocam, color: Color(0xFF1769E0)),
        ),
        title: Text(_fmtDate(log.startedAt), style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$mins min${log.rating != null ? " • ${'★' * log.rating!}" : ""}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
