import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/collections/collections.dart';
import 'package:staff_app/features/collections/src/application/record_collection.dart';
import 'package:staff_app/features/customers/customers.dart';

import 'helpers.dart';

/// FR-CUS-023 (contract 1.50.0, FR-M-080, ADR-M43): an invoice returned in the ERP while a
/// collection against it waits on the phone. The plan goes on the next pull, the
/// customer and the collection stay, and the collection ends up in Problems.
void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.dispose());

  test('returned invoice: plan removed on pull, customer and unsynced collection kept, then PLAN_CLOSED in Problems', () async {
    await h.signIn();
    final db = h.read(databaseProvider);
    const customerId = 'c-1002';
    final plan = (await (db.select(db.plans)..where((t) => t.customerId.equals(customerId))).get()).first;
    final invoiceNo = plan.invoiceNo!;

    // Recorded on the phone; the server is busy, so it stays unsynced.
    final r = await h.read(recordCollectionProvider).call(CollectionInput(
          customerId: customerId,
          customerName: 'Test',
          customerCode: 'T-1',
          erpPlanId: plan.erpPlanId,
          amountPoisha: 50000,
          method: PaymentMethod.cash,
        ));
    h.api.transientRejects = 1;
    h.api.returnInvoice(customerId, plan.erpPlanId);
    await h.read(syncEngineProvider).kick();

    // Pulled: the plan and its schedule are gone, the customer is not.
    expect(await (db.select(db.plans)..where((t) => t.erpPlanId.equals(plan.erpPlanId))).get(), isEmpty);
    expect(await (db.select(db.scheduleLines)..where((t) => t.erpPlanId.equals(plan.erpPlanId))).get(), isEmpty);
    expect(await h.read(customerRepositoryProvider).getOne(customerId), isNotNull);
    final search = (await h.read(customerRepositoryProvider).getOne(customerId))!.row.searchText;
    expect(search, isNot(contains(invoiceNo.toLowerCase().replaceAll('-', ''))));
    // CLAUDE.md §2.3: the unsynced collection and its outbox item are untouched.
    final ob = await (db.select(db.outbox)..where((t) => t.mutationId.equals(r.clientId))).getSingle();
    expect(ob.state, 'pending');
    final col = await (db.select(db.collections)..where((t) => t.clientId.equals(r.clientId))).getSingle();
    expect(col.erpPlanId, plan.erpPlanId);

    // It still goes up and comes back as a PLAN_CLOSED conflict, shown in Problems.
    await h.read(syncEngineProvider).syncNow();
    final problems = await h.read(collectionRepositoryProvider).watchProblems().first;
    expect(problems.map((c) => c.clientId), contains(r.clientId));
    expect(problems.firstWhere((c) => c.clientId == r.clientId).conflictCode, 'PLAN_CLOSED');
  });
}
