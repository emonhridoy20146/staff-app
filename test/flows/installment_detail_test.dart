import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/customers/src/domain/customer.dart';

import 'helpers.dart';

/// FR-M-054 (contract 1.14.0, schema 11): the ERP's own record of every installment
/// reaches the phone: paid on which day, how many days late, missed, and the payments.
void main() {
  test('decodes the payments of a line; nothing or junk reads as none', () {
    expect(decodeLinePayments(null), isEmpty);
    expect(decodeLinePayments(''), isEmpty);
    expect(decodeLinePayments('{"x":1}'), isEmpty);
    final p = decodeLinePayments('[{"id":"e1","date":"2026-10-09","amountPoisha":500000,"receiptNo":"R-1"},{"date":"2026-10-12","amountPoisha":1000}]');
    expect(p.map((x) => (x.date, x.amountPoisha, x.receiptNo)), [('2026-10-09', 500000, 'R-1'), ('2026-10-12', 1000, null)]);
  });

  test('after the first sync, paid lines carry their paid-on date and payments, overdue ones are marked missed', () async {
    final h = Harness();
    addTearDown(h.dispose);
    await h.signIn();
    final db = h.read(databaseProvider);
    final lines = await db.select(db.scheduleLines).get();
    final paid = lines.where((l) => l.status == 'paid').toList();
    expect(paid, isNotEmpty);
    for (final l in paid) {
      expect(l.paidOn, isNotNull);
      final pays = decodeLinePayments(l.paymentsJson);
      expect(pays.single.amountPoisha, l.amountPoisha);
      expect(pays.single.date, l.paidOn);
    }
    expect(paid.any((l) => l.daysLate == 4), isTrue); // some were paid late in the fake ERP
    final overdue = lines.where((l) => l.status == 'overdue').toList();
    expect(overdue, isNotEmpty);
    expect(overdue.every((l) => l.missed && l.daysLate > 0 && l.paidOn == null), isTrue);
    expect(lines.where((l) => l.status == 'upcoming').every((l) => !l.missed && l.daysLate == 0), isTrue);
  });
}
