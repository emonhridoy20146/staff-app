import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/location/tracking/tracking_provider.dart';
import 'package:staff_app/core/permissions/permission_service.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/attendance.dart';
import 'package:staff_app/features/customers/customers.dart';
import 'package:staff_app/features/location/location.dart';

import 'helpers.dart';

void main() {
  late Harness h;
  late FakeTrackingProvider free;
  late FakeTrackingProvider paid;

  void build({bool paidCompiled = false}) {
    h = Harness();
    final all = h.read(trackingProvidersProvider);
    free = all.firstWhere((p) => p.id == 'free') as FakeTrackingProvider;
    paid = all.firstWhere((p) => p.id == 'paid') as FakeTrackingProvider..isAvailable = paidCompiled;
  }

  tearDown(() async {
    // Let fire-and-forget sync kicks / flushes finish before the DB closes.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  LocationTracker tracker() => h.read(locationTrackerProvider);
  Future<int> queued() async => (await h.read(databaseProvider).select(h.read(databaseProvider).locationQueue).get()).length;
  RawLocation pt(int sec, {double lat = 22.7010, double lng = 90.3535}) =>
      RawLocation(t: h.clock.nowUtc().add(Duration(seconds: sec)), lat: lat, lng: lng, acc: 8);

  Future<void> workIn() async {
    await h.read(attendanceServiceProvider).record(AttendanceEventType.workIn);
    await tracker().reconcile(onDuty: true);
  }

  test('does not track off duty and stores nothing', () async {
    build();
    await h.signIn();
    await tracker().reconcile(onDuty: false);
    expect(free.isRunning, isFalse);
    free.emit(pt(0));
    await tracker().handle(pt(0));
    expect(await queued(), 0);
  });

  test('tracks on duty, queues points, uploads and deletes only confirmed rows', () async {
    build();
    await h.signIn();
    await workIn();
    expect(free.isRunning, isTrue);
    expect(h.read(trackingStatusProvider).providerId, 'free');
    await tracker().handle(pt(0));
    await tracker().handle(pt(30, lat: 22.7013));
    expect(await queued(), 2);

    h.api.offline = true;
    await tracker().uploadPending();
    expect(await queued(), 2, reason: 'offline: points stay');

    h.api.offline = false;
    await tracker().uploadPending();
    expect(await queued(), 0);
    expect(h.api.locationPoints, hasLength(2));
    expect(h.api.locationPoints.first['lat'], 22.7010);
  });

  test('stops at work-out', () async {
    build();
    await h.signIn();
    await workIn();
    await tracker().reconcile(onDuty: false);
    expect(free.isRunning, isFalse);
    expect(h.read(trackingStatusProvider).running, isFalse);
  });

  test('stays off when module.location is off', () async {
    build();
    await h.signIn();
    h.read(accessProvider.notifier).set(flags: {...h.read(accessProvider).flags, 'module.location': false});
    await tracker().reconcile(onDuty: true);
    expect(free.isRunning, isFalse);
  });

  test('admin chooses paid: falls back to free when not in this build, heartbeat says so', () async {
    build();
    h.api.trackingProvider = 'paid';
    await h.signIn();
    expect(h.read(serverSettingsProvider)['location.trackingProvider'], 'paid');
    await workIn();
    expect(free.isRunning, isTrue);
    expect(h.read(trackingStatusProvider).fellBack, isTrue);
    await tracker().sendHeartbeat();
    expect(h.api.heartbeats.last['trackingProvider'], 'free');
    expect(h.api.heartbeats.last['trackingProviderFallback'], true);
  });

  test('admin switches to paid at runtime when the build has it', () async {
    build(paidCompiled: true);
    await h.signIn();
    await workIn();
    expect(free.isRunning, isTrue);
    h.read(serverSettingsProvider.notifier).state = {...h.read(serverSettingsProvider), 'location.trackingProvider': 'paid'};
    await tracker().reconcile(onDuty: true);
    expect(free.isRunning, isFalse);
    expect(paid.isRunning, isTrue);
    expect(h.read(trackingStatusProvider).providerId, 'paid');
  });

  test('queue cap drops the oldest stationary points first', () async {
    build();
    await h.signIn();
    final db = h.read(databaseProvider);
    final t0 = h.clock.nowUtc().subtract(const Duration(days: 1));
    await db.batch((b) {
      for (var i = 0; i < 20000; i++) {
        b.insert(db.locationQueue, LocationQueueCompanion.insert(t: t0.add(Duration(seconds: i)), lat: 22.7, lng: 90.35, acc: 5, act: Value(i < 10 ? 'still' : 'walking')));
      }
    });
    await workIn();
    await tracker().handle(pt(0));
    expect(await queued(), 20000);
    final still = await (db.select(db.locationQueue)..where((t) => t.act.equals('still'))).get();
    expect(still, hasLength(9));
  });

  test('suggests a visit after 5 minutes near an unvisited customer pin', () async {
    build();
    await h.signIn();
    final c = (await h.read(customerRepositoryProvider).watchAll().first).firstWhere((c) => c.hasPin);
    await workIn();
    final lat = c.row.lat!, lng = c.row.lng!;
    await tracker().handle(RawLocation(t: h.clock.nowUtc().subtract(const Duration(minutes: 6)), lat: lat, lng: lng, acc: 8));
    await tracker().handle(RawLocation(t: h.clock.nowUtc(), lat: lat + 0.0001, lng: lng, acc: 8));
    expect(h.read(visitSuggestionProvider)?.customerId, c.id);
    tracker().dismissSuggestion();
    expect(h.read(visitSuggestionProvider), isNull);
  });
}
