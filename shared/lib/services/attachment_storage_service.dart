import '../models/attachment.dart';

abstract class AttachmentStorageService {
  Future<List<MessageAttachment>> uploadAttachments({
    required String chatId,
    required String messageId,
    required List<PendingAttachment> attachments,
  });
}
