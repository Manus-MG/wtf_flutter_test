import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/dev_log_entry.dart';

class DevLogger {
  DevLogger._();
  static final DevLogger instance = DevLogger._();

  FirebaseFirestore? _db;
  final _uuid = const Uuid();

  void init(FirebaseFirestore db) {
    _db = db;
  }

  void log(String tag, String message, {DevLogLevel level = DevLogLevel.info, Map<String, Object?>? payload}) {
    final entry = DevLogEntry(
      id: _uuid.v4(),
      level: level,
      tag: tag,
      message: message,
      createdAt: DateTime.now(),
      payload: payload,
    );
    _write(entry);
  }

  void warn(String tag, String message, {Map<String, Object?>? payload}) =>
      log(tag, message, level: DevLogLevel.warn, payload: payload);

  void error(String tag, String message, {Map<String, Object?>? payload}) =>
      log(tag, message, level: DevLogLevel.error, payload: payload);

  void _write(DevLogEntry entry) {
    _db?.collection('dev_logs').doc(entry.id).set({
      'id': entry.id,
      'level': entry.level.name,
      'tag': entry.tag,
      'message': entry.message,
      'createdAt': Timestamp.fromDate(entry.createdAt),
      'payload': entry.payload,
    });
  }
}
