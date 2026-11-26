import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/location/tracking/tracking_token.dart';
import 'package:staff_app/core/media/media.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/attendance.dart';
import 'package:staff_app/features/auth/auth.dart';
import 'package:staff_app/features/location/location.dart';

import 'helpers.dart';

/// FR-M-076 (contract 1.49.0): the native service uploads with a long-lived tracking token that Dart obtains at
/// duty start, renews on app open when it runs out within 12 h (or was refused), and clears at duty end / logout.
void main() {
  const channel = MethodChannel('com.howlader.staff/permissions');
  late Harness h;
  late List<MethodCall> calls;
  var authFailed = false;

  setUp(() {
    h = Harness();
    calls = [];
    authFailed = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (c) async {
      calls.add(c);
      return switch (c.method) {
        'isTrackingAuthFailed' => authFailed,
        'isNativeTrackingRunning' => true,
        'readBufferedPoints' => '[]',
        _ => true,
      };
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  LocationTracker tracker() => h.read(locationTrackerProvider);
  List<MethodCall> stored() => calls.where((c) => c.method == 'storeTrackingCredentials').toList();
  Future<void> idle() => Future<void>.delayed(const Duration(milliseconds: 50));

  Future<void> workIn() async {
    await h.read(attendanceServiceProvider).record(AttendanceEventType.workIn, selfie: testJpeg());
    await tracker().reconcile(onDuty: true);
    await idle();
  }

  test('duty start: a tracking token is fetched and handed to the native service (never the access token)', () async {
    await h.signIn();
    await workIn();
    expect(h.api.trackingTokenRequests, hasLength(1));
    final args = stored().last.arguments as Map;
    expect(args['trackingToken'], h.api.trackingTokenRequests.single);
    expect(args['trackingToken'], startsWith('trk_'));
    expect(args.containsKey('accessToken'), isFalse);
    expect(args['expiresAtMs'], h.clock.nowUtc().add(const Duration(hours: 24)).millisecondsSinceEpoch);
    expect(args['reauthText'], isNotEmpty);
    expect((await h.read(trackingTokenStoreProvider).read())!.token, args['trackingToken']);
  });

  test('app open: kept while more than 12 h are left, renewed when less', () async {
    await h.signIn();
    await workIn();
    await tracker().onAppResumed();
    expect(h.api.trackingTokenRequests, hasLength(1), reason: '24 h left');

    h.clock.advance(const Duration(hours: 13));
    await tracker().onAppResumed();
    expect(h.api.trackingTokenRequests, hasLength(2), reason: '11 h left');
    expect((stored().last.arguments as Map)['trackingToken'], endsWith('fake2'));
  });

  test('a refused token (native 401) is renewed at once on app open', () async {
    await h.signIn();
    await workIn();
    authFailed = true;
    await tracker().onAppResumed();
    expect(h.api.trackingTokenRequests, hasLength(2));
  });

  test('offline at app open: the old token stays with the native service', () async {
    await h.signIn();
    await workIn();
    h.clock.advance(const Duration(hours: 20));
    h.api.offline = true;
    await tracker().onAppResumed();
    expect((await h.read(trackingTokenStoreProvider).read())!.token, endsWith('fake1'));
    expect((stored().last.arguments as Map)['trackingToken'], endsWith('fake1'));
  });

  test('duty end clears the token on both sides and nothing is fetched off duty', () async {
    await h.signIn();
    await workIn();
    await tracker().reconcile(onDuty: false);
    await idle();
    expect(calls.map((c) => c.method), contains('clearTrackingCredentials'));
    expect(await h.read(trackingTokenStoreProvider).read(), isNull);
    await tracker().onAppResumed();
    await tracker().ensureTrackingToken(force: true);
    expect(h.api.trackingTokenRequests, hasLength(1));
  });

  test('logout clears the token and stops the native service', () async {
    await h.signIn();
    await workIn();
    // Logout is refused while something is unsent: send the work-in (and its photo) first.
    h.clock.advance(const Duration(minutes: 1));
    await h.read(mediaServiceProvider).uploadPending();
    await h.read(syncEngineProvider).syncNow();
    calls.clear();
    await h.read(sessionProvider.notifier).logout();
    expect(h.read(sessionProvider).stage, SessionStage.signedOut);
    expect(await h.read(trackingTokenStoreProvider).read(), isNull);
    expect(calls.map((c) => c.method), containsAll(['stopNativeTracking', 'clearTrackingCredentials']));
  });

  group('rules', () {
    final now = DateTime.utc(2026, 11, 26, 4);
    test('renewal threshold is 12 h', () {
      expect(trackingTokenNeedsRenewal(null, now), isTrue);
      expect(trackingTokenNeedsRenewal(TrackingToken(token: 't', expiresAt: now.add(const Duration(hours: 13))), now), isFalse);
      expect(trackingTokenNeedsRenewal(TrackingToken(token: 't', expiresAt: now.add(const Duration(hours: 12))), now), isTrue);
      expect(trackingTokenNeedsRenewal(TrackingToken(token: 't', expiresAt: now.subtract(const Duration(minutes: 1))), now), isTrue);
    });

    test('token round-trips through the store format', () {
      final t = TrackingToken(token: 'abc', expiresAt: now);
      final back = TrackingToken.tryParse('{"token":"abc","expiresAt":"${now.toIso8601String()}"}')!;
      expect(back.token, t.token);
      expect(back.expiresAt, t.expiresAt);
      expect(TrackingToken.tryParse('garbage'), isNull);
    });

    test('tracking issue: never off duty; worst first; unknown is no problem', () {
      const ok = DeviceTrackingProbe(nativeRunning: true, authFailed: false, batteryOptimised: false);
      expect(trackingIssueFor(onDuty: false, locationOn: true, trackerRunning: false, probe: const DeviceTrackingProbe(nativeRunning: false)), isNull);
      expect(trackingIssueFor(onDuty: true, locationOn: false, trackerRunning: false, probe: ok), isNull);
      expect(trackingIssueFor(onDuty: true, locationOn: true, trackerRunning: true, probe: ok), isNull);
      expect(trackingIssueFor(onDuty: true, locationOn: true, trackerRunning: true, probe: const DeviceTrackingProbe()), isNull);
      expect(trackingIssueFor(onDuty: true, locationOn: true, trackerRunning: false, probe: ok), TrackingIssue.notRunning);
      expect(trackingIssueFor(onDuty: true, locationOn: true, trackerRunning: true, probe: const DeviceTrackingProbe(nativeRunning: false, batteryOptimised: true)), TrackingIssue.notRunning);
      expect(trackingIssueFor(onDuty: true, locationOn: true, trackerRunning: true, probe: const DeviceTrackingProbe(authFailed: true, batteryOptimised: true)), TrackingIssue.authRefused);
      expect(trackingIssueFor(onDuty: true, locationOn: true, trackerRunning: true, probe: const DeviceTrackingProbe(batteryOptimised: true)), TrackingIssue.batteryOptimised);
    });

    test('phone brand → guide', () {
      expect(oemBrandFor('Xiaomi'), OemBrandId.xiaomi);
      expect(oemBrandFor('Redmi'), OemBrandId.xiaomi);
      expect(oemBrandFor('OPPO'), OemBrandId.oppo);
      expect(oemBrandFor('realme'), OemBrandId.oppo);
      expect(oemBrandFor('vivo'), OemBrandId.vivo);
      expect(oemBrandFor('samsung'), OemBrandId.samsung);
      expect(oemBrandFor('Google'), OemBrandId.other);
      expect(oemBrandFor(null), OemBrandId.other);
    });
  });
}
