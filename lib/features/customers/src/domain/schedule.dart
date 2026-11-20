/// Installment line money (FR-M-030). Pure rules, no I/O.
///
/// `amountPoisha` of a schedule line already includes its late fee
/// (field-api contract, `Plan.schedule[].amountPoisha`), so what is left on a
/// line is `amount − paid` and the late fee is never added a second time.
library;

/// What was paid on one installment line and what is still left on it.
class LineMoney {
  const LineMoney({required this.paidPoisha, required this.leftPoisha});
  final int paidPoisha;
  final int leftPoisha;

  /// Nothing left to pay on this line.
  bool get settled => leftPoisha == 0;

  /// Some money came in, but not all of it.
  bool get partlyPaid => paidPoisha > 0 && leftPoisha > 0;
}

LineMoney lineMoney({required int amountPoisha, required int paidPoisha}) {
  final paid = paidPoisha < 0 ? 0 : (paidPoisha > amountPoisha ? amountPoisha : paidPoisha);
  return LineMoney(paidPoisha: paid, leftPoisha: amountPoisha - paid);
}

/// The state shown for a line: `paid | overdue | due | partial | upcoming`.
///
/// The server's status is kept, so a line past its date stays **overdue** when
/// only part of it was paid (the paid and left amounts are shown next to it).
/// A line with nothing left is always `paid`, whatever an older row says.
String lineState({required String status, required int amountPoisha, required int paidPoisha}) {
  final m = lineMoney(amountPoisha: amountPoisha, paidPoisha: paidPoisha);
  if (m.settled) return 'paid';
  return switch (status) {
    'overdue' || 'due' || 'partial' => status,
    // A stale "paid" on a line that still has money left: show what is true.
    _ => m.partlyPaid ? 'partial' : 'upcoming',
  };
}

/// What is still open on one invoice, from its visible lines.
class PlanDues {
  const PlanDues({required this.remainingCount, required this.overdueCount, required this.overduePoisha});

  /// Installments with money left on them (partly paid ones included).
  final int remainingCount;

  /// Of those, the ones past their date.
  final int overdueCount;

  /// Money left on the lines past their date: only the unpaid part of a partly paid line.
  final int overduePoisha;
}

PlanDues planDues(Iterable<({String status, int amountPoisha, int paidPoisha})> lines) {
  var remaining = 0, overdueCount = 0, overdue = 0;
  for (final l in lines) {
    final m = lineMoney(amountPoisha: l.amountPoisha, paidPoisha: l.paidPoisha);
    if (m.settled) continue;
    remaining++;
    if (l.status == 'overdue') {
      overdueCount++;
      overdue += m.leftPoisha;
    }
  }
  return PlanDues(remainingCount: remaining, overdueCount: overdueCount, overduePoisha: overdue);
}
