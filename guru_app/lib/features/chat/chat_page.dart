import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';
import 'chat_providers.dart';
import 'widgets/message_bubble.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/chat_input_bar.dart';

const _quickReplies = ['Got it 👍', 'Can we talk at 6?', 'Share plan?'];

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  void _markRead() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    ref.read(chatServiceProvider).markChatAsRead(widget.chatId, user.id);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.chatId));
    final isTyping = ref.watch(typingProvider(widget.chatId));
    final notifier = ref.read(chatNotifierProvider(widget.chatId).notifier);
    final chatState = ref.watch(chatNotifierProvider(widget.chatId));
    final currentUser = ref.watch(currentUserProvider);

    // Scroll to bottom on new messages
    ref.listen(messagesProvider(widget.chatId), (_, next) {
      next.whenData((_) => WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom()));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aarav'),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (msgs) {
                if (msgs.isEmpty) {
                  return const EmptyState(
                    title: 'No messages yet',
                    message: 'No messages yet. Start the conversation.',
                    icon: Icons.chat_bubble_outline,
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final msg = msgs[i];
                    final isMe = msg.senderId == currentUser?.id;
                    return MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                title: 'Error',
                message: e.toString(),
                icon: Icons.error_outline,
                action: TextButton(onPressed: () {}, child: const Text('Retry')),
              ),
            ),
          ),
          // Typing indicator
          isTyping.when(
            data: (typing) => typing ? const TypingIndicator() : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Quick replies
          if (chatState.draft.isEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: _quickReplies
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(r, style: const TextStyle(fontSize: 13)),
                            onPressed: () => notifier.onTextChanged(r),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ChatInputBar(
            chatId: widget.chatId,
            onTextChanged: notifier.onTextChanged,
            onSend: notifier.sendMessage,
            draft: chatState.draft,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
