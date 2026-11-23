import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/features/reports/reports.dart';

import 'helpers.dart';

/// FR-M-071: the leaderboard has its own line in the Me tab while `reports.leaderboardVisibleToStaff` is on.
void main() {
  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 8; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<Harness> openMe(WidgetTester t, {required bool visible}) async {
    final h = Harness();
    h.api.leaderboardVisible = visible;
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 2400) * 2; // the whole Me list is built (a sliver list builds only what shows)
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    h.read(routerProvider).go('/me');
    await settle(t);
    return h;
  }

  testWidgets('setting on: a Leaderboard entry in the Me list opens the board', (t) async {
    final h = await openMe(t, visible: true);
    final entry = find.byType(LeaderboardMeEntry, skipOffstage: false);
    expect(entry, findsOneWidget);
    await t.ensureVisible(entry);
    await settle(t);
    expect(t.getSize(find.descendant(of: entry, matching: find.byType(ListTile))).height, greaterThanOrEqualTo(48));
    await t.tap(entry);
    await settle(t);
    expect(h.read(routerProvider).state.uri.path, '/leaderboard');
  });

  testWidgets('setting off: no Leaderboard entry anywhere in Me', (t) async {
    await openMe(t, visible: false);
    expect(find.byType(LeaderboardMeEntry, skipOffstage: false), findsNothing);
    expect(find.text('লিডারবোর্ড', skipOffstage: false), findsNothing);
  });
}
