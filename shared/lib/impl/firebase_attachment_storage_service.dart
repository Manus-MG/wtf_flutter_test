import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/attachment.dart';
import '../services/attachment_storage_service.dart';

class FirebaseAttachmentStorageService implements AttachmentStorageService {
  FirebaseAttachmentStorageService(this._storage);

  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  @override
  Future<List<MessageAttachment>> uploadAttachments({
    required String chatId,
    required String messageId,
    required List<PendingAttachment> attachments,
  }) async {
    final uploaded = <MessageAttachment>[];
    for (final attachment in attachments) {
      final id = _uuid.v4();
      final mimeType = attachment.mimeType ?? _guessMimeType(attachment.name);
      final storagePath =
          'chats/$chatId/messages/$messageId/$id-${_sanitizeFileName(attachment.name)}';
      final ref = _storage.ref(storagePath);
      await ref.putData(
        attachment.bytes,
        SettableMetadata(contentType: mimeType),
      );
      final url = await ref.getDownloadURL();
      uploaded.add(
        MessageAttachment(
          id: id,
          name: attachment.name,
          url: url,
          storagePath: storagePath,
          mimeType: mimeType,
          sizeBytes: attachment.sizeBytes,
        ),
      );
    }
    return uploaded;
  }

  String _sanitizeFileName(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return cleaned.isEmpty ? 'attachment' : cleaned;
  }

  String _guessMimeType(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }
}
