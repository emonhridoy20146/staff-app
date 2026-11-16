import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/media/media.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/attendance.dart';

import 'helpers.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  test('every attendance event needs a selfie by default', () async {
    await h.signIn();
    final s = h.read(attendanceServiceProvider);
    for (final t in AttendanceEventType.values) {
      expect(s.needsSelfie(t), isTrue, reason: t.name);
    }
    expect(() => s.record(AttendanceEventType.workIn), throwsA(isA<SelfieRequired>()));
  });

  test('admin setting can limit photos to work-in', () async {
    h.api.selfieEvents = ['work_in'];
    await h.signIn();
    final s = h.read(attendanceServiceProvider);
    expect(s.needsSelfie(AttendanceEventType.workIn), isTrue);
    expect(s.needsSelfie(AttendanceEventType.breakStart), isFalse);
  });

  test('offline: events wait for their photos, then reach the server in order with selfieMediaId', () async {
    await h.signIn();
    final s = h.read(attendanceServiceProvider);
    final db = h.read(databaseProvider);
    h.api.offline = true;
    await s.record(AttendanceEventType.workIn, selfie: testJpeg());
    h.clock.advance(const Duration(hours: 2));
    await s.record(AttendanceEventType.breakStart, selfie: testJpeg());

    // On duty locally right away, even though nothing is sent yet.
    final ob = await (db.select(db.outbox)..where((t) => t.entity.equals('attendance_event'))).get();
    expect(ob.map((o) => o.state), everyElement('held'));
    expect(await h.read(outboxReaderProvider).unsyncedCount(), greaterThanOrEqualTo(4), reason: '2 events + 2 photos');

    await Future<void>.delayed(const Duration(milliseconds: 50));
    h.api.offline = false;
    h.clock.advance(const Duration(minutes: 30));
    await h.read(mediaServiceProvider).uploadPending();
    await h.read(syncEngineProvider).syncNow();

    final sent = [for (final o in ob) h.api.appliedPayloads[o.mutationId]];
    expect(sent.every((p) => p != null && p['selfieMediaId'] != null), isTrue);
    expect([for (final p in sent) p!['type']], ['work_in', 'break_start']);
    final after = await (db.select(db.outbox)..where((t) => t.entity.equals('attendance_event'))).get();
    expect(after.map((o) => o.state), everyElement('done'));
  });
}
