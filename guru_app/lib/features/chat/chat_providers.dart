import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(chatServiceProvider).watchMessages(chatId);
});

final typingProvider = StreamProvider.family<bool, String>((ref, chatId) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return const Stream.empty();
  // Watch the OTHER user's typing state for this chat
  final parts = chatId.split('_');
  final otherId = parts.firstWhere((p) => p != currentUser.id, orElse: () => '');
  if (otherId.isEmpty) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(otherId)
      .snapshots()
      .map((s) {
    final data = s.data();
    if (data == null) return false;
    return (data['isTyping'] as bool? ?? false) && data['typingChatId'] == chatId;
  });
});

final unreadCountProvider = StreamProvider.family<int, String>((ref, chatId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final field = user.role == UserRole.member ? 'unreadCountMember' : 'unreadCountTrainer';
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .snapshots()
      .map((s) => (s.data()?[field] as int?) ?? 0);
});

class ChatNotifierState {
  const ChatNotifierState({this.draft = '', this.isSending = false, this.error});
  final String draft;
  final bool isSending;
  final String? error;
  ChatNotifierState copyWith({String? draft, bool? isSending, String? error}) =>
      ChatNotifierState(draft: draft ?? this.draft, isSending: isSending ?? this.isSending, error: error);
}

class ChatNotifier extends StateNotifier<ChatNotifierState> {
  ChatNotifier(this._ref, this._chatId) : super(const ChatNotifierState());

  final Ref _ref;
  final String _chatId;
  final _uuid = const Uuid();
  Timer? _typingTimer;

  void onTextChanged(String text) {
    state = state.copyWith(draft: text);
    _setTyping(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () => _setTyping(false));
  }

  Future<void> sendMessage() async {
    final user = _ref.read(currentUserProvider);
    if (user == null || state.draft.trim().isEmpty) return;
    final text = state.draft.trim();
    state = state.copyWith(draft: '', isSending: true);
    _setTyping(false);
    _typingTimer?.cancel();

    final parts = _chatId.split('_');
    final receiverId = parts.firstWhere((p) => p != user.id, orElse: () => '');
    final msg = Message(
      id: _uuid.v4(),
      chatId: _chatId,
      senderId: user.id,
      receiverId: receiverId,
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );
    try {
      await _ref.read(chatServiceProvider).sendMessage(msg);
      DevLogger.instance.log('[CHAT]', 'Message sent: ${msg.id.substring(0, 8)}');
    } catch (e) {
      DevLogger.instance.error('[CHAT]', 'Send failed: $e');
      state = state.copyWith(error: e.toString(), isSending: false);
      return;
    }
    state = state.copyWith(isSending: false);
  }

  void _setTyping(bool typing) {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    FirebaseFirestore.instance.collection('users').doc(user.id).update({
      'isTyping': typing,
      'typingChatId': typing ? _chatId : null,
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _setTyping(false);
    super.dispose();
  }
}

final chatNotifierProvider =
    StateNotifierProvider.family<ChatNotifier, ChatNotifierState, String>(
        (ref, chatId) => ChatNotifier(ref, chatId));
