import '../models/call_request.dart';
import '../models/room_meta.dart';

abstract class CallService {
  Stream<List<CallRequest>> watchRequests();
  Future<void> requestCall(CallRequest request);
  Future<void> approveRequest(String requestId, RoomMeta roomMeta);
  Future<void> declineRequest(String requestId, {String? reason});
}
