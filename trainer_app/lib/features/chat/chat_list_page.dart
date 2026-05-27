import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('trainerId', isEqualTo: user?.id ?? 'user_aarav')
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No chats yet',
              message: 'No messages yet. Start the conversation.',
            );
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final chatId = d['id'] as String? ?? docs[i].id;
              final memberId = d['memberId'] as String? ?? '';
              final lastMsg = d['lastMessage'] as String? ?? '';
              final unread = (d['unreadCountTrainer'] as int?) ?? 0;
              final lastAt = (d['lastMessageAt'] as Timestamp?)?.toDate();

              return ListTile(
                onTap: () => context.push('/chats/$chatId'),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1769E0).withValues(alpha: 0.15),
                  child: Text(
                    memberId.isEmpty ? '?' : memberId.substring(5, 6).toUpperCase(),
                    style: const TextStyle(color: Color(0xFF1769E0), fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(memberId == 'user_dk' ? 'DK' : memberId),
                subtitle: Text(lastMsg.isEmpty ? 'No messages yet. Start the conversation.' : lastMsg,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (lastAt != null)
                      Text(formatRelativeTime(lastAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    if (unread > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Color(0xFFE50914), shape: BoxShape.circle),
                        child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
