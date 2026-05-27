enum MessageStatus { sending, sent, read }

class Message {
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;

  Map<String, Object?> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  factory Message.fromJson(Map<String, Object?> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: MessageStatus.values.byName(json['status'] as String),
    );
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? createdAt,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
