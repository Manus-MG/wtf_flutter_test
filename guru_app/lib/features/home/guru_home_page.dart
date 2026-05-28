import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

class GuruHomePage extends ConsumerWidget {
  const GuruHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Guru • ${user?.name ?? "DK"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppRoleBadge(label: 'Member', color: Color(0xFF1769E0)),
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
                SectionCard(
                  title: 'Welcome back, ${user?.name ?? "DK"}',
                  child: Text(
                    'Your trainer workspace is ready. Chat, schedule a call, or review sessions.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                _UpcomingCallBanner(userId: user?.id ?? 'user_dk'),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      _NavCard(
                        icon: Icons.chat_bubble_outline,
                        title: 'Chat with Trainer',
                        subtitle: 'Messages with Aarav',
                        onTap: () => context.push('/chat/user_dk_user_aarav'),
                      ),
                      const SizedBox(height: 12),
                      _NavCard(
                        icon: Icons.calendar_month_outlined,
                        title: 'Schedule Call',
                        subtitle: 'Book a video session',
                        onTap: () => context.push('/schedule'),
                      ),
                      const SizedBox(height: 12),
                      _NavCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'My Sessions',
                        subtitle: 'History & ratings',
                        onTap: () => context.push('/sessions'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Debug FAB
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
}

class _UpcomingCallBanner extends StatelessWidget {
  const _UpcomingCallBanner({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('call_requests')
          .where('memberId', isEqualTo: userId)
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty)
          return const SizedBox.shrink();
        final docs = snap.data!.docs;
        // Find calls where scheduledFor is within 10 min from now or in the future
        final now = DateTime.now();
        final upcoming = docs.where((d) {
          final scheduled = (d['scheduledFor'] as Timestamp).toDate();
          return scheduled.isAfter(now.subtract(const Duration(hours: 1)));
        }).toList();
        if (upcoming.isEmpty) return const SizedBox.shrink();
        final doc = upcoming.first;
        final scheduled = (doc['scheduledFor'] as Timestamp).toDate();
        final canJoin =
            now.isAfter(scheduled.subtract(const Duration(minutes: 10)));
        return Card(
          color: const Color(0xFF1769E0).withValues(alpha: 0.1),
          child: ListTile(
            leading: const Icon(Icons.videocam, color: Color(0xFF1769E0)),
            title: Text('Call on ${_fmt(scheduled)}'),
            subtitle: canJoin
                ? const Text('Ready to join!')
                : Text('In ${_diff(scheduled, now)}'),
            trailing: canJoin
                ? FilledButton(
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

  String _diff(DateTime future, DateTime now) {
    final diff = future.difference(now);
    if (diff.inHours > 0)
      return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    return '${diff.inMinutes}m';
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1769E0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF1769E0)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
