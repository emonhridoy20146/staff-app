import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/sync/sync_handlers.dart';
import 'package:staff_app/features/collections/src/domain/collection_rules.dart';
import 'package:staff_app/features/customers/src/data/customer_repository.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart';

/// Contract 1.13.0: the real Laravel ERP shape (field-api ADR-033, FR-M-030/031).
/// Fake names and phones only.
void main() {
  group('same-day payment warning', () {
    test('only for an installment invoice that already has a payment today', () {
      expect(sameDayPaymentRisk(planId: 'p1', installment: true, erpPaidToday: {'p1'}, localPlanIdsToday: const []), isTrue);
      expect(sameDayPaymentRisk(planId: 'p1', installment: true, erpPaidToday: const {}, localPlanIdsToday: const ['p1']), isTrue);
      expect(sameDayPaymentRisk(planId: 'p1', installment: true, erpPaidToday: {'p2'}, localPlanIdsToday: const [null, 'p3']), isFalse);
      // credit invoices take any number of payments a day
      expect(sameDayPaymentRisk(planId: 'p1', installment: false, erpPaidToday: {'p1'}, localPlanIdsToday: const ['p1']), isFalse);
      // no invoice chosen: the server spreads it, nothing to warn about
      expect(sameDayPaymentRisk(planId: null, installment: true, erpPaidToday: {'p1'}, localPlanIdsToday: const ['p1']), isFalse);
    });
  });

  group('ERP invoice details', () {
    test('returned, cancelled and settled invoices are not collectable', () {
      expect(isCollectablePlan(status: 'active', outstandingPoisha: 100), isTrue);
      expect(isCollectablePlan(status: 'defaulted', outstandingPoisha: 100), isTrue);
      expect(isCollectablePlan(status: 'closed', outstandingPoisha: 100), isFalse);
      expect(isCollectablePlan(status: 'cancelled', outstandingPoisha: 100), isFalse);
      expect(isCollectablePlan(status: 'completed', outstandingPoisha: 100), isFalse);
      expect(isCollectablePlan(status: 'active', outstandingPoisha: 0), isFalse);
    });

    test('products: name, model and quantity above one; rows without a name are skipped', () {
      final items = decodePlanItems(jsonEncode([
        {'name': ' Fridge ', 'model': 'FR-200', 'qty': 2, 'serials': ['SN1', 'SN2']},
        {'name': 'Fan', 'qty': 1},
        {'name': '', 'model': 'X'},
        'junk',
      ]));
      expect(items.map((i) => i.label), ['Fridge FR-200 ×2', 'Fan']);
      expect(items.first.serials, ['SN1', 'SN2']);
      expect(decodePlanItems(null), isEmpty);
      expect(decodePlanItems('{}'), isEmpty);
    });

    test('ERP risk: grade and level; N/A and empty grades mean no badge', () {
      final r = ErpRisk.parse(jsonEncode({'grade': 'D', 'level': 'High', 'overdueCount': 3, 'maxDaysLate': 64}))!;
      expect(r.grade, 'D');
      expect(r.levelKey, 'high');
      expect(r.overdueCount, 3);
      expect(r.maxDaysLate, 64);
      expect(ErpRisk.parse(jsonEncode({'grade': 'A', 'level': 'Unknown'}))!.levelKey, isNull);
      expect(ErpRisk.parse(jsonEncode({'grade': 'N/A'})), isNull);
      expect(ErpRisk.parse(jsonEncode({'grade': ''})), isNull);
      expect(ErpRisk.parse(null), isNull);
    });

    test('guarantor: the first of the ERP phones when no single phone was sent', () {
      final g = Guarantor.parse(jsonEncode({'name': 'Test Guarantor', 'phones': [' ', '01700000001', '01700000002']}))!;
      expect(g.phone, '01700000001');
      expect(g.canCall, isTrue);
      expect(Guarantor.parse(jsonEncode({'name': 'Test Guarantor', 'phone': '01700000003', 'phones': ['01700000001']}))!.phone, '01700000003');
      expect(Guarantor.parse(jsonEncode({'name': '', 'phones': []})), isNull);
    });
  });

  group('customer pull with the ERP shape', () {
    late AppDatabase db;
    late CustomerRepository repo;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = CustomerRepository(db);
    });
    tearDown(() => db.close());

    Map<String, dynamic> detail() => {
          'id': 'c1',
          'code': 'C-0001',
          'name': {'bn': 'পরীক্ষা গ্রাহক'},
          'phones': ['01700000009'],
          'address': 'Village A',
          'detailedAddress': 'Village A, Road 2, near the school',
          'directions': 'Second house after the mosque',
          'erpRisk': {'grade': 'C', 'level': 'Medium', 'overdueCount': 1, 'maxDaysLate': 12},
          'totalOutstandingPoisha': 1500000,
          'plans': [
            {
              'erpPlanId': 'inv-1',
              'kind': 'installment',
              'invoiceNo': 'INV-1001',
              'product': 'Fridge',
              'startDate': '2026-06-01',
              'finalDueDate': '2026-12-01',
              'installmentCount': 4,
              'totalPayablePoisha': 2000000,
              'paidPoisha': 1000000,
              'outstandingPoisha': 1000000,
              'status': 'active',
              'frequency': 'monthly',
              'items': [
                {'name': 'Fridge', 'model': 'FR-200', 'qty': 1, 'serials': ['SN1']},
              ],
              'guarantor': {'name': 'Test Guarantor', 'phones': ['01700000001']},
              'schedule': [
                {'seq': 1, 'dueDate': '2026-09-01', 'amountPoisha': 500000, 'paidPoisha': 500000, 'status': 'paid'},
                {'seq': 2, 'dueDate': '2026-10-01', 'amountPoisha': 0, 'paidPoisha': 0, 'status': 'paid', 'rolled': true},
                {'seq': 3, 'dueDate': '2026-11-01', 'amountPoisha': 520000, 'paidPoisha': 0, 'status': 'overdue', 'lateFeePoisha': 20000},
              ],
            },
            {
              'erpPlanId': 'inv-2',
              'kind': 'credit',
              'invoiceNo': 'INV-1002',
              'product': 'Fan',
              'startDate': '2026-10-01',
              'finalDueDate': '2026-11-30',
              'installmentCount': 0,
              'totalPayablePoisha': 500000,
              'paidPoisha': 0,
              'outstandingPoisha': 500000,
              'status': 'active',
              'writtenOffPoisha': 10000,
            },
            {
              'erpPlanId': 'inv-3',
              'invoiceNo': 'INV-0900',
              'product': 'TV',
              'startDate': '2025-01-01',
              'finalDueDate': '2025-12-01',
              'installmentCount': 12,
              'totalPayablePoisha': 900000,
              'paidPoisha': 300000,
              'outstandingPoisha': 600000,
              'status': 'closed',
            },
          ],
          'payments': [
            {'erpPaymentId': 'pay-1', 'erpPlanId': 'inv-1', 'date': '2026-11-18', 'amountPoisha': 100000, 'method': 'cash', 'methodLabel': 'Cash', 'collectorName': 'Test Collector', 'source': 'office'},
            {'erpPaymentId': 'pay-2', 'erpPlanId': 'inv-2', 'date': '2026-11-18', 'amountPoisha': 50000, 'method': 'cash', 'source': 'office', 'advance': true},
            {'erpPaymentId': 'pay-3', 'erpPlanId': 'inv-3', 'date': '2026-11-18', 'amountPoisha': 50000, 'method': 'cash', 'source': 'office', 'reversed': true},
            {'erpPaymentId': 'pay-4', 'planId': 'inv-3', 'date': '2026-11-17', 'amountPoisha': 50000, 'method': 'bank', 'source': 'office', 'discountPoisha': 5000},
          ],
        };

    Future<void> pull() => CustomerPullHandler(SyncHandlerRegistry.new).upsert(db, 'c1', detail());

    test('customer address, directions and ERP risk are kept', () async {
      await pull();
      final c = (await repo.getOne('c1'))!;
      expect(c.detailedAddress, 'Village A, Road 2, near the school');
      expect(c.directions, 'Second house after the mosque');
      expect(c.erpRisk!.levelKey, 'medium');
    });

    test('invoices: number, kind, products, guarantor; rolled lines hidden; late fee kept', () async {
      await pull();
      final plans = {for (final p in await repo.watchPlans('c1').first) p.plan.erpPlanId: p};
      final inv1 = plans['inv-1']!;
      expect(inv1.plan.invoiceNo, 'INV-1001');
      expect(inv1.credit, isFalse);
      expect(inv1.plan.frequency, 'monthly');
      expect(inv1.items.single.label, 'Fridge FR-200');
      expect(inv1.guarantor!.phone, '01700000001');
      expect(inv1.rolledCount, 1);
      expect(inv1.visibleSchedule.map((s) => s.seq), [1, 3]);
      expect(inv1.paidCount, 1);
      expect(inv1.shownCount, 2);
      expect(inv1.visibleSchedule.last.lateFeePoisha, 20000);
      expect(inv1.collectable, isTrue);

      final inv2 = plans['inv-2']!;
      expect(inv2.credit, isTrue);
      expect(inv2.plan.writtenOffPoisha, 10000);
      expect(inv2.shownCount, 0);

      final inv3 = plans['inv-3']!;
      expect(inv3.plan.kind, 'installment');
      expect(inv3.closedInErp, isTrue);
      expect(inv3.collectable, isFalse);
    });

    test('payments: ERP labels kept; today\'s paid invoices leave out advances and removed payments', () async {
      await pull();
      final pays = {for (final p in await db.select(db.erpPayments).get()) p.erpPaymentId: p};
      expect(pays['pay-1']!.planId, 'inv-1');
      expect(pays['pay-1']!.methodLabel, 'Cash');
      expect(pays['pay-1']!.collectorName, 'Test Collector');
      expect(pays['pay-2']!.advance, isTrue);
      expect(pays['pay-4']!.planId, 'inv-3');
      expect(pays['pay-4']!.discountPoisha, 5000);
      expect(await repo.watchPlansPaidOn('c1', '2026-11-18').first, {'inv-1'});
      expect(await repo.watchPlansPaidOn('c1', '2026-11-17').first, {'inv-3'});
    });
  });
}
