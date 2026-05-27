import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_log.dart';
import '../services/log_service.dart';

class FirebaseLogService implements LogService {
  FirebaseLogService(this._db, {required this.currentUserId});

  final FirebaseFirestore _db;
  final String currentUserId;

  CollectionReference<Map<String, dynamic>> get _logs =>
      _db.collection('session_logs');

  @override
  Stream<List<SessionLog>> watchLogs() {
    return _db
        .collection('session_logs')
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((s) {
      return s.docs
          .map(_fromDoc)
          .where((l) => l.memberId == currentUserId || l.trainerId == currentUserId)
          .toList();
    });
  }

  @override
  Future<void> saveLog(SessionLog log) async {
    await _logs.doc(log.id).set(_toDoc(log));
  }

  @override
  Future<void> updateLog(String id, Map<String, dynamic> fields) async {
    await _logs.doc(id).update(fields);
  }

  SessionLog _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SessionLog(
      id: d['id'] as String,
      memberId: d['memberId'] as String,
      trainerId: d['trainerId'] as String,
      startedAt: (d['startedAt'] as Timestamp).toDate(),
      endedAt: (d['endedAt'] as Timestamp).toDate(),
      durationSec: d['durationSec'] as int,
      rating: d['rating'] as int?,
      trainerNotes: d['trainerNotes'] as String?,
      memberNotes: d['memberNotes'] as String?,
    );
  }

  Map<String, dynamic> _toDoc(SessionLog l) => {
        'id': l.id,
        'memberId': l.memberId,
        'trainerId': l.trainerId,
        'startedAt': Timestamp.fromDate(l.startedAt),
        'endedAt': Timestamp.fromDate(l.endedAt),
        'durationSec': l.durationSec,
        'rating': l.rating,
        'trainerNotes': l.trainerNotes,
        'memberNotes': l.memberNotes,
      };
}
