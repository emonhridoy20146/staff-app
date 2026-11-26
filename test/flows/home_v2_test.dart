import 'dart:math' as math;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/permissions/permission_service.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/customers.dart';
import 'package:staff_app/features/notices/src/notices_data.dart' show unreadNoticesProvider;
import 'package:staff_app/features/notices/src/notices_screens.dart' show NoticesTodayBanner;
import 'package:staff_app/features/today/today.dart';

import 'helpers.dart';

/// Home v2 (owner request 2026-11-26): filter chips with counts over the work list (FR-M-082), the quick-action
/// grid (FR-M-083), and alerts above the shortcuts.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 6}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  /// The whole page on one tall, wide screen, so every row and every chip is on it and nothing needs scrolling.
  Future<Harness> start(WidgetTester t, {Future<void> Function(AppDatabase db)? seed, Size size = const Size(1000, 6400)}) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = size * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    // Seeded before the app starts: a write while the start-up sync holds the database would wait forever.
    if (seed != null) await t.runAsync(() => seed(h.read(databaseProvider)));
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t, rounds: 12);
    return h;
  }

  void setFlags(Harness h, Map<String, bool> change) {
    final a = h.read(accessProvider);
    h.read(accessProvider.notifier).set(flags: {...a.flags, ...change});
  }

  testWidgets('filters: counts match the sections and the summary card; a filter shows only its list; the choice is kept', (t) async {
    final h = await start(t, seed: (db) async {
      for (final (id, code) in [('c-1013', 'absconded'), ('c-1017', 'refused_to_pay')]) {
        await (db.update(db.customers)..where((c) => c.serverId.equals(id))).write(CustomersCompanion(tagState: const Value('tagged'), tagSeverity: const Value('bad'), tagReasonCode: Value(code)));
      }
    });
    expect(h.read(homeScopeUserIdProvider), 'u-fs-014'); // a field staff member: own and unassigned customers
    final w = h.read(homeWorkProvider).value!;
    final p = w.priorities;
    expect(p.overdue.length, greaterThan(8), reason: 'the demo day has more overdue than the All list shows');
    Finder chip(HomeFilter f) => find.byKey(ValueKey('home-filter-${f.name}'));
    String words(HomeFilter f) => (t.widget<FilterChip>(chip(f)).label as Text).textSpan!.toPlainText();
    bool picked(HomeFilter f) => t.widget<FilterChip>(chip(f)).selected;
    int rows() => find.byType(CustomerWorkRow).evaluate().length;
    Finder row(Customer c) => find.byKey(ValueKey('home-row-${c.id}'));
    final card = find.byKey(const Key('today-progress-card'));
    // The chip row scrolls sideways: bring a chip on screen before tapping it.
    Future<void> pick(HomeFilter f) async {
      await t.ensureVisible(chip(f));
      await settle(t, rounds: 2);
      await t.tap(chip(f));
      await settle(t);
    }

    // Each chip carries the number of rows it shows; the summary card shows the same three numbers.
    for (final f in HomeFilter.values) {
      expect(words(f), endsWith('  ${w.count(f)}'), reason: f.name);
      expect(t.getSize(chip(f)).height, greaterThanOrEqualTo(48));
    }
    expect(w.count(HomeFilter.all), p.promised.length + p.due.length + p.overdue.length);
    for (final n in [p.promised.length, p.due.length, p.overdue.length]) {
      expect(find.descendant(of: card, matching: find.text('$n')), findsOneWidget);
    }
    expect(w.badTag.length, 3); // the two tagged here and the demo server's own

    // All: the three sections, overdue cut at 8 with "N more".
    expect(picked(HomeFilter.all), isTrue);
    expect(rows(), p.promised.length + p.due.length + 8);
    expect(find.byKey(const Key('today-more')), findsOneWidget);

    // Overdue: only that list, all of it.
    await pick(HomeFilter.overdue);
    expect(picked(HomeFilter.overdue), isTrue);
    expect(picked(HomeFilter.all), isFalse);
    expect(rows(), p.overdue.length);
    for (final c in p.overdue) {
      expect(row(c), findsOneWidget);
    }
    expect(row(p.promised.first), findsNothing);
    expect(find.byKey(const Key('today-more')), findsNothing);

    // The choice is kept for the session: another tab and back.
    await t.tap(find.text('গ্রাহক').last);
    await settle(t);
    await t.tap(find.text('আজ').last);
    await settle(t);
    expect(picked(HomeFilter.overdue), isTrue);
    expect(rows(), p.overdue.length);

    // "N more" under All opens the Overdue filter in place.
    await pick(HomeFilter.all);
    await t.tap(find.byKey(const Key('today-more')));
    await settle(t);
    expect(picked(HomeFilter.overdue), isTrue);

    // A count in the summary card picks its filter.
    await t.tap(find.descendant(of: card, matching: find.text('${p.due.length}')));
    await settle(t);
    expect(picked(HomeFilter.due), isTrue);
    expect(rows(), p.due.length);

    // Bad tag: every bad-tag customer, each in its frame.
    await pick(HomeFilter.badTag);
    expect(rows(), w.badTag.length);
    expect(find.byKey(const Key('tag-frame')), findsNWidgets(w.badTag.length));

    // Broken promise has nobody today: a calm card with a way back.
    expect(w.count(HomeFilter.brokenPromise), 0);
    await pick(HomeFilter.brokenPromise);
    expect(rows(), 0);
    expect(find.text('এই তালিকায় কেউ নেই'), findsOneWidget);
    await t.tap(find.byKey(const Key('home-filter-show-all')));
    await settle(t);
    expect(picked(HomeFilter.all), isTrue);

    // A filter whose module is turned off is not offered, and a pick of it falls back to All.
    h.read(homeFilterProvider.notifier).pick(HomeFilter.brokenPromise);
    setFlags(h, {'module.promises': false});
    await settle(t);
    expect(chip(HomeFilter.brokenPromise), findsNothing);
    expect(picked(HomeFilter.all), isTrue);
    expect(t.takeException(), isNull);
  });

  testWidgets('on a phone the picked chip is always in sight, however it was picked', (t) async {
    final h = await start(t, size: const Size(360, 780));
    final w = h.read(homeWorkProvider).value!;
    // Off stage too: the chip row starts under the first screen, and some chips sit past its right edge.
    Finder chip(HomeFilter f) => find.byKey(ValueKey('home-filter-${f.name}'), skipOffstage: false);
    bool inSight(HomeFilter f) {
      final r = t.getRect(chip(f));
      return r.left >= 0 && r.right <= 360;
    }

    expect(inSight(HomeFilter.all), isTrue);
    expect(inSight(HomeFilter.badTag), isFalse, reason: 'the chips are wider than the phone');

    // The choice kept for the session is made away from the chips: the picked chip comes into sight.
    h.read(homeFilterProvider.notifier).pick(HomeFilter.badTag);
    await settle(t);
    expect(inSight(HomeFilter.badTag), isTrue);

    // A count in the summary card (on the first screen of a small phone) does the same for its own chip.
    await t.tap(find.descendant(of: find.byKey(const Key('today-progress-card')), matching: find.text('${w.priorities.promised.length}')));
    await settle(t, rounds: 8);
    expect(h.read(homeFilterProvider), HomeFilter.promised);
    expect(inSight(HomeFilter.promised), isTrue);
    expect(inSight(HomeFilter.badTag), isFalse);
    expect(t.takeException(), isNull);
  });

  testWidgets('quick actions: nine equal cells in three rows with state and badges; fewer features reflow to 6 and 3; alerts sit above', (t) async {
    final h = await start(t);
    final grid = find.byKey(const Key('quick-grid'));
    List<String> ids() => [for (final e in find.descendant(of: grid, matching: find.byType(InkWell)).evaluate()) (e.widget.key! as ValueKey<String>).value];
    Finder cell(String id) => find.byKey(ValueKey('quick-$id'));

    expect(ids(), ['quick-attendance', 'quick-today-work', 'quick-cash', 'quick-tasks', 'quick-notices', 'quick-requests', 'quick-prospects', 'quick-performance', 'quick-leave']);
    final sizes = [for (final id in ids()) t.getSize(find.byKey(ValueKey(id)))];
    for (final s in sizes) {
      expect(s.width, moreOrLessEquals(sizes.first.width, epsilon: 0.5));
      expect(s.height, moreOrLessEquals(sizes.first.height, epsilon: 0.5));
      expect(math.min(s.width, s.height), greaterThanOrEqualTo(48));
    }
    expect({for (final id in ids()) t.getTopLeft(find.byKey(ValueKey(id))).dy.round()}.length, 3);

    // Attendance says it is still to give (FR-M-042); notices carry their unread count.
    expect(find.descendant(of: cell('attendance'), matching: find.text('হাজিরা বাকি')), findsOneWidget);
    final unread = h.read(unreadNoticesProvider).length;
    expect(unread, greaterThan(0));
    expect(find.descendant(of: cell('notices'), matching: find.text('$unread')), findsOneWidget);
    expect(find.descendant(of: cell('cash'), matching: find.text('হাতে নগদ')), findsOneWidget);

    // What is wrong or waiting comes before the shortcuts.
    expect(t.getTopLeft(find.byType(NoticesTodayBanner)).dy, lessThan(t.getTopLeft(grid).dy));

    final router = h.read(routerProvider);
    await t.tap(cell('cash'));
    await settle(t);
    expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/cash/in-hand');
    router.pop();
    await settle(t);

    // Two features off: the others move up and the bench fills the grid.
    setFlags(h, {'module.tasks': false, 'module.prospects': false});
    await settle(t);
    expect(ids(), ['quick-attendance', 'quick-today-work', 'quick-cash', 'quick-notices', 'quick-requests', 'quick-performance', 'quick-leave', 'quick-leaderboard', 'quick-cowork']);
    // Six left: two full rows.
    setFlags(h, {'module.requests': false, 'module.cowork': false, 'module.reports': false, 'module.handovers': false});
    await settle(t);
    expect(ids(), ['quick-attendance', 'quick-today-work', 'quick-cash', 'quick-notices', 'quick-leave', 'quick-sync']);
    // Five left: one full row; the rest stays in Me.
    setFlags(h, {'module.notifications': false});
    await settle(t);
    expect(ids(), ['quick-attendance', 'quick-today-work', 'quick-cash']);
    expect(t.takeException(), isNull);
  });
}
