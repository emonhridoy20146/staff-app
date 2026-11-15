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
    expect(jsonEncode(p), isNot(contains('017')));
  });
}
