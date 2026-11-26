import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/attendance.dart';
import 'package:staff_app/features/location/location.dart';

import 'helpers.dart';

class _Probe implements TrackingProbe {
  _Probe(this.value);
  DeviceTrackingProbe value;
  @override
  Future<DeviceTrackingProbe> read() async => value;
}

/// FR-M-078: a clear in-app status when tracking is not healthy on duty, never off duty; the set-up screen.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 10}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> done(WidgetTester t, Harness h) async {
    await t.pumpWidget(const SizedBox.shrink());
    h.container.dispose();
    await t.pump(const Duration(milliseconds: 50));
  }

  Future<(Harness, _Probe)> start(WidgetTester t, {required bool onDuty, required DeviceTrackingProbe probe}) async {
    final p = _Probe(probe);
    final h = Harness(extra: [trackingProbeProvider.overrideWithValue(p)]);
    await t.runAsync(() async {
      await h.signIn();
      if (onDuty) {
        await h.read(attendanceServiceProvider).record(AttendanceEventType.workIn, fix: await h.read(locationEngineProvider).currentFix(), selfie: testJpeg());
      }
    });
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    return (h, p);
  }

  testWidgets('on duty with the native service stopped: a danger line on Today opens the set-up', (t) async {
    final (h, _) = await start(t, onDuty: true, probe: const DeviceTrackingProbe(nativeRunning: false, batteryOptimised: true, manufacturer: 'Xiaomi'));
    final banner = find.byKey(const Key('tracking-health-banner'));
    expect(banner, findsOneWidget);
    expect(find.text('ডিউটিতে আছেন, কিন্তু লাইভ লোকেশন চলছে না। ঠিক করতে চাপুন।'), findsOneWidget);

    await t.ensureVisible(banner);
    await t.pump();
    await t.tap(banner);
    await settle(t, rounds: 4);
    expect(h.read(routerProvider).routerDelegate.currentConfiguration.last.matchedLocation, '/location/background-setup');
    expect(find.text('ব্যাকগ্রাউন্ডে লোকেশন'), findsOneWidget);
    expect(find.text('অনুমতি নেই'), findsOneWidget); // battery optimised
    expect(find.textContaining('Xiaomi'), findsWidgets); // the detected brand's steps
    expect(find.byKey(const Key('tracking-setup-battery')), findsOneWidget);
    expect(find.byKey(const Key('tracking-setup-oem')), findsOneWidget);
    expect(find.descendant(of: find.byType(TrackingSetupScreen), matching: find.byType(RefreshIndicator)), findsOneWidget);
    await done(t, h);
  });

  testWidgets('battery optimised while tracking runs: a warning line', (t) async {
    final (h, _) = await start(t, onDuty: true, probe: const DeviceTrackingProbe(nativeRunning: true, batteryOptimised: true));
    // The fake tracking provider runs in tests; only the battery is a problem.
    expect(find.text('ব্যাটারি সেভার লাইভ লোকেশন বন্ধ করে দিতে পারে। অনুমতি দিতে চাপুন।'), findsOneWidget);
    await done(t, h);
  });

  testWidgets('off duty: no tracking line at all, whatever the phone says', (t) async {
    final (h, _) = await start(t, onDuty: false, probe: const DeviceTrackingProbe(nativeRunning: false, batteryOptimised: true));
    expect(find.byKey(const Key('tracking-health-banner')), findsNothing);
    await done(t, h);
  });
}
