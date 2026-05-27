enum DevLogLevel { info, warn, error }

class DevLogEntry {
  const DevLogEntry({
    required this.id,
    required this.level,
    required this.tag,
    required this.message,
    required this.createdAt,
    this.payload,
  });

  final String id;
  final DevLogLevel level;
  final String tag;
  final String message;
  final DateTime createdAt;
  final Map<String, Object?>? payload;

  Map<String, Object?> toJson() => {
        'id': id,
        'level': level.name,
        'tag': tag,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'payload': payload,
      };

  factory DevLogEntry.fromJson(Map<String, Object?> json) {
    return DevLogEntry(
      id: json['id'] as String,
      level: DevLogLevel.values.byName(json['level'] as String),
      tag: json['tag'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      payload: json['payload'] as Map<String, Object?>?,
    );
  }
}
