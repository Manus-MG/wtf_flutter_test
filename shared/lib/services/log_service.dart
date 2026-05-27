import '../models/session_log.dart';

abstract class LogService {
  Stream<List<SessionLog>> watchLogs();
  Future<void> saveLog(SessionLog log);
  Future<void> updateLog(String id, Map<String, dynamic> fields);
}
