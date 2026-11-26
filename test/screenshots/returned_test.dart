@Tags(['screenshots'])
library;

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/src/customer_providers.dart' show customerSortProvider;
import 'package:staff_app/features/customers/src/domain/customer.dart' show CustomerSort;
import 'package:staff_app/features/map/src/map_screen.dart' show mapListModeProvider;

import '../flows/helpers.dart';
import 'shot_helpers.dart';

/// Returned invoices (FR-M-085, contract 1.53.0): the "returned product customer" marker on list rows, the
/// only-returned row that does not open, and the customer page's "Returned invoices" section with its payments.
/// Regenerate: `flutter test --tags screenshots --update-goldens`.
///
/// The fake server returns invoices of the first two customers by name: every invoice of the first (only
/// returned), and the first of two of the second (it gets a second invoice first). Sample data is not changed.
Future<List<String>> seedReturned(Harness h) async {
  final db = h.read(databaseProvider);
  final first = (await (db.select(db.customers)..orderBy([(c) => OrderingTerm.asc(c.nameBn)])..limit(2)).get()).map((c) => c.serverId).toList();
  Future<List<String>> plansOf(String id) async => [for (final p in await (db.select(db.plans)..where((t) => t.customerId.equals(id))).get()) p.erpPlanId];
  Map<String, Object> pay(String id, String date, int poisha) =>
      {'erpPaymentId': id, 'date': date, 'amountPoisha': poisha, 'method': 'cash', 'methodLabel': 'Cash', 'source': 'office', 'receiptNo': 'RC-$id'};
  for (final p in await plansOf(first[0])) {
    h.api.returnInvoice(first[0], p, payments: [pay('ret-a1', '2026-11-03', 250000), pay('ret-a2', '2026-10-05', 250000)]);
  }
  h.api.addInvoice(first[1], 'INV-EXTRA-1', 'INV-99001');
  h.api.returnInvoice(first[1], (await plansOf(first[1])).first, payments: [pay('ret-b1', '2026-11-08', 300000)]);
  await h.read(syncEngineProvider).syncNow();
  return first;
}

void main() {
  setUpAll(loadShotFonts);

  const phone = Size(412, 1100);

  Future<void> customers(WidgetTester t, String name, {bool dark = false, String lang = 'bn'}) async {
    final h = await readyShot(t, size: phone, dark: dark, lang: lang, setup: seedReturned);
    h.read(customerSortProvider.notifier).state = CustomerSort.name;
    await takeShot(t, h, name, go: '/customers');
  }

  Future<void> page(WidgetTester t, String name, {bool dark = false, String lang = 'bn'}) async {
    late List<String> ids;
    final h = await readyShot(t, size: const Size(412, 1400), dark: dark, lang: lang, setup: (h) async => ids = await seedReturned(h));
    await takeShot(t, h, name, go: '/customers/${ids[1]}', then: () async {
      // The page is a lazy list: scroll until the section is built, then bring its top into view.
      await t.scrollUntilVisible(find.byKey(const Key('returned-plans')), 300, scrollable: find.byType(Scrollable).first);
      await Scrollable.ensureVisible(t.element(find.byKey(const Key('returned-plans'))));
    });
  }

  testWidgets('customers list returned bn light', (t) => customers(t, 'returned/customers-bn-light'));
  testWidgets('customers list returned bn dark', (t) => customers(t, 'returned/customers-bn-dark', dark: true));
  testWidgets('customers list returned en light', (t) => customers(t, 'returned/customers-en-light', lang: 'en'));
  testWidgets('customers list returned en dark', (t) => customers(t, 'returned/customers-en-dark', lang: 'en', dark: true));
  testWidgets('customer page returned bn light', (t) => page(t, 'returned/customer-page-bn-light'));
  testWidgets('customer page returned bn dark', (t) => page(t, 'returned/customer-page-bn-dark', dark: true));
  testWidgets('customer page returned en light', (t) => page(t, 'returned/customer-page-en-light', lang: 'en'));
  testWidgets('customer page returned en dark', (t) => page(t, 'returned/customer-page-en-dark', lang: 'en', dark: true));
  testWidgets('map list returned bn light, text 1.3', (t) async {
    final h = await readyShot(t, size: phone, textScale: 1.3, setup: seedReturned);
    h.read(mapListModeProvider.notifier).state = true;
    await takeShot(t, h, 'returned/map-list-bn-light-scale130', go: '/map');
  });
}
