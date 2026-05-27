import '../models/session_log.dart';

abstract class LogService {
  Stream<List<SessionLog>> watchLogs();
  Future<void> saveLog(SessionLog log);
}
