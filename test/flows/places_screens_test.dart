import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/places/src/places_ui.dart';

import 'helpers.dart';

/// Map places on screen (master FR-PLC-001..004): long-press the map to add one, its name stays next to
/// the marker, my own place can be edited, a colleague's can only be asked to move.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 8}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<Harness> start(WidgetTester t, {double textScale = 1}) async {
    final h = Harness();
    h.api.addPlace('pl-9', name: 'নতুন বাজার', icon: 'market', lat: 22.7072, lng: 90.3452, by: const {'id': 'u-fs-002', 'name': 'সুমন মিয়া'});
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    t.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(t.view.reset);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    await t.tap(find.text('ম্যাপ').first);
    await settle(t);
    return h;
  }

  testWidgets('a colleague\'s place shows with its name; long-press adds mine, which I may edit', (t) async {
    await start(t);
    expect(find.byType(PlaceMarker), findsOneWidget);
    expect(find.text('নতুন বাজার'), findsOneWidget); // the label is always shown

    // Long-press the map → the sheet; a name is required.
    await t.longPress(find.byType(FlutterMap));
    await settle(t);
    expect(find.text('ম্যাপে নতুন জায়গা'), findsOneWidget);
    await t.ensureVisible(find.byKey(const Key('place-save')));
    await settle(t, rounds: 2);
    await t.tap(find.byKey(const Key('place-save')));
    await settle(t);
    await t.ensureVisible(find.byKey(const Key('place-name')));
    await settle(t, rounds: 2);
    expect(find.text('একটি নাম লিখুন'), findsOneWidget);
    await t.enterText(find.byKey(const Key('place-name')), 'আলিফ মডেল স্কুল');
    await t.ensureVisible(find.byKey(const Key('place-icon-school')));
    await t.tap(find.byKey(const Key('place-icon-school')));
    await t.enterText(find.byKey(const Key('place-note')), 'মসজিদের পেছনের গলি');
    await t.ensureVisible(find.byKey(const Key('place-save')));
    await t.tap(find.byKey(const Key('place-save')));
    await settle(t);
    expect(find.byType(PlaceMarker), findsNWidgets(2));
    expect(find.text('আলিফ মডেল স্কুল'), findsWidgets);

    // Every place marker is a ≥ 48 dp target.
    for (final e in find.byType(PlaceMarker).evaluate()) {
      expect(t.getSize(find.byWidget(e.widget)).height, greaterThanOrEqualTo(48));
    }

    // Mine: edit is offered.
    await t.tap(find.widgetWithText(PlaceMarker, 'আলিফ মডেল স্কুল'));
    await settle(t);
    expect(find.text('আপনি এই জায়গাটি যোগ করেছেন'), findsOneWidget);
    expect(find.byKey(const Key('place-edit')), findsOneWidget);
    expect(find.text('মসজিদের পেছনের গলি'), findsOneWidget);
    await t.tapAt(const Offset(200, 60)); // close the sheet
    await settle(t);

    // A colleague's: no edit, but I can ask to move it.
    await t.tap(find.widgetWithText(PlaceMarker, 'নতুন বাজার'));
    await settle(t);
    expect(find.text('যোগ করেছেন সুমন মিয়া'), findsOneWidget);
    expect(find.byKey(const Key('place-edit')), findsNothing);
    expect(find.byKey(const Key('place-move')), findsOneWidget);
  });

  testWidgets('ask to move: the map moves under the pin, the request waits for the office', (t) async {
    final h = await start(t);
    await t.tap(find.widgetWithText(PlaceMarker, 'নতুন বাজার'));
    await settle(t);
    await t.tap(find.byKey(const Key('place-move')));
    await settle(t);
    expect(find.text('নতুন বাজার সরান'), findsOneWidget);
    // Not moved yet: sending is not possible.
    expect(t.widget<FilledButton>(find.ancestor(of: find.text('আগে ম্যাপ সরান'), matching: find.byWidgetPredicate((w) => w is FilledButton))).onPressed, isNull);
    await t.drag(find.byType(FlutterMap).last, const Offset(-120, 80));
    await settle(t);
    await t.enterText(find.byKey(const Key('place-move-reason')), 'মূল গেট রাস্তার ওপারে');
    await t.tap(find.byKey(const Key('place-move-send')));
    await settle(t, rounds: 12);
    final db = h.read(databaseProvider);
    final row = await t.runAsync(() => db.select(db.mapPlaces).getSingle());
    expect(row!.lat, 22.7072); // the marker stays where it was
    expect(row.moveReason ?? row.pendingMoveJson, isNotNull);
  });

  testWidgets('labels and sheet still fit at 130 % text (FR-M accessibility)', (t) async {
    await start(t, textScale: 1.3);
    expect(find.text('নতুন বাজার'), findsOneWidget);
    await t.longPress(find.byType(FlutterMap));
    await settle(t);
    expect(find.text('ম্যাপে নতুন জায়গা'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
