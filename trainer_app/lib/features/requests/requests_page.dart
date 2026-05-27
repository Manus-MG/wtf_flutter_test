import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

const _kTokenServerUrl = 'http://192.168.29.189:3001';

class RequestsPage extends ConsumerWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(_callRequestsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Call Requests'),
          bottom: const TabBar(tabs: [Tab(text: 'Pending'), Tab(text: 'All')]),
        ),
        body: TabBarView(
          children: [
            _RequestList(requests: requests, filter: CallRequestStatus.pending),
            _RequestList(requests: requests, filter: null),
          ],
        ),
      ),
    );
  }
}

final _callRequestsProvider = StreamProvider<List<CallRequest>>((ref) {
  return ref.watch(callServiceProvider).watchRequests();
});

class _RequestList extends ConsumerWidget {
  const _RequestList({required this.requests, required this.filter});
  final AsyncValue<List<CallRequest>> requests;
  final CallRequestStatus? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return requests.when(
      data: (list) {
        final filtered = filter == null ? list : list.where((r) => r.status == filter).toList();
        if (filtered.isEmpty) {
          return EmptyState(
            icon: Icons.rule_folder_outlined,
            title: filter == CallRequestStatus.pending ? 'No pending requests' : 'No requests',
            message: 'Nothing here yet.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _RequestCard(request: filtered[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  const _RequestCard({required this.request});
  final CallRequest request;

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _loading = false;

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      // Create 100ms room via token server
      final resp = await http.post(
        Uri.parse('$_kTokenServerUrl/room'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': 'wtf-call-${widget.request.id.substring(0, 8)}'}),
      );
      if (resp.statusCode != 200) throw Exception('Room creation failed: ${resp.body}');
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final roomId = data['roomId'] as String;

      final roomMeta = RoomMeta(
        id: const Uuid().v4(),
        callRequestId: widget.request.id,
        hmsRoomId: roomId,
        hmsRoleMember: 'member',
        hmsRoleTrainer: 'trainer',
      );

      await ref.read(callServiceProvider).approveRequest(widget.request.id, roomMeta);

      // Send system message in chat
      final chatId = '${widget.request.memberId}_${widget.request.trainerId}';
      final scheduledStr =
          '${widget.request.scheduledFor.day}/${widget.request.scheduledFor.month} '
          '${widget.request.scheduledFor.hour.toString().padLeft(2, '0')}:'
          '${widget.request.scheduledFor.minute.toString().padLeft(2, '0')}';
      final systemMsg = Message(
        id: const Uuid().v4(),
        chatId: chatId,
        senderId: widget.request.trainerId,
        receiverId: widget.request.memberId,
        text: 'Call approved for $scheduledStr',
        createdAt: DateTime.now(),
        status: MessageStatus.sent,
      );
      await ref.read(chatServiceProvider).sendMessage(systemMsg);

      DevLogger.instance.log('[SCHEDULE]', 'Call approved, room=$roomId');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call approved for $scheduledStr')),
        );
      }
    } catch (e) {
      DevLogger.instance.error('[SCHEDULE]', 'Approve failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            action: SnackBarAction(label: 'Copy', onPressed: () {}),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _decline() async {
    final reason = await _showDeclineDialog();
    if (reason == null) return;
    await ref.read(callServiceProvider).declineRequest(widget.request.id, reason: reason);
    DevLogger.instance.log('[SCHEDULE]', 'Call declined');
  }

  Future<String?> _showDeclineDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Request'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Reason (optional)', border: OutlineInputBorder()),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD92D20)),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final isPending = req.status == CallRequestStatus.pending;
    final statusColor = _color(req.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF1769E0),
                  child: Text('DK', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_fmtDate(req.scheduledFor), style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Requested ${_fmtDate(req.requestedAt)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_label(req.status), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (req.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(req.note),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : _decline,
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD92D20), side: const BorderSide(color: Color(0xFFD92D20))),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading ? null : _approve,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF12B76A)),
                      child: _loading
                          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
            if (req.status == CallRequestStatus.approved) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.videocam, size: 16),
                label: const Text('Join Call'),
                onPressed: () => GoRouter.of(context).push('/call/pre-join/${req.id}'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              ),
            ],
          ],
        ),
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

  String _label(CallRequestStatus s) => s.name[0].toUpperCase() + s.name.substring(1);
}
