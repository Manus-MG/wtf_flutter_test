import 'dart:typed_data';

class MessageAttachment {
  const MessageAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.storagePath,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String id;
  final String name;
  final String url;
  final String storagePath;
  final String mimeType;
  final int sizeBytes;

  bool get isImage => mimeType.toLowerCase().startsWith('image/');

  String get sizeLabel {
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = sizeBytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex += 1;
    }
    final formatted = value >= 10 || unitIndex == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$formatted ${units[unitIndex]}';
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'storagePath': storagePath,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
      };

  factory MessageAttachment.fromJson(Map<String, Object?> json) {
    return MessageAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      storagePath: json['storagePath'] as String,
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    );
  }
}

class PendingAttachment {
  const PendingAttachment({
    required this.name,
    required this.bytes,
    required this.sizeBytes,
    this.mimeType,
  });

  final String name;
  final Uint8List bytes;
  final int sizeBytes;
  final String? mimeType;

  String get sizeLabel {
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = sizeBytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex += 1;
    }
    final formatted = value >= 10 || unitIndex == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$formatted ${units[unitIndex]}';
  }
}
