import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/format/digits.dart';
import 'package:staff_app/core/settings/ui_prefs.dart';
import 'package:staff_app/features/customers/src/presentation/invoice_kind_label.dart';
import 'package:staff_app/l10n/app_localizations.dart';
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
    test('without the server\'s activity: latest visit of the month on the phone; the user\'s own visit has the user\'s name', () {
      final p = monthPeopleOf(
        today: '2026-11-15',
        myName: 'রহিম',
        myVisits: [
          (at: DateTime.utc(2026, 11, 3, 5), userName: null, byMe: true),
          (at: DateTime.utc(2026, 10, 31, 17, 30), userName: null, byMe: true), // 23:30 Dhaka, 31 Oct: last month
        ],
        colleagueVisits: [(at: DateTime.utc(2026, 11, 1, 4), name: 'করিম')],
        paymentPeople: ['জামাল', null, 'জামাল', ' ', 'সালমা'],
        promiseBy: 'করিম',
      );
      expect(p.visitBy, const Who('রহিম'));
      expect(p.paidBy, const Who('জামাল', more: 1));
      expect(p.pendingBy, isNull);
      expect(p.promiseBy, const Who('করিম'));
    });

    test('a colleague\'s later visit wins; nothing known gives no names', () {
      final p = monthPeopleOf(
        today: '2026-11-15',
        myName: 'রহিম',
        myVisits: [(at: DateTime.utc(2026, 11, 3, 5), userName: null, byMe: true)],
        colleagueVisits: [(at: DateTime.utc(2026, 11, 9, 4), name: 'করিম')],
        paymentPeople: const [],
        promiseBy: null,
      );
      expect(p.visitBy, const Who('করিম'));
      final none = monthPeopleOf(today: '2026-11-15', myName: null, myVisits: const [], colleagueVisits: const [], paymentPeople: const [], promiseBy: null);
      expect([none.visitBy, none.paidBy, none.pendingBy, none.promiseBy], everyElement(isNull));
    });

    test('contract 1.44.0 activity first: newest name with +N, office payer, pending kept apart from paid', () {
      final activity = ServerActivity.parse(encodeActivity({
        'activity': {
          'month': '2026-11',
          'visitedBy': [
            {'userId': 'u2', 'name': 'করিম', 'count': 2, 'lastAt': '2026-11-12T05:00:00Z'},
            {'userId': 'u1', 'name': 'রহিম', 'count': 1, 'lastAt': '2026-11-02T05:00:00Z'},
          ],
          'paidBy': [
            {'name': 'রহিম', 'source': 'staff', 'userId': 'u1', 'amountPoisha': 50000, 'lastDate': '2026-11-14', 'pending': true},
            {'name': '', 'source': 'unknown', 'amountPoisha': 120000, 'lastDate': '2026-11-10', 'pending': false},
            {'name': 'সালমা', 'source': 'erp_referrer', 'amountPoisha': 80000, 'lastDate': '2026-11-05', 'pending': false},
          ],
          'promisedBy': [
            {'userId': 'u3', 'name': 'জামাল', 'count': 1, 'lastAt': '2026-11-11T05:00:00Z'},
          ],
        },
      }));
      final p = monthPeopleOf(
        today: '2026-11-15',
        myName: 'রহিম',
        myVisits: [(at: DateTime.utc(2026, 11, 14, 5), userName: null, byMe: true)],
        colleagueVisits: const [],
        paymentPeople: const ['অন্য কেউ'],
        promiseBy: 'অন্য কেউ',
        server: activity,
      );
      expect(p.visitBy, const Who('করিম', more: 1));
      expect(p.paidBy, const Who.office(more: 1));
      expect(p.pendingBy, const Who('রহিম'));
      expect(p.promiseBy, const Who('জামাল'));
    });

    test('last month\'s activity is ignored; lastVisitByName of the list row is kept; an older server keeps the local names', () {
      final old = ServerActivity.parse(encodeActivity({'activity': {'month': '2026-10', 'visitedBy': [{'name': 'করিম'}]}}));
      final p = monthPeopleOf(today: '2026-11-15', myName: 'রহিম', myVisits: [(at: DateTime.utc(2026, 11, 3, 5), userName: null, byMe: true)], colleagueVisits: const [], paymentPeople: const [], promiseBy: null, server: old);
      expect(p.visitBy, const Who('রহিম'));
      final row = ServerActivity.parse(encodeActivity({'lastVisitByName': 'সালমা', 'activity': {'month': '2026-11'}}));
      expect(row!.lastVisitByName, 'সালমা');
      expect(monthPeopleOf(today: '2026-11-15', myName: null, myVisits: const [], colleagueVisits: const [], paymentPeople: const [], promiseBy: null, server: row).visitBy, const Who('সালমা'));
      expect(encodeActivity({'name': 'x'}), isNull);
      expect(ServerActivity.parse(null), isNull);
    });

    test('promise maker: createdByName, else the user for a promise of this phone, else the colleague', () {
      expect(promiseMakerName(ownRow: true, createdByName: 'করিম', colleagueName: null, myName: 'রহিম'), 'করিম');
      expect(promiseMakerName(ownRow: true, createdByName: null, colleagueName: null, myName: 'রহিম'), 'রহিম');
      expect(promiseMakerName(ownRow: false, createdByName: null, colleagueName: 'সালমা', myName: 'রহিম'), 'সালমা');
      expect(promiseMakerName(ownRow: false, createdByName: null, colleagueName: null, myName: 'রহিম'), isNull);
    });

    test('a payment\'s person: office → referrer first, field → collector first', () {
      expect(paymentPersonName(source: 'office', referrerName: 'সালমা', collectorName: 'ক্যাশ-০৩'), 'সালমা');
      expect(paymentPersonName(source: 'office', referrerName: null, collectorName: 'ক্যাশ-০৩'), 'ক্যাশ-০৩');
      expect(paymentPersonName(source: 'field', referrerName: 'সালমা', collectorName: 'রহিম'), 'রহিম');
    });
  });

  group('cash sales and unknown types (contract 1.44.0)', () {
    test('saleType wins over kind; missing is installment; an unknown value is kept', () {
      expect(planKindOf({'saleType': 'cash', 'kind': 'installment'}), 'cash');
      expect(planKindOf({'kind': 'credit'}), 'credit');
      expect(planKindOf(const {}), 'installment');
      expect(planKindOf({'saleType': 'lease'}), 'lease');
    });

    test('cash counts while it stands, even with nothing due; unknown types are "other"; filters ignore both', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.signIn();
      final db = h.read(databaseProvider);
      final id = (await db.select(db.customers).get()).first.serverId;
      await db.delete(db.scheduleLines).go();
      await db.delete(db.plans).go();
      await db.batch((b) => b.insertAll(db.plans, [
            plan('c1', id, kind: 'cash', outstanding: 0, status: 'completed'),
            plan('c2', id, kind: 'cash', outstanding: 0, status: 'cancelled'),
            plan('i1', id),
            plan('x1', id, kind: 'lease'),
          ]));
      final c = (await CustomerRepository(db).watchOne(id).first)!;
      expect(c.kinds, const InvoiceKinds(installment: 1, cash: 1, other: 1));
      expect(matchesKind(c, InvoiceKind.installment), isTrue);
      expect(matchesKind(c, InvoiceKind.credit), isFalse);
      expect(filterableKinds, [InvoiceKind.installment, InvoiceKind.credit]);
      // a cash sale with nothing due is never collectable
      expect(isCollectablePlan(status: 'completed', outstandingPoisha: 0), isFalse);
    });

    test('label texts: "১ কিস্তি · ১ নগদ"; one cash sale alone reads "নগদ"; unknown reads "অন্যান্য"', () {
      final l = lookupAppLocalizations(const Locale('bn'));
      const f = Fmt('bn', DigitStyle.bangla);
      List<String> texts(InvoiceKinds k, {bool counted = false}) => invoiceKindTexts(l, f, k, counted: counted).map((e) => e.$2).toList();
      expect(texts(const InvoiceKinds(installment: 1, cash: 1)), ['১ কিস্তি', '১ নগদ']);
      expect(texts(const InvoiceKinds(cash: 1)), ['নগদ']);
      expect(texts(const InvoiceKinds(other: 1)), ['অন্যান্য']);
      expect(texts(const InvoiceKinds(credit: 1), counted: true), ['১ বাকি']);
    });
  });
}
