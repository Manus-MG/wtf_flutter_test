import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wtf_shared/shared.dart';
import 'scheduler_providers.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(callRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule a Call')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/schedule/request'),
        icon: const Icon(Icons.add),
        label: const Text('Request Call'),
      ),
      body: requests.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.calendar_month_outlined,
              title: 'No requests yet',
              message: 'Schedule your first call',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _RequestTile(request: list[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(title: 'Error', message: e.toString(), icon: Icons.error_outline),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});
  final CallRequest request;

  @override
  Widget build(BuildContext context) {
    final statusColor = _color(request.status);
    final statusLabel = _label(request.status);

    return Card(
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: statusColor),
        title: Text(_fmtDate(request.scheduledFor), style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.note.isNotEmpty) Text(request.note, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Chip(
              label: Text(statusLabel, style: const TextStyle(fontSize: 11)),
              backgroundColor: statusColor.withValues(alpha: 0.12),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: request.status == CallRequestStatus.approved
            ? FilledButton.icon(
                icon: const Icon(Icons.videocam, size: 16),
                label: const Text('Join'),
                onPressed: () => GoRouter.of(context).push('/call/pre-join/${request.id}'),
                style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
              )
            : null,
        isThreeLine: true,
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Color _color(CallRequestStatus s) {
    switch (s) {
      case CallRequestStatus.pending: return const Color(0xFFF79009);
      case CallRequestStatus.approved: return const Color(0xFF12B76A);
      case CallRequestStatus.declined: return const Color(0xFFD92D20);
      case CallRequestStatus.cancelled: return Colors.grey;
    }
  }

  String _label(CallRequestStatus s) {
    switch (s) {
      case CallRequestStatus.pending: return 'Pending approval by Aarav';
      case CallRequestStatus.approved: return 'Approved';
      case CallRequestStatus.declined: return 'Declined${request.declineReason != null ? ": ${request.declineReason}" : ""}';
      case CallRequestStatus.cancelled: return 'Cancelled';
    }
  }
}
