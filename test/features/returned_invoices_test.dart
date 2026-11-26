import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/api/api_models.dart' show Json;
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/sync/sync_handlers.dart';
import 'package:staff_app/features/customers/src/data/customer_repository.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart';

/// FR-CUS-023 (owner request 2026-11-26, contract 1.50.0, FR-M-080, ADR-M43): an invoice
/// returned in the ERP is never shown. The customer stays; only the ERP-derived
/// plan and schedule rows go; unsynced field work stays. Fake data only.
void main() {
  const today = '2026-11-26';
  late AppDatabase db;
  late CustomerRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CustomerRepository(db);
  });
  tearDown(() => db.close());

  Json plan(String id, String invoiceNo) => {
        'erpPlanId': id,
        'product': 'Fridge',
        'startDate': '2026-01-01',
        'finalDueDate': '2027-01-01',
        'installmentCount': 2,
        'totalPayablePoisha': 1200000,
        'paidPoisha': 0,
        'outstandingPoisha': 1200000,
        'status': 'active',
        'kind': 'installment',
        'invoiceNo': invoiceNo,
        'schedule': [
          {'seq': 1, 'dueDate': '2026-12-01', 'amountPoisha': 600000},
          {'seq': 2, 'dueDate': '2027-01-01', 'amountPoisha': 600000},
        ],
      };

  /// [returned] null = an older server (< 1.50.0) that omits `returnedPlanIds`.
  Future<void> pull(String id, {List<Json>? plans, List<String>? returned}) => CustomerPullHandler(SyncHandlerRegistry.new).upsert(db, id, {
        'id': id,
        'code': 'C-$id',
        'name': {'bn': 'গ্রাহক $id', 'en': 'Customer $id'},
        'phones': ['01712345678'],
        'totalOutstandingPoisha': 100000,
        'plans': ?plans,
        'returnedPlanIds': ?returned,
      });

  Future<List<String>> planIds(String customerId) async =>
      [for (final p in await (db.select(db.plans)..where((t) => t.customerId.equals(customerId))).get()) p.erpPlanId]..sort();
  Future<int> scheduleOf(String planId) async => (await (db.select(db.scheduleLines)..where((t) => t.erpPlanId.equals(planId))).get()).length;
  Future<List<String>> find(String q) async {
    final all = [for (final c in await db.select(db.customers).get()) (await repo.getOne(c.serverId))!];
    return applyQuery(all, today: today, search: q, sort: CustomerSort.name).map((c) => c.id).toList();
  }

  Future<void> unsyncedCollection(String clientId, String customerId, String planId, {String outboxState = 'pending'}) async {
    final at = DateTime.utc(2026, 11, 26, 5);
    await db.into(db.collections).insert(CollectionsCompanion.insert(
          clientId: clientId,
          customerId: customerId,
          customerName: 'গ্রাহক $customerId',
          customerCode: 'C-$customerId',
          erpPlanId: Value(planId),
          amountPoisha: 50000,
          method: 'cash',
          receiptNo: 'R-$clientId',
          recordedAt: at,
          deviceTime: at,
          businessDate: today,
        ));
    await db.into(db.outbox).insert(OutboxCompanion.insert(
          mutationId: clientId,
          entity: 'collection',
          op: 'create',
          payloadJson: '{"clientId":"$clientId","customerId":"$customerId","erpPlanId":"$planId","amountPoisha":50000}',
          createdAt: at,
          state: Value(outboxState),
        ));
  }

  test('a pull with returnedPlanIds removes the plan and its schedule, keeps the customer and unsynced work', () async {
    await pull('a', plans: [plan('p-1', 'S-24052'), plan('p-2', 'S-24053')], returned: const []);
    await unsyncedCollection('col-1', 'a', 'p-1');
    await unsyncedCollection('col-2', 'a', 'p-1', outboxState: 'failed');
    expect(await scheduleOf('p-1'), 2);

    await pull('a', plans: [plan('p-2', 'S-24053')], returned: const ['p-1']);

    expect(await planIds('a'), ['p-2']);
    expect(await scheduleOf('p-1'), 0);
    expect(await scheduleOf('p-2'), 2);
    expect(await repo.getOne('a'), isNotNull);
    // CLAUDE.md §2.3: the collections and their outbox items stay, the failed one still a Problem.
    final cols = await (db.select(db.collections)..where((t) => t.erpPlanId.equals('p-1'))).get();
    expect(cols.map((c) => c.clientId), unorderedEquals(['col-1', 'col-2']));
    final ob = {for (final o in await db.select(db.outbox).get()) o.mutationId: o.state};
    expect(ob, {'col-1': 'pending', 'col-2': 'failed'});
  });

  test('a returned id is deleted even when the payload still listed it (never shown)', () async {
    await pull('a', plans: [plan('p-1', 'S-24052')], returned: const []);
    await pull('a', plans: [plan('p-1', 'S-24052'), plan('p-2', 'S-24053')], returned: const ['p-1']);
    expect(await planIds('a'), ['p-2']);
  });

  test('a customer whose invoices are all returned stays, with no plans', () async {
    await pull('a', plans: [plan('p-1', 'S-24052')], returned: const []);
    await pull('a', plans: const [], returned: const ['p-1']);
    expect(await planIds('a'), isEmpty);
    expect(await scheduleOf('p-1'), 0);
    expect((await repo.getOne('a'))!.id, 'a');
  });

  test('from a 1.50 server, plans: [] clears the stored plans and their schedules', () async {
    await pull('a', plans: [plan('p-1', 'S-24052')]);
    await pull('a', plans: const [], returned: const []);
    expect(await planIds('a'), isEmpty);
    expect(await scheduleOf('p-1'), 0);
    expect(await find('24052'), isEmpty);
  });

  test('from a 1.50 server, a payload without plans keeps them but still drops a returned one', () async {
    await pull('a', plans: [plan('p-1', 'S-24052'), plan('p-2', 'S-24053')]);
    await pull('a', returned: const ['p-1']);
    expect(await planIds('a'), ['p-2']);
    expect(await find('24052'), isEmpty);
    expect(await find('24053'), ['a']);
  });

  test('an older server (no returnedPlanIds) keeps the stored plans when a pull carries none', () async {
    await pull('a', plans: [plan('p-1', 'S-24052')]);
    await pull('a'); // no plans key
    expect(await planIds('a'), ['p-1']);
    await pull('a', plans: const []); // empty list, no returnedPlanIds
    expect(await planIds('a'), ['p-1']);
    expect(await scheduleOf('p-1'), 2);
    expect(await find('24052'), ['a']);
  });

  test('an older server still replaces plans with a non-empty list', () async {
    await pull('a', plans: [plan('p-1', 'S-24052')]);
    await pull('a', plans: [plan('p-2', 'S-24053')]);
    expect(await planIds('a'), ['p-2']);
    expect(await scheduleOf('p-1'), 0, reason: 'schedule rows of a dropped plan go with it');
  });

  test('search no longer finds the returned invoice number', () async {
    await pull('a', plans: [plan('p-1', 'S-24052'), plan('p-2', 'S-24053')], returned: const []);
    await pull('b', plans: [plan('p-3', 'S-11870')], returned: const []);
    expect(await find('S-24052'), ['a']);

    await pull('a', plans: [plan('p-2', 'S-24053')], returned: const ['p-1']);

    expect(await find('S-24052'), isEmpty);
    expect(await find('24052'), isEmpty);
    expect(await find('S-24053'), ['a']);
    expect(await find('11870'), ['b']);
    expect(await find('গ্রাহক a'), ['a'], reason: 'the customer is still found by name');
  });

  test('a returned plan held here under another customer goes too, and leaves that search text', () async {
    await pull('a', plans: [plan('p-1', 'S-24052')], returned: const []);
    await pull('b', plans: [plan('p-3', 'S-11870')], returned: const ['p-1']);
    expect(await planIds('a'), isEmpty);
    expect(await find('24052'), isEmpty);
    expect(await find('11870'), ['b']);
  });
}
