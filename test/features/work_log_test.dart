import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/feature/feature_manifest.dart';
import 'package:staff_app/core/time/clock.dart';
import 'package:staff_app/features/today/src/work_summary.dart';

/// FR-M-041: Today's Work. The day's entries come from each feature; the
/// screen merges, orders and counts them.
void main() {
  const icon = IconData(0xe000);
  WorkLogEntry e(WorkKind kind, int minute, {int? amount, bool pending = false}) =>
      WorkLogEntry(at: DateTime.utc(2026, 11, 21, 4, minute), kind: kind, icon: icon, title: kind.name, amountPoisha: amount, pending: pending);

  test('counts the day: ERP money and money still waiting stay apart', () {
    final s = summarizeWork([
      e(WorkKind.visit, 1),
      e(WorkKind.visit, 2),
      e(WorkKind.collection, 3, amount: 100000),
      e(WorkKind.collection, 4, amount: 50000, pending: true),
      e(WorkKind.promise, 5),
      e(WorkKind.note, 6),
      e(WorkKind.pin, 7, pending: true),
      e(WorkKind.call, 8),
      e(WorkKind.task, 9),
    ]);
    expect((s.visits, s.collections, s.promises, s.others), (2, 2, 1, 4));
    expect(s.postedPoisha, 100000);
    expect(s.pendingPoisha, 50000);
    expect(s.isEmpty, isFalse);
    expect(summarizeWork(const []).isEmpty, isTrue);
  });

  test('latest first; the same moment keeps a steady order', () {
    final list = orderWork([e(WorkKind.note, 5), e(WorkKind.collection, 9), e(WorkKind.visit, 5), e(WorkKind.promise, 1)]);
    expect(list.map((x) => x.kind), [WorkKind.collection, WorkKind.visit, WorkKind.note, WorkKind.promise]);
  });

  test('a business day starts at 00:00 Dhaka; days shift across months and years', () {
    expect(businessDayStartUtc('2026-11-21'), DateTime.utc(2026, 11, 20, 18));
    expect(shiftBusinessDate('2026-11-21', -1), '2026-11-20');
    expect(shiftBusinessDate('2026-11-01', -1), '2026-10-31');
    expect(shiftBusinessDate('2026-12-31', 1), '2027-01-01');
    expect(shiftBusinessDate('2028-02-28', 1), '2028-02-29');
  });

  test('a UUIDv7 gives the moment it was made; other ids give nothing', () {
    // 0x019AA3C5B000 ms = a moment in November 2026
    final at = uuidV7Time('019aa3c5-b000-7abc-8def-0123456789ab');
    expect(at, DateTime.fromMillisecondsSinceEpoch(0x019AA3C5B000, isUtc: true));
    expect(uuidV7Time('019aa3c5-b000-4abc-8def-0123456789ab'), isNull); // version 4
    expect(uuidV7Time('pin-123'), isNull);
    expect(uuidV7Time(''), isNull);
  });
}
