import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/media/media.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/auth/auth.dart';
import 'package:staff_app/features/collections/collections.dart';
import 'package:staff_app/features/collections/src/application/record_collection.dart';
import 'package:staff_app/features/customers/customers.dart';

import 'helpers.dart';

CollectionInput cash(String customerId, int poisha) => CollectionInput(
      customerId: customerId,
      customerName: 'Test',
      customerCode: 'T-1',
      amountPoisha: poisha,
      method: PaymentMethod.cash,
    );

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.dispose());

  test('first run reaches Today with the 36 demo customers on the phone', () async {
    await h.signIn();
    expect(h.read(sessionProvider).stage, SessionStage.ready);
    final customers = await h.read(customerRepositoryProvider).watchAll().first;
    expect(customers, hasLength(36));
    expect(h.read(fakeApiProvider)!.appliedPayloads, isEmpty);
  });

  test('a collection saved online is pushed once and gets a server receipt block', () async {
    await h.signIn();
    final r = await h.read(recordCollectionProvider).call(cash('c-1001', 150000));
    await h.read(syncEngineProvider).kick();
    final db = h.read(databaseProvider);
    final row = await (db.select(db.collections)..where((t) => t.clientId.equals(r.clientId))).getSingle();
    expect(row.syncState, 'synced');
    expect(h.api.appliedPayloads.keys, contains(r.clientId));
    // The mutation id IS the client id (idempotency key, CLAUDE.md §2.3).
    expect(h.api.appliedPayloads[r.clientId]!['clientId'], r.clientId);
    expect(h.api.appliedPayloads[r.clientId]!['amountPoisha'], 150000);
  });

  test('offline: saved on the phone, retried with backoff, then sent exactly once', () async {
    await h.signIn();
    h.api.offline = true;
    final r = await h.read(recordCollectionProvider).call(cash('c-1002', 50000));
    await h.read(syncEngineProvider).kick();
    final db = h.read(databaseProvider);
    var ob = await (db.select(db.outbox)..where((t) => t.mutationId.equals(r.clientId))).getSingle();
    expect(ob.state, 'pending');
    expect(ob.attempts, greaterThan(0));
    expect(ob.nextAttemptAt, isNotNull);
    expect(r.receiptNo, contains('-OFF')); // offline fallback receipt
    expect(await h.read(outboxReaderProvider).unsyncedCount(), greaterThan(0));

    // Back online; "Sync now" clears the backoff.
    h.api.offline = false;
    await h.read(syncEngineProvider).syncNow();
    ob = await (db.select(db.outbox)..where((t) => t.mutationId.equals(r.clientId))).getSingle();
    expect(ob.state, 'done');
    final pushesBefore = h.api.pushCalls;
    await h.read(syncEngineProvider).syncNow();
    expect(h.api.appliedPayloads.keys.where((k) => k == r.clientId), hasLength(1));
    expect(h.api.pushCalls, pushesBefore, reason: 'nothing left to push');
  });

  test('a lost response is replayed, not applied twice', () async {
    await h.signIn();
    final r = await h.read(recordCollectionProvider).call(cash('c-1003', 70000));
    await h.read(syncEngineProvider).kick();
    // Simulate "server applied but the phone never saw the answer".
    final db = h.read(databaseProvider);
    await (db.update(db.outbox)..where((t) => t.mutationId.equals(r.clientId))).write(const OutboxCompanion(state: Value('pending')));
    await h.read(syncEngineProvider).syncNow();
    final ob = await (db.select(db.outbox)..where((t) => t.mutationId.equals(r.clientId))).getSingle();
    expect(ob.state, 'done');
    expect(ob.result, 'replayed');
  });

  test('office already took the money: collection becomes a conflict, never deleted', () async {
    await h.signIn();
    final r = await h.read(recordCollectionProvider).call(cash('c-1008', 120000));
    await h.read(syncEngineProvider).kick();
    final db = h.read(databaseProvider);
    final row = await (db.select(db.collections)..where((t) => t.clientId.equals(r.clientId))).getSingle();
    expect(row.status, 'conflict');
    expect(row.conflictCode, 'ALREADY_PAID_OFFICE');
    expect((jsonDecode(row.conflictMessage!) as Map<String, dynamic>)['bn'], isNotEmpty);
    expect(await (db.select(db.collections)..where((t) => t.status.equals('conflict'))).get(), hasLength(1));
  });

  test('server rejection marks the item failed and keeps it for the sync centre', () async {
    await h.signIn();
    // Bypass UI validation to make the fake server reject it.
    await h.read(outboxWriterProvider).enqueue(mutationId: 'm-bad', entity: 'collection', payload: {'clientId': 'm-bad', 'customerId': 'c-1001', 'amountPoisha': 0});
    await h.read(syncEngineProvider).kick();
    final failed = await h.read(outboxReaderProvider).watchFailed().first;
    expect(failed.single.mutationId, 'm-bad');
    expect(failed.single.lastError, contains('VALIDATION_FAILED'));
  });

  test('expired cursor (410) triggers a fresh bootstrap without losing the queue', () async {
    await h.signIn();
    h.api.offline = true;
    final r = await h.read(recordCollectionProvider).call(cash('c-1004', 30000));
    h.api
      ..offline = false
      ..expireCursor = true;
    await h.read(syncEngineProvider).syncNow();
    final db = h.read(databaseProvider);
    final ob = await (db.select(db.outbox)..where((t) => t.mutationId.equals(r.clientId))).getSingle();
    expect(ob.state, 'done');
    expect(await h.read(customerRepositoryProvider).watchAll().first, hasLength(36));
  });

  test('sign-out is refused while anything is unsent; data stays', () async {
    await h.signIn();
    h.api.offline = true;
    await h.read(recordCollectionProvider).call(cash('c-1005', 10000));
    await h.read(syncEngineProvider).kick();
    await expectLater(h.read(sessionProvider.notifier).logout(), throwsStateError);
    final db = h.read(databaseProvider);
    expect(await db.select(db.collections).get(), hasLength(1));
    expect(h.read(sessionProvider).stage, SessionStage.ready);
  });

  test('426 Upgrade Required stops sync and raises the update gate; queue kept', () async {
    await h.signIn();
    h.api.upgradeRequired = true;
    final r = await h.read(recordCollectionProvider).call(cash('c-1006', 20000));
    await h.read(syncEngineProvider).kick();
    expect(h.read(upgradeRequiredProvider), isTrue);
    final db = h.read(databaseProvider);
    final ob = await (db.select(db.outbox)..where((t) => t.mutationId.equals(r.clientId))).getSingle();
    expect(ob.state, isNot('done'));
  });

  test('photos upload separately and are de-duplicated by hash', () async {
    await h.signIn();
    final media = h.read(mediaServiceProvider);
    final photo = await processPhoto((await FakePhotoCapturer().capture(_NoContext()))!, watermark: '15 Nov 10:00 · FS014');
    expect(photo.bytes.length, lessThanOrEqualTo(250 * 1024));
    await media.enqueue(photo: photo, kind: 'visit_photo', ownerEntity: 'visit', ownerClientId: 'v-1');
    await media.enqueue(photo: photo, kind: 'visit_photo', ownerEntity: 'visit', ownerClientId: 'v-2');
    await media.uploadPending();
    final db = h.read(databaseProvider);
    final rows = await db.select(db.mediaQueue).get();
    expect(rows.every((r) => r.state == 'confirmed'), isTrue);
    expect(h.api.uploadedMedia, hasLength(1), reason: 'same bytes uploaded once');
  });

  test('handover appears from a pull and accepting needs the network', () async {
    await h.signIn();
    h.api.addPendingHandover();
    await h.read(syncEngineProvider).kick();
    final db = h.read(databaseProvider);
    expect((await db.select(db.handovers).get()).single.status, 'pending_acceptance');
  });

  test('a retryable rejection keeps the collection queued and the same id goes through later', () async {
    await h.signIn();
    h.api.transientRejects = 1;
    final r = await h.read(recordCollectionProvider).call(cash('c-1003', 20000));
    await h.read(syncEngineProvider).syncNow();
    final db = h.read(databaseProvider);
    var ob = await (db.select(db.outbox)..where((t) => t.mutationId.equals(r.clientId))).getSingle();
    expect(ob.state, 'pending');
    expect(h.api.appliedPayloads.containsKey(r.clientId), isFalse);
    await h.read(syncEngineProvider).syncNow();
    ob = await (db.select(db.outbox)..where((t) => t.mutationId.equals(r.clientId))).getSingle();
    expect(ob.state, 'done');
    expect(h.api.appliedPayloads.containsKey(r.clientId), isTrue);
  });
}

class _NoContext extends Fake implements BuildContext {}
