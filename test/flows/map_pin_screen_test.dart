import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/providers.dart';

import 'helpers.dart';

/// The ride-app style pin screen (FR-CUS-011): the map moves under a fixed
/// pin, typed coordinates jump there, and "Set pin" saves a map proposal.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 10}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  final coords = find.byWidgetPredicate((w) => w is Text && RegExp(r'^\d+\.\d{5}, \d+\.\d{5}$').hasMatch(w.data ?? ''));
  String shown(WidgetTester t) => t.widget<Text>(coords).data!;

  testWidgets('drag the map, type coordinates, set the pin of a customer without a location', (t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    h.read(routerProvider).go('/customers/c-1010');
    await settle(t);
    await t.tap(find.text('লোকেশন দিন').first);
    await settle(t);

    expect(find.byType(FlutterMap), findsOneWidget);
    final start = shown(t);
    await t.drag(find.byType(FlutterMap), const Offset(-120, 80));
    await settle(t, rounds: 4);
    expect(shown(t), isNot(start), reason: 'the point under the pin follows the map');

    // Coordinates shared by the customer, longitude first by mistake.
    await t.tap(find.byIcon(Icons.edit_location_alt_rounded));
    await settle(t, rounds: 3);
    await t.enterText(find.byType(TextField).last, 'nonsense');
    await t.tap(find.text('যান'));
    await settle(t, rounds: 3);
    expect(find.text('এই কো-অর্ডিনেট পড়া যায়নি।'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, '90.36002, 22.71001');
    await t.tap(find.text('যান'));
    await settle(t, rounds: 4);
    expect(shown(t), '22.71001, 90.36002');
    expect(find.text('এই কাস্টমারের লোকেশন নেই: পাঠানোর সাথে সাথে পিন বসে যাবে।'), findsOneWidget);

    await t.tap(find.text('পিন বসান'));
    await settle(t);
    expect(find.byType(FlutterMap), findsNothing, reason: 'back on the customer');
    final rows = await t.runAsync(() {
      final db = h.read(databaseProvider);
      return db.select(db.locationProposals).get();
    });
    expect(rows!.single.customerId, 'c-1010');
    expect(rows.single.method, 'map');
    expect(rows.single.lat, closeTo(22.71001, 1e-6));
    expect(rows.single.lng, closeTo(90.36002, 1e-6));
    expect(rows.single.deviceGeoJson, isNotNull, reason: 'where the phone was goes along');

    await t.pumpWidget(const SizedBox.shrink());
    h.container.dispose();
    await t.pump(const Duration(milliseconds: 50));
  });
}
