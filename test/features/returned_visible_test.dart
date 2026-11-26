import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/api/api_models.dart' show Json;
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/sync/sync_handlers.dart';
import 'package:staff_app/features/customers/src/data/customer_repository.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart';
import 'package:staff_app/features/customers/src/domain/returned_plan.dart';
import 'package:staff_app/features/customers/src/domain/work_marks.dart';
import 'package:staff_app/features/today/today.dart';

/// FR-CUS-024 (owner request 2026-11-26, contract 1.53.0, FR-M-085, ADR-M46): invoices returned in the ERP are
/// shown again, apart from the counted ones, and never counted anywhere. Fake data only, no network.
void main() {
  const today = '2026-11-26';
  late AppDatabase db;
  late CustomerRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CustomerRepository(db);
  });
  tearDown(() => db.close());

  Json plan(String id, String invoiceNo, {int outstanding = 1200000, String kind = 'installment'}) => {
        'erpPlanId': id,
        'product': 'Fridge',
        'startDate': '2026-01-01',
        'finalDueDate': '2027-01-01',
        'installmentCount': 2,
        'totalPayablePoisha': 1200000,
        'paidPoisha': 1200000 - outstanding,
        'outstandingPoisha': outstanding,
        'status': 'active',
        'kind': kind,
        'invoiceNo': invoiceNo,
        'saleDate': '2026-01-01',
        'schedule': [
          {'seq': 1, 'dueDate': '2026-12-01', 'amountPoisha': 600000},
          {'seq': 2, 'dueDate': '2027-01-01', 'amountPoisha': 600000},
        ],
      };

  /// A `returnedPlans` item as 1.53.0 sends it: closed, not collectable, no schedule, its payments marked.
  Json returnedPlan(String id, String invoiceNo, {List<Json> payments = const []}) => {
        ...plan(id, invoiceNo, outstanding: 800000),
        'product': 'TV',
        'status': 'closed',
        'returned': true,
        'collectable': false,
        'schedule': const <Json>[],
        'payments': payments,
      };

  Json payment(String id, String date, int amount, {String? planId, bool returned = false}) => {
        'erpPaymentId': id,
        'erpPlanId': ?planId,
        'date': date,
        'amountPoisha': amount,
        'method': 'cash',
        'source': 'office',
        'receiptNo': 'RC-$id',
        if (returned) 'returned': true,
      };

  /// A customer pull. [returned] = `returnedPlans` (null: an older server omits it); [returnedIds] =
  /// `returnedPlanIds` (null: omitted).
  Future<void> pull(
    String id, {
    List<Json>? plans,
    List<Json>? returned,
    List<String>? returnedIds,
    List<Json>? payments,
    int? count,
    bool? onlyReturned,
    int outstanding = 400000,
    int daysOverdue = 0,
    bool dueToday = false,
  }) =>
      CustomerPullHandler(SyncHandlerRegistry.new).upsert(db, id, {
        'id': id,
        'code': 'C-$id',
        'name': {'bn': 'গ্রাহক $id', 'en': 'Customer $id'},
        'phones': ['01712345678'],
        'totalOutstandingPoisha': outstanding,
        'daysOverdue': daysOverdue,
        'badges': [if (dueToday) 'due_today', if (daysOverdue > 0) 'overdue'],
        'plans': ?plans,
        'returnedPlans': ?returned,
        'returnedPlanIds': ?returnedIds,
        'payments': ?payments,
        'returnedInvoiceCount': ?count,
        'onlyReturned': ?onlyReturned,
      });

  Future<List<String>> counted(String customerId) async =>
      [for (final p in await (db.select(db.plans)..where((t) => t.customerId.equals(customerId))).get()) p.erpPlanId]..sort();
  Future<List<String>> returnedOf(String customerId) async =>
      [for (final p in await (db.select(db.returnedPlans)..where((t) => t.customerId.equals(customerId))).get()) p.erpPlanId]..sort();
  Future<Customer> one(String id) async => (await repo.watchOne(id).first)!;
  Future<List<Customer>> everyone() => repo.watchAll().first;

  test('an upsert with plans and returnedPlans keeps both, apart; only the counted plans count', () async {
    await pull('a',
        plans: [plan('p-1', 'S-1001'), plan('p-2', 'CR-2002', kind: 'credit')],
        returned: [returnedPlan('r-1', 'S-0999', payments: [payment('x-1', '2026-11-03', 50000, planId: 'r-1', returned: true)])],
        returnedIds: const ['r-1'],
        count: 1,
        onlyReturned: false);

    expect(await counted('a'), ['p-1', 'p-2']);
    expect(await returnedOf('a'), ['r-1']);
    final r = (await repo.watchReturnedPlans('a').first).single;
    expect([r.invoiceNo, r.row.status, r.collectable], ['S-0999', 'closed', false]);
    expect(r.payments.single.amountPoisha, 50000);

    // Counts, invoice numbers and totals read only the counted plans.
    final c = await one('a');
    expect(c.kinds, const InvoiceKinds(installment: 1, credit: 1));
    expect(c.invoiceNos, unorderedEquals(['S-1001', 'CR-2002']));
    expect(c.outstanding, 400000); // the server's number, returned invoices already left out
    expect([c.returnedInvoiceCount, c.hasReturned, c.onlyReturned], [1, true, false]);
    expect(invoiceTotals(await repo.watchPlanSummaries().first, {'a'}), (total: 2, open: 2));
    // The Collect picker's plans: no returned one among them.
    expect((await repo.watchPlans('a').first).map((p) => p.plan.erpPlanId), unorderedEquals(['p-1', 'p-2']));
  });

  test('1.50-style returnedPlanIds never deletes the returned plans just stored, nor ones stored before', () async {
    await pull('a', plans: [plan('p-1', 'S-1001'), plan('r-1', 'S-0999')], returnedIds: const []);
    expect(await counted('a'), ['p-1', 'r-1']);

    // 1.53: r-1 is returned; the same id is in returnedPlanIds and returnedPlans.
    await pull('a', plans: [plan('p-1', 'S-1001')], returned: [returnedPlan('r-1', 'S-0999')], returnedIds: const ['r-1']);
    expect(await counted('a'), ['p-1']);
    expect(await returnedOf('a'), ['r-1']);
    expect(await (db.select(db.scheduleLines)..where((t) => t.erpPlanId.equals('r-1'))).get(), isEmpty);

    // A later pull that only names it in returnedPlanIds (no returnedPlans key) keeps the stored returned plan.
    await pull('a', plans: [plan('p-1', 'S-1001')], returnedIds: const ['r-1']);
    expect(await counted('a'), ['p-1']);
    expect(await returnedOf('a'), ['r-1']);
  });

  test('every other stored plan of the customer goes; returnedPlans: [] clears the returned ones', () async {
    await pull('a', plans: [plan('p-1', 'S-1001'), plan('p-2', 'S-1002')], returned: [returnedPlan('r-1', 'S-0999'), returnedPlan('r-2', 'S-0998')]);
    await pull('a', plans: [plan('p-2', 'S-1002')], returned: [returnedPlan('r-2', 'S-0998')], returnedIds: const ['r-2']);
    expect(await counted('a'), ['p-2']);
    expect(await returnedOf('a'), ['r-2']);
    await pull('a', plans: [plan('p-2', 'S-1002')], returned: const [], returnedIds: const []);
    expect(await returnedOf('a'), isEmpty);
    expect((await one('a')).returnedInvoiceCount, 0);
  });

  test('an older server (no returnedPlans, no counts) keeps the stored returned plans; counts read as 0 / false', () async {
    await pull('a', plans: [plan('p-1', 'S-1001')], returned: [returnedPlan('r-1', 'S-0999')], count: 1);
    await pull('a', plans: [plan('p-1', 'S-1001')]);
    expect(await returnedOf('a'), ['r-1']);
    final c = await one('a');
    expect([c.returnedInvoiceCount, c.onlyReturned], [0, false]);
    // its number still finds the customer
    expect(c.row.searchText, contains('s0999'));
  });

  test('a returned invoice number finds its customer, and the hit carries the marker', () async {
    await pull('a', plans: [plan('p-1', 'S-1001')], returned: [returnedPlan('r-1', 'S-24052')], count: 1, onlyReturned: false);
    await pull('b', plans: const [], returned: [returnedPlan('r-2', 'S-77001')], count: 1, onlyReturned: true, outstanding: 0);
    await pull('z', plans: [plan('p-9', 'S-9009')]);
    final all = await everyone();
    List<Customer> find(String q) => applyQuery(all, today: today, search: q, sort: CustomerSort.name);
    expect(find('S24052').map((c) => c.id), ['a']);
    expect(find('S24052').single.hasReturned, isTrue);
    final b = find('77001').single;
    expect([b.id, b.hasReturned, b.onlyReturned], ['b', true, true]);
    expect(find('S9009').single.hasReturned, isFalse);
  });

  test('payments to a returned invoice are kept marked and never count: paid this month, paid today, month people', () async {
    await pull('a',
        plans: [plan('p-1', 'S-1001')],
        returned: [returnedPlan('r-1', 'S-0999')],
        payments: [
          payment('x-1', '2026-11-26', 70000, planId: 'r-1', returned: true),
          payment('x-2', '2026-11-20', 30000, planId: 'p-1'),
        ]);
    await pull('b',
        plans: const [],
        returned: [returnedPlan('r-2', 'S-0888')],
        onlyReturned: true,
        outstanding: 0,
        payments: [payment('y-1', '2026-11-26', 90000, planId: 'r-2', returned: true)]);

    final rows = await repo.watchPayments('a').first;
    expect({for (final p in rows) p.erpPaymentId: p.returned}, {'x-1': true, 'x-2': false});
    // ERP money this month: only the counted payment; b has none at all (no "paid this month" mark).
    final paid = await repo.watchPaidThisMonth(today).first;
    expect(paid, {'a': 30000});
    expect(await repo.watchPlansPaidOn('a', today).first, isEmpty);
    final all = await everyone();
    Customer of(String id) => all.firstWhere((c) => c.id == id);
    expect(matchesFilter(of('b'), CustomerFilter.paidThisMonth, today: today, paidThisMonth: paid), isFalse);
    expect(matchesFilter(of('a'), CustomerFilter.paidThisMonth, today: today, paidThisMonth: paid), isTrue);
    final marks = workMarksOf(today: today, lastVisitAt: null, erpPaidThisMonthPoisha: paid['b'] ?? 0, pendingFieldPoisha: 0, hasOpenPromise: false, hasPin: false);
    expect(marks.money, MoneyMark.none);
  });

  test('Home filters and counts leave an only-returned customer out; the rest keep their places', () async {
    await pull('a', plans: [plan('p-1', 'S-1001')], returned: [returnedPlan('r-1', 'S-0999')], count: 1, daysOverdue: 12);
    // An old row may still say due: every invoice is returned, so it is no Home work.
    await pull('b', plans: const [], returned: [returnedPlan('r-2', 'S-0888')], count: 1, onlyReturned: true, outstanding: 0, dueToday: true);
    final w = homeWorkOf(await everyone(), today, scopeUserId: null);
    expect([for (final c in w.listOf(HomeFilter.all)) c.id], ['a']);
    expect(w.count(HomeFilter.due), 0);
    expect(w.count(HomeFilter.overdue), 1);
    // Still listed (never hidden) in the Customers list.
    expect(applyQuery(await everyone(), today: today, sort: CustomerSort.name).map((c) => c.id), ['a', 'b']);
  });

  test('unsynced collections on a returned plan are kept: collection, outbox and media rows stay', () async {
    await pull('a', plans: [plan('p-1', 'S-1001'), plan('r-1', 'S-0999')], returnedIds: const []);
    final at = DateTime.utc(2026, 11, 26, 5);
    await db.into(db.collections).insert(CollectionsCompanion.insert(
          clientId: 'col-1',
          customerId: 'a',
          customerName: 'গ্রাহক a',
          customerCode: 'C-a',
          erpPlanId: const Value('r-1'),
          amountPoisha: 50000,
          method: 'cash',
          receiptNo: 'R-1',
          recordedAt: at,
          deviceTime: at,
          businessDate: today,
        ));
    for (final (id, state) in [('col-1', 'pending'), ('col-2', 'failed')]) {
      await db.into(db.outbox).insert(OutboxCompanion.insert(
            mutationId: id,
            entity: 'collection',
            op: 'create',
            payloadJson: '{"clientId":"$id","customerId":"a","erpPlanId":"r-1","amountPoisha":50000}',
            createdAt: at,
            state: Value(state),
          ));
    }

    await pull('a', plans: [plan('p-1', 'S-1001')], returned: [returnedPlan('r-1', 'S-0999')], returnedIds: const ['r-1'], count: 1);

    expect(await returnedOf('a'), ['r-1']);
    final col = await (db.select(db.collections)..where((t) => t.clientId.equals('col-1'))).getSingle();
    expect([col.erpPlanId, col.amountPoisha], ['r-1', 50000]);
    expect({for (final o in await db.select(db.outbox).get()) o.mutationId: o.state}, {'col-1': 'pending', 'col-2': 'failed'});
    expect((await one('a')).row.pendingFieldPoisha, 0); // not touched by the pull either way
  });

  test('a customer tombstone removes its returned plans with the rest', () async {
    await pull('a', plans: [plan('p-1', 'S-1001')], returned: [returnedPlan('r-1', 'S-0999')]);
    await CustomerPullHandler(SyncHandlerRegistry.new).delete(db, 'a');
    expect(await returnedOf('a'), isEmpty);
  });

  test('payments_json reads safely: newest first; bad text gives none', () {
    expect(decodeReturnedPayments('[{"date":"2026-10-01","amountPoisha":5},{"date":"2026-11-01","amountPoisha":7}]').map((p) => p.amountPoisha), [7, 5]);
    expect(decodeReturnedPayments('not json'), isEmpty);
    expect(decodeReturnedPayments('{}'), isEmpty);
  });
}
