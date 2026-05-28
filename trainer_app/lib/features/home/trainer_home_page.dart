import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

class TrainerHomePage extends ConsumerWidget {
  const TrainerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    final items = [
      _TileItem(
          'Chats', Icons.chat_outlined, '/chats', _unreadBadge(user?.id ?? '')),
      _TileItem('Requests', Icons.rule_folder_outlined, '/requests',
          _pendingBadge(user?.id ?? '')),
      _TileItem('Sessions', Icons.event_note_outlined, '/sessions', null),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer • ${user?.name ?? "Aarav"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppRoleBadge(label: 'Trainer', color: Color(0xFFE50914)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UpcomingCallBanner(trainerId: user?.id ?? 'user_aarav'),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.push(item.route),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(item.icon,
                                        size: 34,
                                        color: const Color(0xFFE50914)),
                                    const SizedBox(height: 12),
                                    Text(item.label,
                                        style: theme.textTheme.titleMedium),
                                  ],
                                ),
                              ),
                              if (item.badge != null)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: item.badge!,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'dev',
              backgroundColor: Colors.black54,
              onPressed: () => context.push('/dev-panel'),
              child: const Text('⋮',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _unreadBadge(String trainerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('trainerId', isEqualTo: trainerId)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final total = snap.data!.docs.fold<int>(
            0, (s, d) => s + ((d['unreadCountTrainer'] as int?) ?? 0));
        if (total == 0) return const SizedBox.shrink();
        return _Badge(count: total);
      },
    );
  }

  Widget _pendingBadge(String trainerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('call_requests')
          .where('trainerId', isEqualTo: trainerId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty)
          return const SizedBox.shrink();
        return _Badge(count: snap.data!.docs.length);
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration:
          const BoxDecoration(color: Color(0xFFE50914), shape: BoxShape.circle),
      child: Text('$count',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _TileItem {
  const _TileItem(this.label, this.icon, this.route, this.badge);
  final String label;
  final IconData icon;
  final String route;
  final Widget? badge;
}

class _UpcomingCallBanner extends StatelessWidget {
  const _UpcomingCallBanner({required this.trainerId});
  final String trainerId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('call_requests')
          .where('trainerId', isEqualTo: trainerId)
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty)
          return const SizedBox.shrink();
        final now = DateTime.now();
        final upcoming = snap.data!.docs.where((d) {
          final scheduled = (d['scheduledFor'] as Timestamp).toDate();
          return scheduled.isAfter(now.subtract(const Duration(hours: 1)));
        }).toList();
        if (upcoming.isEmpty) return const SizedBox.shrink();
        final doc = upcoming.first;
        final scheduled = (doc['scheduledFor'] as Timestamp).toDate();
        final canJoin =
            now.isAfter(scheduled.subtract(const Duration(minutes: 10)));
        return Card(
          color: const Color(0xFFE50914).withValues(alpha: 0.1),
          child: ListTile(
            leading: const Icon(Icons.videocam, color: Color(0xFFE50914)),
            title: Text('Call on ${_fmt(scheduled)}'),
            subtitle: canJoin ? const Text('Ready to join!') : Text('Upcoming'),
            trailing: canJoin
                ? FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914)),
                    onPressed: () =>
                        GoRouter.of(context).push('/call/pre-join/${doc.id}'),
                    child: const Text('Join'),
                  )
                : null,
          ),
        );
      },
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
