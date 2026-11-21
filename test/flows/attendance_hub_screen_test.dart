import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';

import 'helpers.dart';

/// FR-M-040 / plan item 3.1: the attendance hub screen (the page before
/// work-in) shows today's state and changes with the day's events.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 10}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<Harness> open(WidgetTester t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    h.read(routerProvider).go('/attendance');
    await settle(t);
    return h;
  }

  Future<void> close(WidgetTester t, Harness h) async {
    await t.pumpWidget(const SizedBox.shrink());
    h.container.dispose();
    await t.pump(const Duration(milliseconds: 50));
  }

  testWidgets('before work-in the hub says the day has not started and has a history section', (t) async {
    final h = await open(t);
    expect(find.text('উপস্থিতি'), findsWidgets);
    expect(find.text('শুরু হয়নি'), findsWidgets);
    expect(find.text('কর্মরত'), findsNothing);
    expect(find.text('উপস্থিতির ইতিহাস'), findsOneWidget);
    expect(t.takeException(), isNull);
    await close(t, h);
  });
  // The on-duty state after a work-in is covered by the flow tests; recording one inside
  // a widget test's fake clock waits forever for the location fix.
}
