import '../models/message.dart';

abstract class ChatService {
  Stream<List<Message>> watchMessages(String chatId);
  Future<void> sendMessage(Message message);
  Future<void> markChatAsRead(String chatId, String userId);
}
