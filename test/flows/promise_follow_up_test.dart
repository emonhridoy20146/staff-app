import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/promises/promises.dart';

import 'helpers.dart';

/// FR-M-072 (contract 1.45.0): a broken promise gets a follow-up linked by `followUpOf`, offline-first through
/// the same `promise` mutation; the chain is numbered; Home lists broken promises nobody has followed up.
void main() {
  const customer = 'c-1010';

  Future<String> promise(Harness h, {PromiseRow? followUpOf, int amount = 50000, String date = '2026-11-16'}) async {
    await h.read(promiseServiceProvider).record(
          followUpOf: followUpOf,
          customerId: customer,
          date: date,
          amountPoisha: amount,
          reminderTitle: 't',
          reminderBody: 'b',
        );
    final db = h.read(databaseProvider);
    return (await (db.select(db.promises)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])..limit(1)).getSingle()).clientId;
  }

  Future<List<PromiseRow>> unfollowed(Harness h) => watchBrokenWithoutFollowUp(h.read(databaseProvider)).first;

  Future<PromiseRow> row(Harness h, String clientId) {
    final db = h.read(databaseProvider);
    return (db.select(db.promises)..where((t) => t.clientId.equals(clientId))).getSingle();
  }

  group('data', () {
    late Harness h;
    setUp(() => h = Harness());
    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await h.dispose();
    });

    test('broken → follow-up offline: linked by followUpOf, attempt 2, same promise mutation, idempotent id', () async {
      await h.signIn();
      final first = await promise(h);
      await h.read(syncEngineProvider).kick(reason: 'test');
      h.api.breakPromise(first);
      await h.read(syncEngineProvider).kick(reason: 'test');
      final broken = await row(h, first);
      expect(broken.status, 'broken');
      expect(await unfollowed(h), [isA<PromiseRow>().having((p) => p.clientId, 'clientId', first)]);

      h.clock.advance(const Duration(minutes: 5));
      h.api.offline = true;
      final second = await promise(h, followUpOf: broken, amount: 30000, date: '2026-11-18');
      final r = await row(h, second);
      expect([r.followUpOf, r.attempt, r.status], ['promise-$first', 2, 'open']);
      final db = h.read(databaseProvider);
      final ob = await (db.select(db.outbox)..where((t) => t.mutationId.equals(second))).getSingle();
      expect(ob.entity, 'promise');
      expect(ob.payloadJson, contains('"followUpOf":"promise-$first"'));
      // Followed up: no longer on Home.
      expect(await unfollowed(h), isEmpty);

      // Retry after a failed send uses the same id; the server sees the link once.
      await h.read(syncEngineProvider).kick(reason: 'test');
      h.api.offline = false;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await h.read(syncEngineProvider).syncNow();
      expect(h.api.appliedPayloads[second]!['followUpOf'], 'promise-$first');
      expect((await row(h, second)).syncState, 'synced');
    });

    test('a plain new promise on a customer with a broken one follows it up too; the chain counts on', () async {
      await h.signIn();
      final a = await promise(h);
      await h.read(syncEngineProvider).kick(reason: 'test');
      h.api.breakPromise(a);
      await h.read(syncEngineProvider).kick(reason: 'test');
      h.clock.advance(const Duration(minutes: 1));
      final b = await promise(h); // no explicit follow-up
      expect((await row(h, b)).attempt, 2);
      await h.read(syncEngineProvider).kick(reason: 'test');
      h.api.breakPromise(b);
      await h.read(syncEngineProvider).kick(reason: 'test');
      expect((await row(h, b)).attempt, 2, reason: 'the server says attempt 2 as well');
      h.clock.advance(const Duration(minutes: 1));
      final c = await promise(h);
      final rc = await row(h, c);
      expect([rc.followUpOf, rc.attempt], ['promise-$b', 3]);
    });

    test('followed up by someone else (the server says followUpId): not on Home, no action', () async {
      await h.signIn();
      final a = await promise(h);
      await h.read(syncEngineProvider).kick(reason: 'test');
      h.api.breakPromise(a, followUpId: 'promise-of-a-colleague');
      await h.read(syncEngineProvider).kick(reason: 'test');
      expect((await row(h, a)).status, 'broken');
      expect(await unfollowed(h), isEmpty);
    });

    test('an open or kept promise needs no follow-up', () async {
      await h.signIn();
      await promise(h);
      expect(await unfollowed(h), isEmpty);
    });
  });

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 8; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('Home lists the broken promise; the customer page shows Broken with "New promise (follow-up)" and the chain', (t) async {
    final h = Harness();
    final first = await t.runAsync(() async {
      await h.signIn();
      final id = await promise(h);
      await h.read(syncEngineProvider).kick(reason: 'test');
      h.api.breakPromise(id);
      await h.read(syncEngineProvider).kick(reason: 'test');
      return id;
    });
    t.view.physicalSize = const Size(412, 2400) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);

    // Home
    expect(find.byType(BrokenPromisesCard), findsOneWidget);
    expect(find.text('ভাঙা প্রতিশ্রুতি: ফলো-আপ করুন'), findsOneWidget);
    final homeButton = find.descendant(of: find.byType(BrokenPromisesCard), matching: find.byType(PromiseFollowUpButton));
    expect(t.getSize(homeButton).height, greaterThanOrEqualTo(48));

    // Customer page
    h.read(routerProvider).go('/customers/$customer');
    await settle(t);
    final action = find.text('নতুন প্রতিশ্রুতি (ফলো-আপ)', skipOffstage: false);
    await t.scrollUntilVisible(action, 200, scrollable: find.byType(Scrollable).first);
    await settle(t);
    expect(find.text('কথা রাখেননি'), findsWidgets); // Broken
    await t.tap(action);
    await settle(t);
    expect(find.textContaining('ভাঙা প্রতিশ্রুতির ফলো-আপ'), findsOneWidget);
    expect(find.textContaining('চেষ্টা 2'), findsOneWidget);
    await t.tap(find.text('সংরক্ষণ'));
    await settle(t);
    final db = h.read(databaseProvider);
    final rows = await t.runAsync(() => (db.select(db.promises)..where((x) => x.followUpOf.equals('promise-$first'))).get());
    expect(rows!.single.attempt, 2);
    // The chain on the timeline, and the follow-up action is gone.
    expect(find.textContaining('চেষ্টা 2', skipOffstage: false), findsWidgets);
    expect(find.textContaining('চেষ্টা 1', skipOffstage: false), findsWidgets);
    expect(find.text('নতুন প্রতিশ্রুতি (ফলো-আপ)', skipOffstage: false), findsNothing);
    await t.pump(const Duration(seconds: 10)); // the "saved" message goes away
    // Leave the customer page inside the test: its drift streams close with a zero timer.
    h.read(routerProvider).go('/');
    await settle(t);
    await t.pumpWidget(const SizedBox());
    await settle(t);
  });
}
