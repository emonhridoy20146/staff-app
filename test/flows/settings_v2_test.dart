import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/permissions/permission_service.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/core/settings/ui_prefs.dart';
import 'package:staff_app/features/auth/auth.dart';
import 'package:staff_app/features/collections/collections.dart';
import 'package:staff_app/features/collections/src/application/record_collection.dart';
import 'package:staff_app/features/customers/customers.dart';

import 'helpers.dart';

/// Settings v2 (FR-M-084, owner request 2026-11-26): six sections of uniform rows with their current value;
/// a choice opens a sheet and applies at once; a module that is off leaves no row.
void main() {
  Future<void> settle(WidgetTester t, {int rounds = 6}) async {
    for (var i = 0; i < rounds; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('sections in order, rows with values, choices apply at once, a module that is off leaves no row', (t) async {
    final h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 2600) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t, rounds: 12);
    unawaited(h.read(routerProvider).push('/settings'));
    await settle(t);
    Finder row(String id) => find.byKey(ValueKey('settings-$id'));
    Finder inRow(String id, String text) => find.descendant(of: row(id), matching: find.text(text));

    // Six sections, top to bottom.
    final tops = [for (final s in ['অ্যাকাউন্ট', 'কাজ', 'লোকেশন ও ব্যাটারি', 'ভাষা ও প্রদর্শন', 'গোপনীয়তা', 'সাহায্য ও অ্যাপ সম্পর্কে']) t.getTopLeft(find.text(s)).dy];
    expect(tops, orderedEquals([...tops]..sort()));
    expect(tops.toSet().length, 6);

    // Every row is there, at least 64 dp tall, with an icon, a title and (where it has one) its value.
    for (final id in ['profile', 'logout', 'sync', 'calendar', 'tracking', 'battery-guide', 'language', 'digits', 'theme', 'contrast', 'privacy', 'version', 'device', 'server']) {
      expect(row(id), findsOneWidget, reason: id);
      expect(t.getSize(row(id)).height, greaterThanOrEqualTo(64), reason: id);
      expect(find.descendant(of: row(id), matching: find.byType(Icon)), findsWidgets, reason: id);
    }
    expect(inRow('profile', 'রাকিব হাসান'), findsOneWidget);
    expect(inRow('profile', 'স্টাফ কোড FS014 · ফিল্ড স্টাফ'), findsOneWidget);
    expect(inRow('language', 'বাংলা'), findsOneWidget);
    expect(inRow('theme', 'আলো'), findsOneWidget);
    expect(inRow('tracking', 'বন্ধ'), findsOneWidget); // off duty: never tracking
    expect(inRow('server', 'ডেমো'), findsOneWidget);
    expect(find.descendant(of: row('calendar'), matching: find.textContaining('–')), findsOneWidget);

    // Language: a sheet of two choices; picking one applies at once.
    await t.tap(row('language'));
    await settle(t);
    await t.tap(find.byKey(const ValueKey('settings-option-en')));
    await settle(t);
    expect(h.read(uiPrefsProvider).language, 'en');
    expect(inRow('language', 'English'), findsOneWidget);
    expect(find.text('Display & language'), findsOneWidget);

    // Theme and high contrast.
    await t.tap(row('theme'));
    await settle(t);
    await t.tap(find.byKey(const ValueKey('settings-option-ThemeMode.dark')));
    await settle(t);
    expect(h.read(uiPrefsProvider).themeMode, ThemeMode.dark);
    await t.tap(row('contrast'));
    await settle(t);
    expect(h.read(uiPrefsProvider).highContrast, isTrue);

    // Sign-out keeps its guard: it asks first.
    await t.tap(row('logout'));
    await settle(t);
    expect(find.byType(AlertDialog), findsOneWidget);
    await t.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextButton)).first);
    await settle(t);
    expect(find.byType(AlertDialog), findsNothing);

    // A module that is off leaves no row, and a section with no row is not shown.
    final a = h.read(accessProvider);
    h.read(accessProvider.notifier).set(flags: {...a.flags, 'module.location': false});
    await settle(t);
    expect(row('tracking'), findsNothing);
    expect(row('battery-guide'), findsNothing);
    expect(find.text('Location & battery'), findsNothing);
    expect(find.text('Work'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  // CLAUDE.md §2.3: unsynced work is never lost on sign-out. The new Settings row keeps the guard.
  testWidgets('sign-out from Settings is refused while a collection is unsent; the collection stays on the phone', (t) async {
    final h = Harness();
    await t.runAsync(() async {
      await h.signIn();
      // Saved with no network: it waits in the outbox.
      h.api.offline = true;
      final c = (await h.read(customerRepositoryProvider).getOne('c-1002'))!;
      await h.read(recordCollectionProvider).call(
          CollectionInput(customerId: c.id, customerName: c.row.nameBn, customerCode: c.code, amountPoisha: 50000, method: PaymentMethod.cash, outstandingPoisha: c.outstanding));
    });
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t, rounds: 12);
    unawaited(h.read(routerProvider).push('/settings'));
    await settle(t);
    final db = h.read(databaseProvider);
    Future<int> unsent() async => (await t.runAsync(() => h.read(outboxReaderProvider).unsyncedCount()))!;
    Future<int> collections() async => (await t.runAsync(() => db.select(db.collections).get()))!.length;
    final waiting = await unsent();
    expect(waiting, greaterThan(0));
    expect(await collections(), 1);

    await t.tap(find.byKey(const ValueKey('settings-logout')));
    await settle(t);
    // Refused: the dialog says what waits and offers to sync; it has no sign-out button.
    final dialog = find.byType(AlertDialog);
    expect(find.descendant(of: dialog, matching: find.textContaining('এখনো আপলোড হয়নি')), findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text('এখনই সিঙ্ক করুন')), findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text('লগআউট')), findsNothing);
    await t.tap(find.descendant(of: dialog, matching: find.byType(TextButton)));
    await settle(t);
    expect(dialog, findsNothing);
    expect(h.read(sessionProvider).user, isNotNull, reason: 'still signed in');
    expect(await unsent(), waiting);
    expect(await collections(), 1);
    expect(t.takeException(), isNull);
  });
}
