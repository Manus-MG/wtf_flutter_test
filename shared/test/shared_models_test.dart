import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/shared.dart';

void main() {
  test('User serializes and deserializes', () {
    const user = User(
      id: 'dk',
      role: UserRole.member,
      name: 'DK',
      email: 'dk@example.com',
      assignedTrainerId: 'aarav',
    );

    final decoded = User.fromJson(user.toJson());

    expect(decoded.id, user.id);
    expect(decoded.role, user.role);
    expect(decoded.assignedTrainerId, user.assignedTrainerId);
  });

  test('Message serializes and deserializes', () {
    final message = Message(
      id: 'm1',
      chatId: 'chat-1',
      senderId: 'dk',
      receiverId: 'aarav',
      text: 'Hi Coach 👋',
      createdAt: DateTime.parse('2026-05-27T10:00:00Z'),
      status: MessageStatus.sent,
    );

    final decoded = Message.fromJson(message.toJson());

    expect(decoded.text, message.text);
    expect(decoded.status, MessageStatus.sent);
  });

  test('validateFutureDate rejects past values', () {
    final result = validateFutureDate(
      DateTime(2026, 1, 1),
      now: DateTime(2026, 1, 2),
    );

    expect(result, isNotNull);
  });
}
