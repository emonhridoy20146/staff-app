/// Pure deposit rules (FR-M-059, field-api FR-CASH-010 / ADR-049, contract 1.35.0). No Flutter, no DB.
library;

import '../../../core/api/api_models.dart';

/// What one deposit hands in: always everything in hand. All the cash (the amount is fixed, a
/// deposit never takes part of it) and every mobile banking, bank or card collection not handed
/// in yet.
class DepositPlan {
  const DepositPlan({required this.cashPoisha, required this.cashCount, required this.nonCashPoisha, required this.nonCashCount});

  /// All the cash in hand, as this phone counts it (server position + unsent cash − unsent deposits).
  final int cashPoisha;

  /// Cash collections in hand that this phone holds (the server may know of older ones too).
  final int cashCount;
  final int nonCashPoisha;
  final int nonCashCount;

  int get collectionCount => cashCount + nonCashCount;

  /// The server answers `NOTHING_TO_DEPOSIT` for this, so the app does not offer it.
  bool get isEmpty => cashPoisha <= 0 && nonCashCount == 0;

  @override
  bool operator ==(Object other) =>
      other is DepositPlan && other.cashPoisha == cashPoisha && other.cashCount == cashCount && other.nonCashPoisha == nonCashPoisha && other.nonCashCount == nonCashCount;

  @override
  int get hashCode => Object.hash(cashPoisha, cashCount, nonCashPoisha, nonCashCount);
}

/// Builds the plan from the cash in hand and my collections still in hand (any method).
DepositPlan planDeposit({required int cashOnHandPoisha, required Iterable<({String method, int amountPoisha})> inHand}) {
  var cashCount = 0, nonCash = 0, nonCashCount = 0;
  for (final c in inHand) {
    if (c.method == 'cash') {
      cashCount++;
    } else {
      nonCash += c.amountPoisha;
      nonCashCount++;
    }
  }
  return DepositPlan(cashPoisha: cashOnHandPoisha < 0 ? 0 : cashOnHandPoisha, cashCount: cashCount, nonCashPoisha: nonCash, nonCashCount: nonCashCount);
}

/// Why the server refused a deposit; each has its own message in Problems.
enum DepositFailure { mustBeAll, exceedsOnHand, nothing, slipRequired, changed, other }

/// The code kept on the failed deposit: `details.rule` (422 BUSINESS_RULE) or `details.reason`
/// (409 INVALID_STATE), else the error code.
String? depositFailureCode(Problem? p) {
  final d = p?.details;
  return (d?['rule'] as String?) ?? (d?['reason'] as String?) ?? p?.code;
}

DepositFailure depositFailureOf(String? code) => switch (code) {
      'DEPOSIT_MUST_BE_ALL' => DepositFailure.mustBeAll,
      'DEPOSIT_EXCEEDS_ON_HAND' => DepositFailure.exceedsOnHand,
      'NOTHING_TO_DEPOSIT' => DepositFailure.nothing,
      'SLIP_REQUIRED' => DepositFailure.slipRequired,
      'STATUS_CHANGED' => DepositFailure.changed,
      _ => DepositFailure.other,
    };

/// How a deposit row reads in the history (contract 1.35.0: `submitted` is final).
enum DepositState { onPhone, failed, deposited, verified, rejected, deleted }

DepositState depositStateOf({required String status, required String syncState}) {
  if (syncState == 'failed') return DepositState.failed;
  if (syncState != 'synced') return DepositState.onPhone;
  return switch (status) {
    'verified' => DepositState.verified,
    'rejected' => DepositState.rejected,
    'deleted' => DepositState.deleted,
    // `submitted` (1.35.0) and `pending` from before it: nobody verifies a deposit any more.
    _ => DepositState.deposited,
  };
}
