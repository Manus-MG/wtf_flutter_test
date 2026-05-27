import 'package:wtf_shared/shared.dart';

const _sessionDuration = Duration(hours: 1);

bool hasConflict(DateTime proposed, List<CallRequest> existing) {
  final proposedEnd = proposed.add(_sessionDuration);
  return existing.where((r) => r.status == CallRequestStatus.approved).any((r) {
    final existingEnd = r.scheduledFor.add(_sessionDuration);
    return proposed.isBefore(existingEnd) && proposedEnd.isAfter(r.scheduledFor);
  });
}
