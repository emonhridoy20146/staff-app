import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/src/domain/phones.dart';
import 'package:staff_app/features/customers/src/phone_numbers.dart';

import 'helpers.dart';

/// FR-M-037: numbers added on the phone, also offline (contract 1.23.0,
/// sync mutation `customer_phone`). Fake numbers only.
void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    // Let fire-and-forget sync kicks / flushes finish before the DB closes.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  test('numbers added offline show at once, go out as one customer_phone mutation and come back as added numbers', () async {
    await h.signIn();
    final db = h.read(databaseProvider);
    Future<List<CustomerPhone>> phones() async =>
        decodePhones((await (db.select(db.customers)..where((c) => c.serverId.equals('c-1001'))).getSingle()).phonesJson);
    final before = await phones();
    expect(before, isNotEmpty);
    expect(before.every((p) => p.fromErp), isTrue);
    expect(before.first.primary, isTrue);

    h.api.offline = true;
    final saved = await h.read(customerPhoneServiceProvider).add(customerId: 'c-1001', phones: [
      (number: '01811000004', label: 'wife'),
      (number: '01311000005', label: null),
      (number: before.first.number, label: null), // the customer already has it: skipped
    ]);
    expect(saved, 2);
    var now = await phones();
    expect(now.length, before.length + 2);
    expect(now.where((p) => p.pending).map((p) => p.number), ['01811000004', '01311000005']);
    // The ERP numbers keep their places at the front (a call record points at them by index).
    expect(now.take(before.length).map((p) => p.number), before.map((p) => p.number));
    await h.read(syncEngineProvider).kick();
    expect(h.api.appliedPayloads, isEmpty);

    h.api.offline = false;
    await h.read(syncEngineProvider).syncNow();
    final sent = h.api.appliedPayloads.values.singleWhere((x) => x.containsKey('phones'));
    expect(sent['customerId'], 'c-1001');
    expect(sent['phones'], [
      {'number': '01811000004', 'label': 'wife'},
      {'number': '01311000005'},
    ]);

    now = await phones();
    expect(now.any((p) => p.pending), isFalse);
    expect(now.where((p) => p.fromErp).map((p) => p.number), before.map((p) => p.number));
    expect(now.where((p) => !p.fromErp).map((p) => p.number), ['01811000004', '01311000005']);
    expect(now.firstWhere((p) => p.number == '01811000004').label, 'wife');
  });

  test('nothing is queued when every number is already there', () async {
    await h.signIn();
    final db = h.read(databaseProvider);
    final row = await (db.select(db.customers)..where((c) => c.serverId.equals('c-1001'))).getSingle();
    final first = decodePhones(row.phonesJson).first.number;
    final outboxBefore = (await db.select(db.outbox).get()).length;
    expect(await h.read(customerPhoneServiceProvider).add(customerId: 'c-1001', phones: [(number: first, label: null)]), 0);
    expect(await h.read(customerPhoneServiceProvider).add(customerId: 'no-such-customer', phones: [(number: '01811000004', label: null)]), 0);
    expect((await db.select(db.outbox).get()).length, outboxBefore);
  });

  test('FR-M-053: an added number is removed again, online only; the ERP number and a number still waiting stay', () async {
    await h.signIn();
    final db = h.read(databaseProvider);
    Future<List<CustomerPhone>> phones() async =>
        decodePhones((await (db.select(db.customers)..where((c) => c.serverId.equals('c-1002'))).getSingle()).phonesJson);
    final erp = (await phones()).first.number;
    final svc = h.read(customerPhoneServiceProvider);
    expect(await svc.add(customerId: 'c-1002', phones: [(number: '01911000006', label: 'son')]), 1);
    await h.read(syncEngineProvider).syncNow();
    expect((await phones()).where((p) => !p.fromErp).map((p) => p.number), ['01911000006']);

    // offline: nothing changes, the caller is told why
    h.api.offline = true;
    expect(await svc.remove(customerId: 'c-1002', number: '01911000006'), PhoneRemoveError.offline);
    expect((await phones()).any((p) => p.number == '01911000006'), isTrue);
    h.api.offline = false;

    // the ERP number is refused by the server and stays
    expect(await svc.remove(customerId: 'c-1002', number: erp), PhoneRemoveError.notAllowed);
    expect((await phones()).first.number, erp);

    // the added number goes, here and on the server
    expect(await svc.remove(customerId: 'c-1002', number: '01911000006'), isNull);
    expect((await phones()).any((p) => p.number == '01911000006'), isFalse);
    await h.read(syncEngineProvider).syncNow();
    expect((await phones()).map((p) => p.number), isNot(contains('01911000006')));
    expect((await phones()).first.number, erp);
  });
}
