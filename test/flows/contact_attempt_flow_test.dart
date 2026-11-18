import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/src/contact_attempts.dart';

import 'helpers.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    // Let fire-and-forget sync kicks / flushes finish before the DB closes.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  test('a call record is saved offline and pushed with the phone index, never the number', () async {
    await h.signIn();
    h.api.offline = true;
    await h.read(contactAttemptServiceProvider).record(customerId: 'c-1001', phoneIndex: 0, at: h.clock.nowUtc(), outcome: 'no_answer');
    final db = h.read(databaseProvider);
    final rows = await db.select(db.contactAttempts).get();
    expect(rows.single.syncState, 'queued');
    await h.read(syncEngineProvider).kick();
    expect(h.api.appliedPayloads, isEmpty);

    h.api.offline = false;
    await h.read(syncEngineProvider).syncNow();
    expect((await db.select(db.contactAttempts).get()).single.syncState, 'synced');
    final p = h.api.appliedPayloads.values.singleWhere((x) => x.containsKey('phoneIndex'));
    expect(p['phoneIndex'], 0);
    expect(p['outcome'], 'no_answer');
    // Never the number: none of this customer's numbers (nor their last 8
    // digits) and no phone field. Checked against the real numbers, because
    // the payload's random UUIDv7 can contain any short digit run like '017'.
    final customer = await (db.select(db.customers)..where((c) => c.serverId.equals('c-1001'))).getSingle();
    final numbers = RegExp(r'\d{10,}').allMatches(customer.phonesJson).map((m) => m.group(0)!).toList();
    expect(numbers, isNotEmpty);
    final body = jsonEncode(p);
    for (final n in numbers) {
      expect(body, isNot(contains(n.substring(n.length - 8))));
    }
    expect(p.keys.where((k) => k.toLowerCase().contains('phone') && k != 'phoneIndex'), isEmpty);
    expect(p.containsKey('number'), isFalse);
  });
}
