import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/customers.dart';
import 'package:staff_app/features/customers/src/customer_providers.dart' show customerSortProvider;
import 'package:staff_app/features/customers/src/domain/customer.dart' show CustomerSort;
import 'package:staff_app/features/customers/src/presentation/returned_mark.dart';
import 'package:staff_app/features/map/src/map_screen.dart' show mapListModeProvider;

import 'helpers.dart';

/// FR-M-085 (contract 1.53.0, FR-CUS-024, owner request 2026-11-26): returned invoices are shown, never counted.
/// Every list marks a customer with a returned invoice; a customer whose every invoice was returned stays listed
/// but does not open. The customer page shows the returned invoices apart, with their payments, and marks the
/// payments in the timeline. Fake server, no network.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 8}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  /// Lets go of the app as the screenshot helper does: drift's stream timers run out on real and fake turns.
  Future<void> finish(WidgetTester t, Harness h) async {
    await t.pumpWidget(const SizedBox.shrink());
    h.container.dispose();
    await settle(t, rounds: 3);
  }

  /// [only]: a customer whose every invoice was returned. [some]: a customer with several, one returned.
  Future<(Harness, CustomerRow only, CustomerRow some, String someReturnedPlan)> start(WidgetTester t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 2400) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final db = h.read(databaseProvider);
    // Seeded before the app starts: a write while the start-up sync holds the database would wait forever.
    final seeded = await t.runAsync(() async {
      final counts = <String, List<String>>{};
      for (final p in await db.select(db.plans).get()) {
        counts.putIfAbsent(p.customerId, () => []).add(p.erpPlanId);
      }
      final rows = await (db.select(db.customers)..orderBy([(c) => OrderingTerm.asc(c.nameBn)])).get();
      final withPlans = rows.where((c) => (counts[c.serverId]?.length ?? 0) >= 1).toList();
      final only = withPlans[0];
      final some = withPlans[1];
      // [some] gets a second invoice; its first one is returned below.
      h.api.addInvoice(some.serverId, 'INV-EXTRA-1', 'INV-99001');
      final payment = {'erpPaymentId': 'ret-pay-1', 'date': '2026-11-10', 'amountPoisha': 250000, 'method': 'cash', 'source': 'office', 'receiptNo': 'RC-RET-1'};
      // Every invoice of [only] is returned (the payment goes with the first).
      for (final (i, id) in counts[only.serverId]!.indexed) {
        h.api.returnInvoice(only.serverId, id, payments: [if (i == 0) payment]);
      }
      h.api.returnInvoice(some.serverId, counts[some.serverId]!.first, payments: [{...payment, 'erpPaymentId': 'ret-pay-2'}]);
      await h.read(syncEngineProvider).syncNow();
      final fresh = {for (final c in await db.select(db.customers).get()) c.serverId: c};
      return (fresh[only.serverId]!, fresh[some.serverId]!, counts[some.serverId]!.first);
    });
    h.read(customerSortProvider.notifier).state = CustomerSort.name;
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t, rounds: 12);
    final (only, some, plan) = seeded!;
    return (h, only, some, plan);
  }

  testWidgets('Customers list: both rows carry the marker; the only-returned row does not open, the other does', (t) async {
    final (h, only, some, _) = await start(t);
    expect([only.onlyReturned, only.returnedInvoiceCount], [true, 1]);
    expect([some.onlyReturned, some.returnedInvoiceCount], [false, 1]);

    await t.tap(find.text('গ্রাহক').last);
    await settle(t);
    Finder row(CustomerRow r) => find.widgetWithText(CustomerWorkRow, r.nameBn);
    await t.scrollUntilVisible(row(only), 300, scrollable: find.byType(Scrollable).last);
    await settle(t, rounds: 2);
    expect(find.descendant(of: row(only), matching: find.byType(ReturnedCustomerMark)), findsOneWidget);
    expect(find.descendant(of: row(only), matching: find.text('ফেরত পণ্যের customer')), findsOneWidget);
    expect(find.descendant(of: row(only), matching: find.byIcon(Icons.assignment_return_rounded)), findsOneWidget);
    // Not clickable: no tap handler, and a tap leaves the list where it is.
    final ink = t.widget<InkWell>(find.descendant(of: row(only), matching: find.byType(InkWell)).first);
    expect(ink.onTap, isNull);
    await t.tap(row(only), warnIfMissed: false);
    await settle(t, rounds: 3);
    expect(find.byType(CustomerDetailScreen), findsNothing);
    expect(t.getSemantics(find.descendant(of: row(only), matching: find.byType(Semantics)).first).label, contains('খোলা যাবে না'));

    await t.scrollUntilVisible(row(some), 300, scrollable: find.byType(Scrollable).last);
    await settle(t, rounds: 2);
    expect(find.descendant(of: row(some), matching: find.byType(ReturnedCustomerMark)), findsOneWidget);
    await t.tap(find.descendant(of: row(some), matching: find.byKey(const Key('work-row-name'))));
    await settle(t);
    expect(find.byType(CustomerDetailScreen), findsOneWidget);
    expect(t.takeException(), isNull);
    await finish(t, h);
  });

  testWidgets('customer page: returned invoices in their own section with the chip and payments; timeline marks them', (t) async {
    final (h, _, some, plan) = await start(t);
    unawaited(h.read(routerProvider).push('/customers/${some.serverId}'));
    await settle(t);
    final section = find.byKey(const Key('returned-plans'), skipOffstage: false);
    await t.scrollUntilVisible(section, 300, scrollable: find.byType(Scrollable).first);
    await settle(t, rounds: 2);
    expect(find.descendant(of: section, matching: find.text('ফেরত চালান')), findsOneWidget);
    expect(find.descendant(of: section, matching: find.text('ফেরত')), findsOneWidget); // the Returned chip
    expect(find.byKey(Key('returned-plan-$plan'), skipOffstage: false), findsOneWidget);
    // One returned invoice: open, with its payment listed. No collect action in the section.
    expect(find.descendant(of: section, matching: find.textContaining('RC-RET-1', skipOffstage: false)), findsOneWidget);
    expect(find.descendant(of: section, matching: find.byType(FilledButton)), findsNothing);
    // The header says the customer has a returned invoice.
    expect(find.byType(ReturnedCustomerMark, skipOffstage: false), findsWidgets);
    // Timeline: the payment to the returned invoice carries the Returned chip and says it is not counted.
    final mark = find.byKey(const Key('timeline-returned'), skipOffstage: false);
    await t.scrollUntilVisible(mark.first, 300, scrollable: find.byType(Scrollable).first);
    expect(mark, findsWidgets);
    expect(find.textContaining('ফেরত চালানের জমা', skipOffstage: false), findsWidgets);
    expect(t.takeException(), isNull);
    await finish(t, h);
  });

  testWidgets('Collect picker and Map list: marker shown; the only-returned customer does not open', (t) async {
    final (h, only, some, _) = await start(t);
    unawaited(h.read(routerProvider).push('/collect'));
    await settle(t);
    Finder tile(CustomerRow r) => find.widgetWithText(CustomerTile, r.nameBn);
    await t.scrollUntilVisible(tile(only), 300, scrollable: find.byType(Scrollable).last);
    await settle(t, rounds: 2);
    expect(find.descendant(of: tile(only), matching: find.byType(ReturnedCustomerMark)), findsOneWidget);
    expect(t.widget<InkWell>(find.descendant(of: tile(only), matching: find.byType(InkWell)).first).onTap, isNull);
    await t.tap(tile(only), warnIfMissed: false);
    await settle(t, rounds: 3);
    expect(h.read(routerProvider).state.uri.path, '/collect');
    h.read(routerProvider).pop();
    await settle(t, rounds: 3);

    h.read(mapListModeProvider.notifier).state = true;
    h.read(routerProvider).go('/map');
    await settle(t);
    await t.scrollUntilVisible(tile(some), 300, scrollable: find.byType(Scrollable).last);
    expect(find.descendant(of: tile(some), matching: find.byType(ReturnedCustomerMark)), findsOneWidget);
    expect(t.widget<InkWell>(find.descendant(of: tile(some), matching: find.byType(InkWell)).first).onTap, isNotNull);
    expect(t.takeException(), isNull);
    await finish(t, h);
  });
}
