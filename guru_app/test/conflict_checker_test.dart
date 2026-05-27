import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/shared.dart';
import 'package:guru_app/features/scheduler/conflict_checker.dart';

CallRequest _req(DateTime at, {CallRequestStatus status = CallRequestStatus.approved}) =>
    CallRequest(
      id: 'r',
      memberId: 'dk',
      trainerId: 'aarav',
      scheduledFor: at,
      note: '',
      status: status,
      requestedAt: at,
    );

void main() {
  final base = DateTime(2026, 6, 1, 10, 0);

  test('no conflict when list is empty', () {
    expect(hasConflict(base, []), isFalse);
  });

  test('no conflict when pending (not approved)', () {
    final pending = _req(base, status: CallRequestStatus.pending);
    expect(hasConflict(base, [pending]), isFalse);
  });

  test('exact overlap conflicts', () {
    expect(hasConflict(base, [_req(base)]), isTrue);
  });

  test('partial overlap conflicts (30 min into session)', () {
    final overlap = base.add(const Duration(minutes: 30));
    expect(hasConflict(overlap, [_req(base)]), isTrue);
  });

  test('adjacent slot does not conflict (starts exactly at end)', () {
    final adjacent = base.add(const Duration(hours: 1));
    expect(hasConflict(adjacent, [_req(base)]), isFalse);
  });
}
