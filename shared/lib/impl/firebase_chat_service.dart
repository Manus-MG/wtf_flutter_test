import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class FirebaseChatService implements ChatService {
  FirebaseChatService(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _db.collection('chats').doc(chatId).collection('messages');

  DocumentReference<Map<String, dynamic>> _chatDoc(String chatId) =>
      _db.collection('chats').doc(chatId);

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return _messages(chatId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromDoc(d)).toList());
  }

  @override
  Future<void> sendMessage(Message message) async {
    final batch = _db.batch();
    final msgRef = _messages(message.chatId).doc(message.id);
    batch.set(msgRef, _toDoc(message));
    batch.set(
      _chatDoc(message.chatId),
      {
        'id': message.chatId,
        'lastMessage': message.text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'memberId': _memberIdFromChatId(message.chatId),
        'trainerId': _trainerIdFromChatId(message.chatId),
        _unreadKey(message.receiverId, message.chatId): FieldValue.increment(1),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Future<void> markChatAsRead(String chatId, String userId) async {
    // Single-field where clause — no composite index needed.
    // Filter non-read client-side to avoid isNotEqualTo index requirement.
    final snap = await _messages(chatId)
        .where('receiverId', isEqualTo: userId)
        .get();
    final unread = snap.docs
        .where((d) => d.data()['status'] != 'read')
        .toList();
    if (unread.isEmpty) return;
    final batch = _db.batch();
    for (final doc in unread) {
      batch.update(doc.reference, {'status': 'read'});
    }
    batch.update(_chatDoc(chatId), {_unreadKey(userId, chatId): 0});
    await batch.commit();
  }

  Stream<Map<String, dynamic>?> watchChatMeta(String chatId) {
    return _chatDoc(chatId).snapshots().map((s) => s.data());
  }

  Message _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Message(
      id: d['id'] as String,
      chatId: d['chatId'] as String,
      senderId: d['senderId'] as String,
      receiverId: d['receiverId'] as String,
      text: d['text'] as String,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: MessageStatus.values.byName(d['status'] as String? ?? 'sent'),
    );
  }

  Map<String, dynamic> _toDoc(Message m) => {
        'id': m.id,
        'chatId': m.chatId,
        'senderId': m.senderId,
        'receiverId': m.receiverId,
        'text': m.text,
        'createdAt': FieldValue.serverTimestamp(),
        'status': m.status.name,
      };

  String _unreadKey(String userId, String chatId) {
    final parts = chatId.split('_');
    if (parts.length < 2) return 'unreadCountMember';
    return userId == parts[0] ? 'unreadCountMember' : 'unreadCountTrainer';
  }

  String _memberIdFromChatId(String chatId) => chatId.split('_').first;
  String _trainerIdFromChatId(String chatId) => chatId.split('_').last;
}
