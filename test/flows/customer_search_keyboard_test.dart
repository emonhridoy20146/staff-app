import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/src/presentation/customer_tile.dart';

import 'helpers.dart';

/// FR-M-032 (owner report 2026-11-22): with the search field focused and the
/// keyboard open, the filtered customers stay visible between the field and
/// the keyboard — no blank band over them.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 8}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('keyboard open: a filtered customer row sits above the keyboard and can be tapped', (t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    const dpr = 2.0;
    t.view.physicalSize = const Size(412, 892) * dpr;
    t.view.devicePixelRatio = dpr;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    await t.tap(find.text('গ্রাহক').last);
    await settle(t);

    final db = h.read(databaseProvider);
    final rows = await t.runAsync(() => db.select(db.customers).get());
    expect(rows, isNotEmpty);
    final name = rows!.first.nameBn;

    // Focus the search field and open a 320 dp keyboard.
    await t.tap(find.byType(TextField));
    const keyboard = 320.0;
    t.view.viewInsets = const FakeViewPadding(bottom: keyboard * dpr);
    await t.enterText(find.byType(TextField), name);
    await settle(t, rounds: 4);

    final row = find.widgetWithText(CustomerTile, name).first;
    expect(row, findsOneWidget);
    final field = t.getRect(find.byType(TextField));
    final rowRect = t.getRect(row);
    const keyboardTop = 892 - keyboard;
    // Below the search field, fully above the keyboard.
    expect(rowRect.top, greaterThanOrEqualTo(field.bottom));
    expect(rowRect.bottom, lessThanOrEqualTo(keyboardTop));
    // The list reaches down to the keyboard: no blank band between them.
    final list = t.getRect(find.byType(ListView).last);
    expect(list.bottom, closeTo(keyboardTop, 1));
    // Nothing covers it: a tap at its centre lands on the row.
    expect(row.hitTestable(), findsOneWidget);
  });
}
