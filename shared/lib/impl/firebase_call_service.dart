import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_request.dart';
import '../models/room_meta.dart';
import '../services/call_service.dart';

class FirebaseCallService implements CallService {
  FirebaseCallService(this._db, {required this.currentUserId, required this.currentUserRole});

  final FirebaseFirestore _db;
  final String currentUserId;
  final String currentUserRole;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('call_requests');

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection('room_meta');

  @override
  Stream<List<CallRequest>> watchRequests() {
    final field = currentUserRole == 'trainer' ? 'trainerId' : 'memberId';
    return _requests
        .where(field, isEqualTo: currentUserId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> requestCall(CallRequest request) async {
    await _requests.doc(request.id).set(_toDoc(request));
  }

  @override
  Future<void> approveRequest(String requestId, RoomMeta roomMeta) async {
    final batch = _db.batch();
    batch.update(_requests.doc(requestId), {'status': 'approved'});
    batch.set(_rooms.doc(requestId), _roomToDoc(roomMeta));
    await batch.commit();
  }

  @override
  Future<void> declineRequest(String requestId, {String? reason}) async {
    await _requests.doc(requestId).update({
      'status': 'declined',
      'declineReason': reason ?? '',
    });
  }

  Future<RoomMeta?> getRoomMeta(String callRequestId) async {
    final doc = await _rooms.doc(callRequestId).get();
    if (!doc.exists) return null;
    return _roomFromDoc(doc);
  }

  Stream<RoomMeta?> watchRoomMeta(String callRequestId) {
    return _rooms.doc(callRequestId).snapshots().map((s) {
      if (!s.exists) return null;
      return _roomFromDoc(s);
    });
  }

  Future<CallRequest?> getRequest(String requestId) async {
    final doc = await _requests.doc(requestId).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  CallRequest _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return CallRequest(
      id: d['id'] as String,
      memberId: d['memberId'] as String,
      trainerId: d['trainerId'] as String,
      requestedAt: (d['requestedAt'] as Timestamp).toDate(),
      scheduledFor: (d['scheduledFor'] as Timestamp).toDate(),
      note: d['note'] as String? ?? '',
      status: CallRequestStatus.values.byName(d['status'] as String),
      declineReason: d['declineReason'] as String?,
    );
  }

  Map<String, dynamic> _toDoc(CallRequest r) => {
        'id': r.id,
        'memberId': r.memberId,
        'trainerId': r.trainerId,
        'requestedAt': FieldValue.serverTimestamp(),
        'scheduledFor': Timestamp.fromDate(r.scheduledFor),
        'note': r.note,
        'status': r.status.name,
        'declineReason': r.declineReason,
      };

  RoomMeta _roomFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return RoomMeta(
      id: d['id'] as String,
      callRequestId: d['callRequestId'] as String,
      hmsRoomId: d['hmsRoomId'] as String,
      hmsRoleMember: d['hmsRoleMember'] as String,
      hmsRoleTrainer: d['hmsRoleTrainer'] as String,
    );
  }

  Map<String, dynamic> _roomToDoc(RoomMeta r) => {
        'id': r.id,
        'callRequestId': r.callRequestId,
        'hmsRoomId': r.hmsRoomId,
        'hmsRoleMember': r.hmsRoleMember,
        'hmsRoleTrainer': r.hmsRoleTrainer,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
