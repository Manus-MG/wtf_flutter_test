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
    final attachment = MessageAttachment(
      id: 'att-1',
      name: 'agenda.pdf',
      url: 'https://example.com/agenda.pdf',
      storagePath: 'chats/chat-1/messages/m1/att-1-agenda.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 1024,
    );
    final message = Message(
        id: 'm1',
        chatId: 'chat-1',
        senderId: 'dk',
        receiverId: 'aarav',
        text: 'Hi Coach 👋',
        createdAt: DateTime.parse('2026-05-27T10:00:00Z'),
        status: MessageStatus.sent,
        attachments: [attachment]);

    final decoded = Message.fromJson(message.toJson());

    expect(decoded.text, message.text);
    expect(decoded.status, MessageStatus.sent);
    expect(decoded.attachments, hasLength(1));
    expect(decoded.attachments.first.name, attachment.name);
  });

  test('Message.fromJson tolerates missing attachments', () {
    final decoded = Message.fromJson({
      'id': 'm1',
      'chatId': 'chat-1',
      'senderId': 'dk',
      'receiverId': 'aarav',
      'text': 'Hello',
      'createdAt': DateTime.parse('2026-05-27T10:00:00Z').toIso8601String(),
      'status': 'sent',
    });

    expect(decoded.attachments, isEmpty);
  });

  test('validateFutureDate rejects past values', () {
    final result = validateFutureDate(
      DateTime(2026, 1, 1),
      now: DateTime(2026, 1, 2),
    );

    expect(result, isNotNull);
  });

  test('Message.copyWith updates only specified fields', () {
    final original = Message(
      id: 'm1',
      chatId: 'chat-1',
      senderId: 'dk',
      receiverId: 'aarav',
      text: 'Hello',
      createdAt: DateTime(2026, 5, 27),
      status: MessageStatus.sent,
    );
    final updated = original.copyWith(status: MessageStatus.read);

    expect(updated.id, original.id);
    expect(updated.text, original.text);
    expect(updated.status, MessageStatus.read);
  });

  test('CallRequest.copyWith updates status', () {
    final req = CallRequest(
      id: 'r1',
      memberId: 'user_dk',
      trainerId: 'user_aarav',
      scheduledFor: DateTime(2026, 6, 1, 10),
      note: 'Morning stretch',
      status: CallRequestStatus.pending,
      requestedAt: DateTime(2026, 5, 27),
    );
    final approved = req.copyWith(status: CallRequestStatus.approved);

    expect(approved.status, CallRequestStatus.approved);
    expect(approved.note, req.note);
    expect(approved.id, req.id);
  });

  test('SessionLog.copyWith updates rating and notes', () {
    final log = SessionLog(
      id: 'log1',
      memberId: 'user_dk',
      trainerId: 'user_aarav',
      startedAt: DateTime(2026, 5, 27, 10),
      endedAt: DateTime(2026, 5, 27, 11),
      durationSec: 3600,
    );
    final rated = log.copyWith(rating: 5, memberNotes: 'Great session');

    expect(rated.rating, 5);
    expect(rated.memberNotes, 'Great session');
    expect(rated.durationSec, log.durationSec);
  });
}
