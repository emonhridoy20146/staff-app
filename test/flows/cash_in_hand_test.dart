import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/cash/src/cash_in_hand_data.dart';
import 'package:staff_app/features/collections/collections.dart';
import 'package:staff_app/features/collections/src/application/record_collection.dart';

import 'helpers.dart';

/// FR-M-049 (field-api FR-CASH-007, contract 1.27.0): which collections my
/// cash on hand came from.
void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.dispose());

  test('deposits pay off the oldest collections first; what is left is listed newest first with customer, invoice and receipt', () async {
    await h.signIn();
    final svc = h.read(cashInHandServiceProvider);
    // ৳8,200 on hand from two collections of ৳5,000 and ৳4,500: the older one is partly handed in
    final (b, err) = await svc.load();
    expect(err, isNull);
    final before = b!;
    expect([before.onHandPoisha, before.count, before.notListed], [820000, 2, 0]);
    expect(before.items.map((i) => [i.amountPoisha, i.inHandPoisha, i.partly]), [
      [450000, 450000, false],
      [500000, 370000, true],
    ]);
    expect(before.items.first.erpPlanId, 'INV-2317');
    expect(before.items.first.customerId, 'c-1005');
    expect(before.items.first.receiptNo, isNotEmpty);
    expect(before.items.first.recordedAt, isNotNull);

    // a new cash collection reaches the server: it is on top
    await h.read(recordCollectionProvider).call(const CollectionInput(customerId: 'c-1001', customerName: 'Test', customerCode: 'T-1', amountPoisha: 150000, method: PaymentMethod.cash));
    await h.read(syncEngineProvider).kick();
    final after = (await svc.load()).$1!;
    expect([after.onHandPoisha, after.count], [970000, 3]);
    expect(after.items.first.customerId, 'c-1001');
    expect([after.items.first.amountPoisha, after.items.first.inHandPoisha], [150000, 150000]);
    expect(after.items.fold<int>(0, (n, i) => n + i.inHandPoisha), after.onHandPoisha);
  });

  test('offline there is no list', () async {
    await h.signIn();
    h.api.offline = true;
    final (data, err) = await h.read(cashInHandServiceProvider).load();
    expect(data, isNull);
    expect(err, CashInHandError.offline);
  });

  test('an answer with missing parts still reads; the customer code stands in for a missing name', () {
    final d = CashInHand.fromJson(const {
      'onHandPoisha': 1200,
      'count': 5,
      'items': [
        {'collectionId': 'x', 'amountPoisha': 1200, 'customer': {'id': 'c1', 'code': 'C-9', 'name': {'bn': ''}}},
        {'amountPoisha': 300, 'inHandPoisha': 100, 'customer': {'name': 'শুধু নাম'}},
      ],
    });
    expect([d.onHandPoisha, d.pendingDepositsPoisha, d.count, d.notListed], [1200, 0, 5, 3]);
    expect([d.items[0].nameOf('bn'), d.items[0].inHandPoisha, d.items[0].partly, d.items[0].recordedAt], ['C-9', 1200, false, null]);
    expect([d.items[1].nameOf('en'), d.items[1].customerId, d.items[1].partly], ['শুধু নাম', null, true]);
  });
}
