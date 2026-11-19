import 'dart:convert';

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

  test('master switch off: no photo needed at any event', () async {
    h.api.selfieRequired = false;
    await h.signIn();
    final s = h.read(attendanceServiceProvider);
    for (final t in AttendanceEventType.values) {
      expect(s.needsSelfie(t), isFalse, reason: t.name);
    }
    await s.record(AttendanceEventType.workIn);
  });

  test('events go at once, never waiting for their photos; photos are linked after them (ADR-M19)', () async {
    await h.signIn();
    final s = h.read(attendanceServiceProvider);
    final db = h.read(databaseProvider);
    h.api.offline = true;
    await s.record(AttendanceEventType.workIn, selfie: testJpeg());
    h.clock.advance(const Duration(hours: 2));
    await s.record(AttendanceEventType.breakStart, selfie: testJpeg());

    // On duty locally right away; nothing is held for a photo.
    final ob = await (db.select(db.outbox)..where((t) => t.entity.equals('attendance_event'))).get();
    expect(ob.map((o) => o.state), everyElement('pending'));
    expect(await h.read(outboxReaderProvider).unsyncedCount(), greaterThanOrEqualTo(4), reason: '2 events + 2 photos');

    // Back online, but the photos cannot upload: attendance still reaches the server, in order.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    h.api.offline = false;
    h.api.uploadsFail = true;
    await h.read(mediaServiceProvider).uploadPending();
    await h.read(syncEngineProvider).syncNow();
    final sent = [for (final o in ob) h.api.appliedPayloads[o.mutationId]];
    expect([for (final p in sent) p?['type']], ['work_in', 'break_start']);
    expect(sent.every((p) => p!['selfieMediaId'] == null), isTrue);
    expect((await (db.select(db.outbox)..where((t) => t.entity.equals('attendance_event'))).get()).map((o) => o.state), everyElement('done'));

    // The photos upload later and are linked to their events, once each.
    h.api.uploadsFail = false;
    h.clock.advance(const Duration(minutes: 30));
    await h.read(mediaServiceProvider).uploadPending();
    await h.read(mediaServiceProvider).uploadPending();
    await h.read(syncEngineProvider).syncNow();
    final links = await (db.select(db.outbox)..where((t) => t.entity.equals('attendance_selfie'))).get();
    expect(links, hasLength(2));
    expect(links.map((l) => l.state), everyElement('done'));
    final linked = [for (final l in links) h.api.appliedPayloads[l.mutationId]!];
    expect(linked.map((p) => p['eventClientId']).toSet(), ob.map((o) => o.mutationId).toSet());
    expect(linked.every((p) => p['selfieMediaId'] != null), isTrue);
    expect(links.every((l) => l.dependsOnJson.contains((jsonDecode(l.payloadJson) as Map<String, Object?>)['eventClientId']! as String)), isTrue);
  });

  test('a work-in an older app held for its photo is sent at start-up, then gets its photo', () async {
    await h.signIn();
    final db = h.read(databaseProvider);
    final outbox = h.read(outboxWriterProvider);
    await outbox.enqueue(mutationId: '0192a000-0000-7000-8000-000000000001', entity: 'attendance_event', held: true, payload: {'clientId': '0192a000-0000-7000-8000-000000000001', 'type': 'work_in', 'at': h.clock.nowUtc().toIso8601String()});
    expect(await releaseHeldAttendance(db), 1);
    await h.read(syncEngineProvider).syncNow();
    expect(h.api.appliedPayloads['0192a000-0000-7000-8000-000000000001']?['type'], 'work_in');
    await linkAttendanceSelfie(outbox, db, '0192a000-0000-7000-8000-000000000001', ['m-1']);
    final links = await (db.select(db.outbox)..where((t) => t.entity.equals('attendance_selfie'))).get();
    expect(jsonDecode(links.single.payloadJson), {'eventClientId': '0192a000-0000-7000-8000-000000000001', 'selfieMediaId': 'm-1'});
  });
}
