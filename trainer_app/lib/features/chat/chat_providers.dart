import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wtf_shared/shared.dart';
import '../../core/providers/app_providers.dart';

final messagesProvider =
    StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(chatServiceProvider).watchMessages(chatId);
});

final typingProvider = StreamProvider.family<bool, String>((ref, chatId) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return const Stream.empty();
  final parts = chatId.split('_');
  final otherId =
      parts.firstWhere((p) => p != currentUser.id, orElse: () => '');
  if (otherId.isEmpty) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(otherId)
      .snapshots()
      .map((s) {
    final data = s.data();
    if (data == null) return false;
    return (data['isTyping'] as bool? ?? false) &&
        data['typingChatId'] == chatId;
  });
});

class ChatNotifierState {
  const ChatNotifierState(
      {this.draft = '',
      this.attachments = const [],
      this.isSending = false,
      this.error});
  final String draft;
  final List<PendingAttachment> attachments;
  final bool isSending;
  final String? error;
  ChatNotifierState copyWith(
          {String? draft,
          List<PendingAttachment>? attachments,
          bool? isSending,
          String? error}) =>
      ChatNotifierState(
        draft: draft ?? this.draft,
        attachments: attachments ?? this.attachments,
        isSending: isSending ?? this.isSending,
        error: error,
      );
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

  void addAttachments(List<PendingAttachment> attachments) {
    if (attachments.isEmpty) return;
    state = state.copyWith(attachments: [...state.attachments, ...attachments]);
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= state.attachments.length) return;
    final updated = [...state.attachments]..removeAt(index);
    state = state.copyWith(attachments: updated);
  }

  Future<void> sendMessage() async {
    final user = _ref.read(currentUserProvider);
    final text = state.draft.trim();
    final selectedAttachments = List<PendingAttachment>.from(state.attachments);
    if (user == null || (text.isEmpty && selectedAttachments.isEmpty)) return;
    state = state.copyWith(isSending: true, error: null);
    _setTyping(false);
    _typingTimer?.cancel();

    final parts = _chatId.split('_');
    final receiverId = parts.firstWhere((p) => p != user.id, orElse: () => '');
    try {
      final messageId = _uuid.v4();
      final uploadedAttachments = selectedAttachments.isEmpty
          ? const <MessageAttachment>[]
          : await _ref.read(attachmentStorageServiceProvider).uploadAttachments(
                chatId: _chatId,
                messageId: messageId,
                attachments: selectedAttachments,
              );
      final msg = Message(
        id: messageId,
        chatId: _chatId,
        senderId: user.id,
        receiverId: receiverId,
        text: text,
        createdAt: DateTime.now(),
        status: MessageStatus.sent,
        attachments: uploadedAttachments,
      );
      await _ref.read(chatServiceProvider).sendMessage(msg);
      DevLogger.instance.log(
        '[CHAT]',
        'Trainer sent message ${msg.id.substring(0, 8)}${uploadedAttachments.isEmpty ? '' : ' (${uploadedAttachments.length} attachment${uploadedAttachments.length == 1 ? '' : 's'})'}',
      );
      state = state.copyWith(
          draft: '', attachments: const [], isSending: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSending: false);
      return;
    }
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
