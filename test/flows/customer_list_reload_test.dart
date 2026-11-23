import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/core/location/gps_status.dart';
import 'package:staff_app/core/ui/chips.dart';

import 'helpers.dart';

/// FR-M-032 (2026-11-19 owner request): the customer list says when nothing is on the phone yet,
/// whether the load failed, and can be reloaded by hand (button or pull down).
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 8}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('empty phone: reload button, failure message with its code, and a reload that brings the branch back', (t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);

    final db = h.read(databaseProvider);
    await t.runAsync(() => db.delete(db.customers).go());
    await t.tap(find.text('গ্রাহক').last);
    await settle(t);
    expect(find.text('এই ফোনে এখনও কোনো গ্রাহক নেই'), findsOneWidget);
    expect(find.byTooltip('গ্রাহক আবার লোড করুন'), findsOneWidget);

    // No network: the screen says the load failed instead of staying blank.
    h.api.offline = true;
    await t.tap(find.text('গ্রাহক আবার লোড করুন'));
    await settle(t);
    expect(find.text('গ্রাহক লোড করা যায়নি'), findsOneWidget);

    // Back online and the server asks for a fresh snapshot: reload fills the list again.
    h.api.offline = false;
    h.api.expireCursor = true;
    await t.tap(find.byTooltip('গ্রাহক আবার লোড করুন'));
    await settle(t, rounds: 12);
    h.api.expireCursor = false;
    expect(find.text('গ্রাহক লোড করা যায়নি'), findsNothing);
    expect(find.text('এই ফোনে এখনও কোনো গ্রাহক নেই'), findsNothing);
    expect(await t.runAsync(() => db.select(db.customers).get()), isNotEmpty);
  });

  testWidgets('online / offline mark in the top bar on every tab, left of the GPS icon, not at the bottom', (t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    Finder strip(String text) => find.descendant(of: find.byType(OnlineDot), matching: find.text(text));
    expect(strip('অনলাইন'), findsOneWidget);
    // Owner request 2026-11-23: in the top bar just left of the GPS icon; nothing above the bottom navigation.
    final dot = t.getRect(find.byType(OnlineDot));
    final gps = t.getRect(find.byType(GpsStatusIcon));
    expect(dot.right, lessThanOrEqualTo(gps.left + 1));
    expect((dot.center.dy - gps.center.dy).abs(), lessThan(4));
    expect(dot.bottom, lessThan(t.getRect(find.byType(NavigationBar)).top - 400));

    h.read(syncEngineProvider).markOffline();
    await settle(t, rounds: 2);
    expect(strip('অফলাইন'), findsOneWidget);
    expect(strip('অনলাইন'), findsNothing);

    // Another tab: still shown.
    await t.tap(find.text('গ্রাহক').last);
    await settle(t, rounds: 2);
    expect(strip('অফলাইন'), findsOneWidget);
  });

  testWidgets('opening the Customers tab with nothing on the phone loads the branch by itself', (t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    final db = h.read(databaseProvider);
    await t.runAsync(() => db.delete(db.customers).go());
    h.api.expireCursor = true; // the server asks for a fresh snapshot, as after the 1.20.1 resync floor
    await t.tap(find.text('গ্রাহক').last);
    await settle(t, rounds: 12);
    h.api.expireCursor = false;
    expect(await t.runAsync(() => db.select(db.customers).get()), isNotEmpty);
    expect(find.text('এই ফোনে এখনও কোনো গ্রাহক নেই'), findsNothing);
  });

  testWidgets('while a load is running the list says customers are still coming, with the count so far', (t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    await t.tap(find.text('গ্রাহক').last);
    await settle(t);
    expect(find.textContaining('গ্রাহক লোড হচ্ছে…'), findsNothing);

    h.api.latency = const Duration(milliseconds: 600);
    h.api.expireCursor = true;
    await t.tap(find.byTooltip('গ্রাহক আবার লোড করুন'));
    // the pull answers "take a fresh snapshot" after one round trip; the snapshot is then on its way
    var seen = false;
    for (var i = 0; i < 30 && !seen; i++) {
      await settle(t, rounds: 1);
      seen = find.textContaining('গ্রাহক লোড হচ্ছে…').evaluate().isNotEmpty;
    }
    expect(seen, isTrue);
    h.api.expireCursor = false;
    h.api.latency = Duration.zero;
    await settle(t, rounds: 20);
    expect(find.textContaining('গ্রাহক লোড হচ্ছে…'), findsNothing);
  });
}
