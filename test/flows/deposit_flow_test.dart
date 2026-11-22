import 'dart:convert';

import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/media/media.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/cash/src/cash_actions.dart';
import 'package:staff_app/features/cash/src/cash.dart' show depositFailureText;
import 'package:staff_app/features/cash/src/record_deposit.dart';
import 'package:staff_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart' show Locale;
import 'package:staff_app/features/collections/collections.dart';
import 'package:staff_app/features/collections/src/application/record_collection.dart';

import 'helpers.dart';

/// FR-M-059 (field-api FR-CASH-010, ADR-049, contract 1.35.0): everything in hand can be changed or
/// deleted until one deposit hands it all in; from then on it is locked, offline too. A deposit the
/// server refuses goes to Problems and the collections are back in hand.
void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    // A sync a test started in the background (recording a collection kicks one) ends before the database closes.
    await h.read(syncEngineProvider).kick(reason: 'test');
    await h.dispose();
  });

  AppDatabase db() => h.read(databaseProvider);
  Future<CollectionRow> row(String clientId) => (db().select(db().collections)..where((t) => t.clientId.equals(clientId))).getSingle();
  Future<DepositRow> deposit(String clientId) => (db().select(db().deposits)..where((t) => t.clientId.equals(clientId))).getSingle();
  Future<String> collect(int poisha, PaymentMethod m, {String customer = 'c-1001'}) async => (await h.read(recordCollectionProvider).call(CollectionInput(
        customerId: customer,
        customerName: 'Test',
        customerCode: 'T-1',
        amountPoisha: poisha,
        method: m,
        txnRef: m == PaymentMethod.cash ? null : 'TXN12345678',
      )))
          .clientId;
  Future<int> failedCount() async => (await (db().select(db().outbox)..where((t) => t.state.equals('failed'))).get()).length;
  Future<String> onlyDeposit() async => (await db().select(db().deposits).get()).single.clientId;

  test('a mobile banking collection can be changed and deleted before the deposit, like cash', () async {
    await h.signIn();
    final bkash = await collect(120000, PaymentMethod.bkash);
    final nagad = await collect(50000, PaymentMethod.nagad);
    await h.read(syncEngineProvider).kick();
    final svc = h.read(cashActionsServiceProvider);
    final b = await row(bkash);
    expect(await svc.edit(b.serverId!, customerId: 'c-1001', oldAmountPoisha: 120000, amountPoisha: 100000), isNull);
    expect((await row(bkash)).amountPoisha, 100000);
    final n = await row(nagad);
    expect(await svc.withdraw(n.serverId!, customerId: 'c-1001', amountPoisha: 50000, reason: 'ভুল'), isNull);
    expect([(await row(nagad)).status, (await row(nagad)).voidedKind], ['voided', 'withdrawn']);
    // still in hand: listed for the deposit
    expect((await h.read(recordDepositProvider).plan()).nonCashPoisha, 100000);
  });

  test('one deposit takes all the cash and every mobile collection; they lock at once and stay locked', () async {
    await h.signIn();
    final cash = await collect(150000, PaymentMethod.cash);
    final bkash = await collect(120000, PaymentMethod.bkash);
    await h.read(syncEngineProvider).kick();

    final rd = h.read(recordDepositProvider);
    final plan = await rd.plan();
    // ৳8,200 the server already had + ৳1,500 now; the amount is not typed, it is all of it
    expect([plan.cashPoisha, plan.nonCashPoisha, plan.nonCashCount, plan.collectionCount], [970000, 120000, 1, 2]);

    h.api.offline = true; // saved offline: locks on the phone before anything is sent
    expect(await rd.call(shown: plan, destination: 'branch_cashier'), DepositSaveResult.saved);
    final dep = await onlyDeposit();
    expect((await row(cash)).depositId, dep);
    expect((await row(bkash)).depositId, dep);
    expect([(await deposit(dep)).amountPoisha, (await deposit(dep)).status, (await deposit(dep)).collectionCount, (await deposit(dep)).nonCashPoisha], [970000, 'submitted', 2, 120000]);
    expect(await readCashOnHand(db(), h.read(serverCashProvider)?.onHandPoisha ?? 0), 0);
    expect((await rd.plan()).isEmpty, isTrue);

    // no change or delete while the deposit waits, and none after; the server is not even asked
    final svc = h.read(cashActionsServiceProvider);
    expect(await svc.withdraw((await row(bkash)).serverId!, customerId: 'c-1001', amountPoisha: 120000), CashActionError.covered);

    h.api.offline = false;
    await h.read(syncEngineProvider).kick();
    final d = await deposit(dep);
    expect([d.syncState, d.status, d.serverId, d.failureCode], ['synced', 'submitted', 'dep-1', null]);
    // the server's deposit id replaces the local one; the ERP took them
    expect([(await row(cash)).depositId, (await row(cash)).status], ['dep-1', 'posted']);
    expect([(await row(bkash)).depositId, (await row(bkash)).status], ['dep-1', 'posted']);
    expect(h.read(serverCashProvider)?.onHandPoisha, 0);
    expect(await svc.edit((await row(cash)).serverId!, customerId: 'c-1001', oldAmountPoisha: 150000, amountPoisha: 1), CashActionError.covered);
    expect(await failedCount(), 0);
  });

  test('a pull while the deposit is still on the phone keeps the lock', () async {
    await h.signIn();
    final a = await collect(150000, PaymentMethod.cash);
    final b = await collect(120000, PaymentMethod.bkash);
    await h.read(syncEngineProvider).kick();
    final rd = h.read(recordDepositProvider);
    h.api.offline = true;
    expect(await rd.call(shown: await rd.plan(), destination: 'manager'), DepositSaveResult.saved);
    final dep = await onlyDeposit();
    h.api.offline = false;
    // the office touches one of them; the deposit is refused for now (try later) but the pull still runs
    h.api.officeVoid(b);
    h.api.transientRejects = 1;
    await h.read(syncEngineProvider).kick();
    expect((await deposit(dep)).syncState, 'queued');
    expect((await row(b)).status, 'voided');
    expect((await row(b)).depositId, dep);
    expect((await row(a)).depositId, dep);
  });

  test('the server refuses the deposit (something changed meanwhile): Problems says why and the collections are back in hand', () async {
    await h.signIn();
    final a = await collect(150000, PaymentMethod.cash);
    final b = await collect(120000, PaymentMethod.bkash);
    await h.read(syncEngineProvider).kick();
    final rd = h.read(recordDepositProvider);
    h.api.offline = true;
    expect(await rd.call(shown: await rd.plan(), destination: 'branch_cashier'), DepositSaveResult.saved);
    final dep = await onlyDeposit();
    // while the phone was offline the office voided the ৳1,500 cash: the deposit now asks for more than is in hand
    h.api.officeVoid(a);
    h.api.offline = false;
    await h.read(syncEngineProvider).kick();

    final d = await deposit(dep);
    expect([d.syncState, d.failureCode, d.amountPoisha], ['failed', 'DEPOSIT_EXCEEDS_ON_HAND', 970000]);
    final ob = await (db().select(db().outbox)..where((t) => t.mutationId.equals(dep))).getSingle();
    expect(ob.state, 'failed'); // kept, never deleted (money)
    expect(await failedCount(), 1);
    // lock undone: the bKash is back in hand and can be changed again
    expect((await row(b)).depositId, isNull);
    expect((await row(a)).depositId, isNull);
    expect((await row(a)).status, 'voided');
    final svc = h.read(cashActionsServiceProvider);
    expect(await svc.edit((await row(b)).serverId!, customerId: 'c-1001', oldAmountPoisha: 120000, note: 'ঠিক আছে'), isNull);

    // deposit again (a new id): what the server has now
    final again = await rd.plan();
    expect([again.cashPoisha, again.nonCashPoisha, again.collectionCount], [820000, 120000, 1]);
    expect(await rd.call(shown: again, destination: 'branch_cashier'), DepositSaveResult.saved);
    await h.read(syncEngineProvider).kick();
    final deps = await db().select(db().deposits).get();
    expect(deps.map((x) => x.syncState).toSet(), {'failed', 'synced'});
    expect(deps.firstWhere((x) => x.clientId != dep).clientId, isNot(dep));
    expect((await row(b)).depositId, isNotNull);
    expect(h.read(serverCashProvider)?.onHandPoisha, 0);
  });

  test('what was confirmed is what is saved: a change in between asks again', () async {
    await h.signIn();
    await collect(150000, PaymentMethod.cash);
    final rd = h.read(recordDepositProvider);
    final plan = await rd.plan();
    await collect(10000, PaymentMethod.cash);
    expect(await rd.call(shown: plan, destination: 'branch_cashier'), DepositSaveResult.changed);
    expect(await db().select(db().deposits).get(), isEmpty);
    expect((await db().select(db().collections).get()).every((c) => c.depositId == null), isTrue);
  });

  // FR-M-065: a bank deposit needs a camera photo of its slip (field-api SLIP_REQUIRED).
  Future<OutboxRow> outboxOf(String id) => (db().select(db().outbox)..where((t) => t.mutationId.equals(id))).getSingle();
  Future<List<MediaQueueRow>> slips(String id) => (db().select(db().mediaQueue)..where((t) => t.ownerEntity.equals('deposit') & t.ownerClientId.equals(id))).get();

  test('a bank deposit without a slip photo is not saved: nothing locked, nothing queued', () async {
    await h.signIn();
    final a = await collect(150000, PaymentMethod.cash);
    await h.read(syncEngineProvider).kick();
    final rd = h.read(recordDepositProvider);
    expect(await rd.call(shown: await rd.plan(), destination: 'bank', reference: 'SL-1'), DepositSaveResult.slipRequired);
    expect(await db().select(db().deposits).get(), isEmpty);
    expect((await db().select(db().outbox).get()).where((o) => o.entity == 'deposit'), isEmpty);
    expect(await db().select(db().mediaQueue).get(), isEmpty);
    expect((await row(a)).depositId, isNull);
    expect((await rd.plan()).isEmpty, isFalse);
  });

  test('a bank deposit with its slip waits for the photo, then goes with slipMediaId; never without it', () async {
    await h.signIn();
    final a = await collect(150000, PaymentMethod.cash);
    await h.read(syncEngineProvider).kick();
    final rd = h.read(recordDepositProvider);
    h.api.uploadsFail = true; // the photo cannot upload yet
    expect(await rd.call(shown: await rd.plan(), destination: 'bank', reference: 'SL-1', slipPhoto: testJpeg()), DepositSaveResult.saved);
    final dep = await onlyDeposit();
    expect((await row(a)).depositId, dep); // locked at once, as any deposit
    final media = await slips(dep);
    expect(media.map((m) => m.kind), ['deposit_slip']);
    expect((await deposit(dep)).slipMediaClientId, media.single.clientId);
    expect((await outboxOf(dep)).state, 'held');
    expect(await h.read(outboxReaderProvider).hasUnsentOf('deposit'), isTrue);

    // Online, the photo fails: the deposit is not sent.
    await h.read(mediaServiceProvider).uploadPending();
    await h.read(syncEngineProvider).syncNow();
    expect(h.api.appliedPayloads[dep], isNull);
    expect([(await outboxOf(dep)).state, (await deposit(dep)).syncState], ['held', 'queued']);

    // The photo uploads: the deposit is released with the server's media id and accepted.
    h.api.uploadsFail = false;
    h.clock.advance(const Duration(minutes: 30));
    await h.read(mediaServiceProvider).uploadPending();
    await h.read(syncEngineProvider).syncNow();
    final mediaId = (await slips(dep)).single.serverMediaId;
    expect(mediaId, isNotNull);
    final sent = h.api.appliedPayloads[dep]!;
    expect([sent['destination'], sent['slipMediaId'], sent['reference']], ['bank', mediaId, 'SL-1']);
    expect((jsonDecode((await outboxOf(dep)).payloadJson) as Map)['slipMediaId'], mediaId);
    final d = await deposit(dep);
    expect([d.syncState, d.failureCode, d.destination], ['synced', null, 'bank']);
    expect(await failedCount(), 0);

    // A second confirm of the same photo changes nothing.
    await linkDepositSlip(h.read(outboxWriterProvider), db(), dep, ['m-other']);
    expect((jsonDecode((await outboxOf(dep)).payloadJson) as Map)['slipMediaId'], mediaId);
  });

  test('a deposit to the branch cashier needs no slip and goes at once, as before', () async {
    await h.signIn();
    await collect(150000, PaymentMethod.cash);
    await h.read(syncEngineProvider).kick();
    final rd = h.read(recordDepositProvider);
    // a photo given by mistake for another destination is ignored
    expect(await rd.call(shown: await rd.plan(), destination: 'branch_cashier', slipPhoto: testJpeg()), DepositSaveResult.saved);
    final dep = await onlyDeposit();
    expect(await slips(dep), isEmpty);
    expect((await deposit(dep)).slipMediaClientId, isNull);
    await h.read(syncEngineProvider).syncNow();
    final sent = h.api.appliedPayloads[dep]!;
    expect(sent['destination'], 'branch_cashier');
    expect(sent.containsKey('slipMediaId'), isFalse);
    expect([(await outboxOf(dep)).state, (await deposit(dep)).syncState], ['done', 'synced']);
  });

  test('the server still refuses a bank deposit with SLIP_REQUIRED: Problems says so in words', () async {
    await h.signIn();
    await collect(150000, PaymentMethod.cash);
    await h.read(syncEngineProvider).kick();
    final rd = h.read(recordDepositProvider);
    expect(await rd.call(shown: await rd.plan(), destination: 'bank', slipPhoto: testJpeg()), DepositSaveResult.saved);
    final dep = await onlyDeposit();
    // as if the slip id never reached the server (e.g. an older app's deposit)
    await h.read(outboxWriterProvider).release(dep, const {});
    await h.read(syncEngineProvider).syncNow();
    final d = await deposit(dep);
    expect([d.syncState, d.failureCode], ['failed', 'SLIP_REQUIRED']);
    expect(depositFailureText(await AppLocalizations.delegate.load(const Locale('bn')), d.failureCode), contains('স্লিপের ছবি'));
    expect(depositFailureText(await AppLocalizations.delegate.load(const Locale('en')), d.failureCode), contains('slip photo'));
  });
}
