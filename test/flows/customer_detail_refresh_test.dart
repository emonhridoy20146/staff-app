import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/core/settings/ui_prefs.dart';

import 'helpers.dart';

/// FR-M-063 (owner request 2026-11-22): the customer page has a reload button and can be pulled down;
/// both ask the server for this customer (ERP figures, invoices, payments) and then sync.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 10}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  const id = 'c-1001';
  const tooltip = 'সার্ভার থেকে আবার লোড করুন';

  Future<Harness> open(WidgetTester t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    h.read(routerProvider).go('/customers/$id');
    await settle(t);
    return h;
  }

  Future<CustomerRow> row(WidgetTester t, Harness h) async {
    final db = h.read(databaseProvider);
    return (await t.runAsync(() => (db.select(db.customers)..where((c) => c.serverId.equals(id))).getSingle()))!;
  }

  /// An old ERP figure on the phone, so a refresh can be seen to replace it.
  Future<int> makeStale(WidgetTester t, Harness h) async {
    final db = h.read(databaseProvider);
    final server = (await row(t, h)).totalOutstandingPoisha;
    await t.runAsync(() => (db.update(db.customers)..where((c) => c.serverId.equals(id)))
        .write(const CustomersCompanion(totalOutstandingPoisha: Value(1), erpFetchedAt: Value(null))));
    return server;
  }

  testWidgets('reload button: fresh ERP figures from the server, then a message', (t) async {
    final h = await open(t);
    expect(find.byTooltip(tooltip), findsOneWidget);
    final server = await makeStale(t, h);

    await t.tap(find.byTooltip(tooltip));
    await settle(t);
    expect(h.api.customerRefreshCalls, 1);
    expect(find.text('সার্ভার থেকে হালনাগাদ হয়েছে'), findsOneWidget);
    final r = await row(t, h);
    expect(r.totalOutstandingPoisha, server);
    expect(r.erpFetchedAt, isNotNull);
  });

  testWidgets('pull down does the same as the button', (t) async {
    final h = await open(t);
    final server = await makeStale(t, h);

    await t.fling(find.byType(CustomScrollView), const Offset(0, 400), 1500);
    await settle(t);
    expect(h.api.customerRefreshCalls, 1);
    expect(find.text('সার্ভার থেকে হালনাগাদ হয়েছে'), findsOneWidget);
    expect((await row(t, h)).totalOutstandingPoisha, server);
  });

  testWidgets('offline: says it needs internet and keeps the saved data and the outbox', (t) async {
    final h = await open(t);
    final db = h.read(databaseProvider);
    final before = await row(t, h);
    final outbox = (await t.runAsync(() => db.select(db.outbox).get()))!.length;
    h.api.offline = true;

    await t.tap(find.byTooltip(tooltip));
    await settle(t);
    expect(find.text('ইন্টারনেট লাগবে। ফোনে রাখা তথ্য দেখানো হচ্ছে।'), findsOneWidget);
    final after = await row(t, h);
    expect(after.totalOutstandingPoisha, before.totalOutstandingPoisha);
    expect(after.code, before.code);
    expect((await t.runAsync(() => db.select(db.outbox).get()))!.length, outbox);
    // The page is still there with the customer on it, and the button can be tapped again.
    expect(find.text(before.code), findsWidgets);
    expect(t.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.refresh_rounded)).onPressed, isNotNull);

    await t.fling(find.byType(CustomScrollView), const Offset(0, 400), 1500);
    await settle(t);
    expect(find.text('ইন্টারনেট লাগবে। ফোনে রাখা তথ্য দেখানো হচ্ছে।'), findsWidgets);
    h.api.offline = false;
  });

  testWidgets('English text', (t) async {
    final h = await open(t);
    await t.runAsync(() => h.read(uiPrefsProvider.notifier).update(const UiPrefs(language: 'en')));
    await settle(t);
    expect(find.byTooltip('Reload from server'), findsOneWidget);
    h.api.offline = true;
    await t.tap(find.byTooltip('Reload from server'));
    await settle(t);
    expect(find.text('Needs internet. Showing the data saved on this phone.'), findsOneWidget);
    h.api.offline = false;
  });
}
