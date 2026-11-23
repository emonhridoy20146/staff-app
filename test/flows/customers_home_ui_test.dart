import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/core/ui/back_button.dart';
import 'package:staff_app/features/customers/customers.dart';

import 'helpers.dart';

/// Owner requests 2026-11-23: invoice-type chips and labels (FR-M-066), the Home row (FR-M-067), the customer
/// page header counts and back button.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 8}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  PlansCompanion plan(String id, String customer, {String kind = 'installment', String? invoiceNo}) => PlansCompanion.insert(
        erpPlanId: id,
        customerId: customer,
        product: 'Fridge',
        startDate: '2026-01-01',
        finalDueDate: '2027-01-01',
        installmentCount: 12,
        totalPayablePoisha: 1200000,
        paidPoisha: 0,
        outstandingPoisha: 100000,
        status: 'active',
        kind: Value(kind),
        invoiceNo: Value(invoiceNo),
        saleDate: const Value('2026-03-01'),
      );

  /// Four customers of mine with known invoices: A overdue installment, B overdue credit, C current installment,
  /// D overdue with one installment and two credit invoices. Everyone else has no open invoice.
  Future<(Harness, List<CustomerRow>)> start(WidgetTester t, {Future<void> Function(AppDatabase db, List<CustomerRow> four)? seed}) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final db = h.read(databaseProvider);
    final me = h.read(myCustomerUserIdProvider);
    // Seeded before the app starts: a write while the start-up sync holds the database would wait forever.
    final rows = await t.runAsync(() async {
      final all = await (db.select(db.customers)..orderBy([(c) => OrderingTerm.asc(c.nameBn)])).get();
      final four = all.take(4).toList();
      await db.delete(db.scheduleLines).go();
      await db.delete(db.plans).go();
      for (final (i, c) in four.indexed) {
        await (db.update(db.customers)..where((x) => x.serverId.equals(c.serverId))).write(CustomersCompanion(
              daysOverdue: Value(i == 2 ? 0 : 75),
              overdue: Value(i != 2),
              dueToday: const Value(false),
              assigneeId: Value(me),
              openPromiseId: const Value(null),
              openPromiseDate: const Value(null),
            ));
      }
      await db.batch((b) => b.insertAll(db.plans, [
            plan('pa', four[0].serverId, invoiceNo: 'INV-A1'),
            plan('pb', four[1].serverId, kind: 'credit', invoiceNo: 'INV-B1'),
            plan('pc', four[2].serverId),
            plan('pd1', four[3].serverId, invoiceNo: 'INV-D1'),
            plan('pd2', four[3].serverId, kind: 'credit', invoiceNo: 'INV-D2'),
            plan('pd3', four[3].serverId, kind: 'credit', invoiceNo: 'INV-D3'),
          ]));
      await seed?.call(db, four);
      return four;
    });
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t, rounds: 12);
    return (h, rows!);
  }

  testWidgets('Overdue + Installment shows only overdue installment customers; a customer with both kinds matches both', (t) async {
    final (_, c) = await start(t);
    await t.tap(find.text('গ্রাহক').last);
    await settle(t);
    Finder row(CustomerRow r) => find.widgetWithText(CustomerWorkRow, r.nameBn);

    // The chip row scrolls sideways; the type chips come first, the status chips after the divider.
    // Built but past the right edge until scrolled to.
    await t.ensureVisible(find.byKey(const ValueKey('filter-overdue'), skipOffstage: false));
    await settle(t, rounds: 2);
    await t.tap(find.byKey(const ValueKey('filter-overdue')));
    await settle(t, rounds: 3);
    // Back to the start of the row, where the type chips are.
    await t.drag(find.ancestor(of: find.byKey(const ValueKey('filter-overdue')), matching: find.byType(Scrollable)).first, const Offset(2000, 0));
    await settle(t, rounds: 3);
    await t.tap(find.byKey(const ValueKey('kind-filter-installment')));
    await settle(t, rounds: 3);
    expect(row(c[0]), findsOneWidget);
    expect(row(c[3]), findsOneWidget);
    expect(row(c[1]), findsNothing); // credit only
    expect(row(c[2]), findsNothing); // not overdue
    expect(find.byType(CustomerWorkRow), findsNWidgets(2));
    // Owner request 2026-11-23: the Home row style with an arrow to the details, and no Collect in the list.
    expect(find.byKey(const Key('open-details-arrow')), findsNWidgets(2));
    expect(find.byKey(ValueKey('collect-${c[0].serverId}')), findsNothing);

    // Credit instead: B and D.
    await t.tap(find.byKey(const ValueKey('kind-filter-credit')));
    await settle(t, rounds: 3);
    expect(find.byType(CustomerWorkRow), findsNWidgets(2));
    expect(row(c[1]), findsOneWidget);
    expect(row(c[3]), findsOneWidget);

    // Tapping the picked chip again clears the type: every overdue customer.
    await t.tap(find.byKey(const ValueKey('kind-filter-credit')));
    await settle(t, rounds: 3);
    expect(row(c[2]), findsNothing);
    expect(find.byType(CustomerWorkRow).evaluate().length, greaterThan(2));
  });

  testWidgets('row label: "কিস্তি" / "বাকি" for one invoice, counts for several', (t) async {
    final (_, c) = await start(t);
    await t.tap(find.text('গ্রাহক').last);
    await settle(t);
    await t.tap(find.byKey(const ValueKey('kind-filter-installment')));
    await settle(t, rounds: 3);
    Finder label(CustomerRow r) => find.descendant(of: find.widgetWithText(CustomerWorkRow, r.nameBn), matching: find.byType(InvoiceKindLabel));
    expect(find.descendant(of: label(c[0]), matching: find.text('কিস্তি')), findsOneWidget);
    expect(find.descendant(of: label(c[3]), matching: find.text('1 কিস্তি')), findsOneWidget);
    expect(find.descendant(of: label(c[3]), matching: find.text('2 বাকি')), findsOneWidget);
    final sem = t.widget<Semantics>(find.descendant(of: label(c[3]), matching: find.byType(Semantics)).first);
    expect(sem.properties.label, 'খোলা ইনভয়েস: 1 কিস্তি · 2 বাকি');

    await t.tap(find.byKey(const ValueKey('kind-filter-credit')));
    await settle(t, rounds: 3);
    expect(find.descendant(of: label(c[1]), matching: find.text('বাকি')), findsOneWidget);
  });

  testWidgets('customer page: type counts right of the name, and a 48 dp tonal back button with a 28 dp arrow', (t) async {
    final (h, c) = await start(t);
    unawaited(h.read(routerProvider).push('/customers/${c[3].serverId}'));
    await settle(t);
    final header = find.byKey(const Key('header-kinds'));
    expect(find.descendant(of: header, matching: find.text('1 কিস্তি')), findsOneWidget);
    expect(find.descendant(of: header, matching: find.text('2 বাকি')), findsOneWidget);
    final name = t.getRect(find.text(c[3].nameBn).first);
    expect(t.getRect(header).left, greaterThan(name.left));
    expect((t.getRect(header).top - name.top).abs(), lessThan(12));

    // One invoice still says "১ কিস্তি" in the header (always counted there).
    h.read(routerProvider).pop();
    await settle(t, rounds: 3);
    unawaited(h.read(routerProvider).push('/customers/${c[0].serverId}'));
    await settle(t);
    expect(find.descendant(of: find.byKey(const Key('header-kinds')), matching: find.text('1 কিস্তি')), findsOneWidget);

    final back = find.byKey(const Key('app-back-button'));
    expect(back, findsOneWidget);
    final size = t.getSize(back);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(t.widget<IconButton>(back).iconSize, AppBackButton.iconSize);
    expect(AppBackButton.iconSize, greaterThan(24));
    // Tonal background from the theme tokens.
    final material = t.widget<Material>(find.descendant(of: back, matching: find.byType(Material)).first);
    expect(material.color, Theme.of(t.element(back)).colorScheme.secondaryContainer);
    // It goes back.
    String path() => h.read(routerProvider).routerDelegate.currentConfiguration.last.matchedLocation;
    expect(path(), '/customers/${c[0].serverId}');
    await t.tap(back);
    await settle(t, rounds: 3);
    expect(path(), isNot('/customers/${c[0].serverId}'));
  });

  testWidgets('Home row: name and amount, branch and invoices, larger marks with a Collect button, overdue line; no FAB', (t) async {
    // D has an open promise for today, taken by a colleague.
    final (h, c) = await start(t, seed: (db, four) async {
      await db.into(db.promises).insert(PromisesCompanion.insert(
            clientId: 'pr-test-d',
            serverId: const Value('srv-pr-test-d'),
            customerId: four[3].serverId,
            promisedDate: '2026-11-15',
            promisedAmountPoisha: 50000,
            createdAt: DateTime.utc(2026, 11, 10),
            createdByName: const Value('করিম উদ্দিন'),
          ));
      await (db.update(db.customers)..where((x) => x.serverId.equals(four[3].serverId)))
          .write(const CustomersCompanion(openPromiseId: Value('srv-pr-test-d'), openPromiseDate: Value('2026-11-15'), openPromisePoisha: Value(50000)));
    });
    expect(find.byType(FloatingActionButton), findsNothing);

    await t.scrollUntilVisible(find.text(c[3].nameBn), 300, scrollable: find.descendant(of: find.byType(CustomScrollView), matching: find.byType(Scrollable)).first);
    final row = find.widgetWithText(CustomerWorkRow, c[3].nameBn).first;
    // Middle of the screen, clear of the pinned top bar.
    await Scrollable.ensureVisible(t.element(row), alignment: 0.5);
    await settle(t, rounds: 2);
    Rect r(Key k) => t.getRect(find.descendant(of: row, matching: find.byKey(k)));
    final name = r(const Key('work-row-name'));
    final amount = r(const Key('work-row-amount'));
    final where = r(const Key('work-row-where'));
    final overdue = r(const Key('work-row-overdue'));
    final collect = t.getRect(find.descendant(of: row, matching: find.byKey(ValueKey('collect-${c[3].serverId}'))));
    final mark = t.getRect(find.descendant(of: row, matching: find.byKey(const ValueKey('work-mark-large'))).first);
    final rowRect = t.getRect(row);

    // Line 1: name, amount at the far right.
    expect(amount.left, greaterThan(name.left));
    expect(rowRect.right - amount.right, lessThanOrEqualTo(17));
    // Line 2: branch and invoice numbers.
    expect(where.top, greaterThanOrEqualTo(name.bottom - 1));
    final whereText = t.widget<Text>(find.descendant(of: row, matching: find.byKey(const Key('work-row-where')))).data!;
    expect(whereText, contains('INV-D1'));
    expect(whereText, contains('INV-D3'));
    // Line 3: bigger marks, Collect at the right, a 48 dp button.
    expect(mark.top, greaterThanOrEqualTo(where.bottom - 1));
    expect(mark.width, greaterThanOrEqualTo(32));
    expect((collect.center.dy - mark.center.dy).abs(), lessThan(4));
    expect(collect.right, greaterThan(rowRect.right - 20));
    expect(collect.height, greaterThanOrEqualTo(48));
    expect(find.descendant(of: row, matching: find.text('আদায়')), findsOneWidget);
    // Line 4: overdue, full width under the rest.
    expect(overdue.top, greaterThanOrEqualTo(collect.bottom - 1));
    expect(find.descendant(of: row, matching: find.text('2 মাস 15 দিন বকেয়া')), findsOneWidget);
    // Promised: who took it.
    expect(find.descendant(of: row, matching: find.text('প্রতিশ্রুতি নিয়েছেন: করিম উদ্দিন')), findsOneWidget);

    await t.tap(find.descendant(of: row, matching: find.text('আদায়')));
    await settle(t, rounds: 3);
    expect(h.read(routerProvider).routerDelegate.currentConfiguration.last.matchedLocation, '/collect/${c[3].serverId}');
  });

  testWidgets('Home: the collection card is compact with a "বিস্তারিত" hint and opens on tap (owner request 2026-11-23)', (t) async {
    await start(t);
    final card = find.byKey(const Key('today-progress-card'));
    expect(card, findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('বিস্তারিত')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('আজ নগদ')), findsNothing);
    final closed = t.getRect(card).height;

    await t.tap(find.descendant(of: card, matching: find.text('আজকের আদায়')));
    await settle(t, rounds: 3);
    expect(find.descendant(of: card, matching: find.text('আজ নগদ')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('লুকান')), findsOneWidget);
    expect(t.getRect(card).height, greaterThan(closed));

    await t.tap(find.descendant(of: card, matching: find.text('আজকের আদায়')));
    await settle(t, rounds: 3);
    expect(find.descendant(of: card, matching: find.text('আজ নগদ')), findsNothing);
  });
}
