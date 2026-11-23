import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/src/data/customer_repository.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart';
import 'package:staff_app/features/customers/src/domain/month_people.dart';

import '../flows/helpers.dart';

/// FR-M-066 (owner request 2026-11-23): installment and credit-sale chips on the customer list, ANDed with the
/// other chips; the open invoices of each kind are counted in the repository's SQL from `plans.kind`.
void main() {
  PlansCompanion plan(String id, String customer, {String kind = 'installment', String status = 'active', int outstanding = 100000, String? invoiceNo, String? saleDate}) =>
      PlansCompanion.insert(
        erpPlanId: id,
        customerId: customer,
        product: 'Fridge',
        startDate: '2026-01-01',
        finalDueDate: '2027-01-01',
        installmentCount: 12,
        totalPayablePoisha: 1200000,
        paidPoisha: 0,
        outstandingPoisha: outstanding,
        status: status,
        kind: Value(kind),
        invoiceNo: Value(invoiceNo),
        saleDate: Value(saleDate),
      );

  CustomerRow row(String id, {int daysOverdue = 0}) => CustomerRow(
        serverId: id,
        code: id,
        nameBn: id,
        phonesJson: '[]',
        locationStatus: 'ok',
        totalOutstandingPoisha: 100000,
        overduePoisha: 0,
        daysOverdue: daysOverdue,
        dueToday: false,
        overdue: daysOverdue > 0,
        badSuggested: false,
        tagState: 'none',
        pendingFieldPoisha: 0,
        searchText: id,
        version: 0,
      );

  group('rules', () {
    test('Overdue + Installment shows only overdue customers with an installment invoice; both kinds match both chips', () {
      final all = [
        Customer(row('a', daysOverdue: 10), kinds: const InvoiceKinds(installment: 1)),
        Customer(row('b', daysOverdue: 10), kinds: const InvoiceKinds(credit: 1)),
        Customer(row('c'), kinds: const InvoiceKinds(installment: 1)),
        Customer(row('d', daysOverdue: 3), kinds: const InvoiceKinds(installment: 1, credit: 2)),
        Customer(row('e', daysOverdue: 3)),
      ];
      List<String> ids(CustomerFilter f, InvoiceKind? k) => applyQuery(all, today: '2026-11-15', filter: f, kind: k, sort: CustomerSort.name).map((c) => c.id).toList();
      expect(ids(CustomerFilter.overdue, InvoiceKind.installment), ['a', 'd']);
      expect(ids(CustomerFilter.overdue, InvoiceKind.credit), ['b', 'd']);
      expect(ids(CustomerFilter.all, InvoiceKind.installment), ['a', 'c', 'd']);
      expect(ids(CustomerFilter.overdue, null), ['a', 'b', 'd', 'e']);
    });

    test('withDistance keeps the invoice kinds and numbers', () {
      final c = Customer(row('a'), kinds: const InvoiceKinds(credit: 2), invoiceNos: const ['INV-1']).withDistance(40);
      expect(c.kinds, const InvoiceKinds(credit: 2));
      expect(c.invoiceNos, ['INV-1']);
      expect(c.distanceM, 40);
    });
  });

  test('the repository counts open invoices by kind in SQL, with their numbers newest sale first', () async {
    final h = Harness();
    addTearDown(h.dispose);
    await h.signIn();
    final db = h.read(databaseProvider);
    final ids = (await db.select(db.customers).get()).map((c) => c.serverId).take(3).toList();
    await db.delete(db.scheduleLines).go();
    await db.delete(db.plans).go();
    await db.batch((b) => b.insertAll(db.plans, [
          plan('p1', ids[0], invoiceNo: 'INV-10', saleDate: '2026-01-05'),
          plan('p2', ids[0], kind: 'credit', invoiceNo: 'INV-22', saleDate: '2026-06-01'),
          plan('p3', ids[0], kind: 'credit', invoiceNo: 'INV-23', saleDate: '2026-07-01'),
          // not open: returned, cancelled, settled, nothing owed
          plan('p4', ids[0], status: 'closed'),
          plan('p5', ids[0], kind: 'credit', status: 'cancelled'),
          plan('p6', ids[0], status: 'completed'),
          plan('p7', ids[0], kind: 'credit', outstanding: 0),
          plan('p8', ids[1], kind: 'credit', invoiceNo: 'INV-30'),
        ]));
    final all = await CustomerRepository(db).watchAll().first;
    Customer of(String id) => all.firstWhere((c) => c.id == id);
    expect(of(ids[0]).kinds, const InvoiceKinds(installment: 1, credit: 2));
    expect(of(ids[0]).invoiceNos, ['INV-23', 'INV-22', 'INV-10']);
    expect(of(ids[1]).kinds, const InvoiceKinds(credit: 1));
    expect(of(ids[2]).kinds, InvoiceKinds.none);
    expect(of(ids[2]).invoiceNos, isEmpty);
    final one = await CustomerRepository(db).watchOne(ids[0]).first;
    expect(one!.kinds, const InvoiceKinds(installment: 1, credit: 2));
  });

  group('who did this month\'s work (FR-M-068)', () {
    test('latest visit of the month with its name; the user\'s own visit is shown with the user\'s name', () {
      final p = monthPeopleOf(
        today: '2026-11-15',
        myName: 'রহিম',
        myVisits: [
          (at: DateTime.utc(2026, 11, 3, 5), userName: null, byMe: true),
          (at: DateTime.utc(2026, 10, 31, 17, 30), userName: null, byMe: true), // 23:30 Dhaka, 31 Oct: last month
        ],
        colleagueVisits: [(at: DateTime.utc(2026, 11, 1, 4), name: 'করিম')],
        paymentCollectors: ['জামাল', null, 'জামাল', ' ', 'অফিস: সালমা'],
        promiseBy: 'করিম',
      );
      expect(p.visitBy, 'রহিম');
      expect(p.paidBy, ['জামাল', 'অফিস: সালমা']);
      expect(p.promiseBy, 'করিম');
    });

    test('a colleague\'s later visit wins; nothing known gives no names', () {
      final p = monthPeopleOf(
        today: '2026-11-15',
        myName: 'রহিম',
        myVisits: [(at: DateTime.utc(2026, 11, 3, 5), userName: null, byMe: true)],
        colleagueVisits: [(at: DateTime.utc(2026, 11, 9, 4), name: 'করিম')],
        paymentCollectors: const [],
        promiseBy: null,
      );
      expect(p.visitBy, 'করিম');
      final none = monthPeopleOf(today: '2026-11-15', myName: null, myVisits: const [], colleagueVisits: const [], paymentCollectors: const [], promiseBy: null);
      expect(none.visitBy, isNull);
      expect(none.paidBy, isEmpty);
      expect(none.promiseBy, isNull);
    });

    test('promise maker: createdByName, else the user for a promise of this phone, else the colleague', () {
      expect(promiseMakerName(ownRow: true, createdByName: 'করিম', colleagueName: null, myName: 'রহিম'), 'করিম');
      expect(promiseMakerName(ownRow: true, createdByName: null, colleagueName: null, myName: 'রহিম'), 'রহিম');
      expect(promiseMakerName(ownRow: false, createdByName: null, colleagueName: 'সালমা', myName: 'রহিম'), 'সালমা');
      expect(promiseMakerName(ownRow: false, createdByName: null, colleagueName: null, myName: 'রহিম'), isNull);
    });
  });
}
