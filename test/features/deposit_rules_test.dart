import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/api/api_models.dart';
import 'package:staff_app/features/cash/src/deposit_rules.dart';
import 'package:staff_app/features/collections/collections.dart';

/// FR-M-059 (field-api FR-CASH-010, ADR-049, contract 1.35.0): one deposit hands in everything in
/// hand; a collection is locked once a deposit has it.
void main() {
  group('deposit everything', () {
    test('all the cash and every mobile / bank collection go together; the cash amount is fixed', () {
      final p = planDeposit(cashOnHandPoisha: 820000, inHand: const [
        (method: 'cash', amountPoisha: 450000),
        (method: 'bkash', amountPoisha: 120000),
        (method: 'bank_transfer', amountPoisha: 300000),
        (method: 'cash', amountPoisha: 370000),
      ]);
      expect([p.cashPoisha, p.cashCount, p.nonCashPoisha, p.nonCashCount, p.collectionCount, p.isEmpty], [820000, 2, 420000, 2, 4, false]);
    });

    test('only mobile money in hand: a deposit of ৳0 cash is still a deposit', () {
      final p = planDeposit(cashOnHandPoisha: 0, inHand: const [(method: 'nagad', amountPoisha: 50000)]);
      expect([p.cashPoisha, p.nonCashCount, p.isEmpty], [0, 1, false]);
    });

    test('nothing in hand: nothing to deposit (the server would answer NOTHING_TO_DEPOSIT)', () {
      expect(planDeposit(cashOnHandPoisha: 0, inHand: const []).isEmpty, isTrue);
    });

    test('a negative estimate on the phone never becomes a negative deposit', () {
      expect(planDeposit(cashOnHandPoisha: -500, inHand: const []).cashPoisha, 0);
    });

    test('two plans of the same money are equal (what was confirmed is what is saved)', () {
      const a = DepositPlan(cashPoisha: 1, cashCount: 1, nonCashPoisha: 2, nonCashCount: 1);
      expect(a, const DepositPlan(cashPoisha: 1, cashCount: 1, nonCashPoisha: 2, nonCashCount: 1));
      expect(a == const DepositPlan(cashPoisha: 2, cashCount: 1, nonCashPoisha: 2, nonCashCount: 1), isFalse);
    });
  });

  group('lock', () {
    test('a collection of any method is in hand until a deposit has it', () {
      expect(isInHand(status: 'queued', depositId: null), isTrue);
      expect(isInHand(status: 'received', depositId: null), isTrue);
      expect(isInHand(status: 'received', depositId: 'dep-local'), isFalse);
      expect(isInHand(status: 'posted', depositId: null), isFalse);
      expect(isInHand(status: 'voided', depositId: null), isFalse);
      expect(isLockedByDeposit('dep-1'), isTrue);
      expect(isLockedByDeposit(null), isFalse);
    });
  });

  group('refused deposits', () {
    Problem rule(String r) => Problem(status: 422, code: 'BUSINESS_RULE', title: 'x', details: {'rule': r, 'onHandPoisha': 5});
    test('the rule or reason of the refusal is kept, else the code', () {
      expect(depositFailureCode(rule('DEPOSIT_MUST_BE_ALL')), 'DEPOSIT_MUST_BE_ALL');
      expect(depositFailureCode(const Problem(status: 409, code: 'INVALID_STATE', title: 'x', details: {'reason': 'STATUS_CHANGED'})), 'STATUS_CHANGED');
      expect(depositFailureCode(const Problem(status: 400, code: 'VALIDATION_FAILED', title: 'x')), 'VALIDATION_FAILED');
      expect(depositFailureCode(null), isNull);
    });
    test('each known refusal has its own message', () {
      expect(depositFailureOf('DEPOSIT_MUST_BE_ALL'), DepositFailure.mustBeAll);
      expect(depositFailureOf('DEPOSIT_EXCEEDS_ON_HAND'), DepositFailure.exceedsOnHand);
      expect(depositFailureOf('NOTHING_TO_DEPOSIT'), DepositFailure.nothing);
      expect(depositFailureOf('SLIP_REQUIRED'), DepositFailure.slipRequired);
      expect(depositFailureOf('STATUS_CHANGED'), DepositFailure.changed);
      expect(depositFailureOf('SOMETHING_NEW'), DepositFailure.other);
      expect(depositFailureOf(null), DepositFailure.other);
    });
  });

  group('history', () {
    test('submitted is final and reads "deposited"; old deposits keep their state', () {
      expect(depositStateOf(status: 'submitted', syncState: 'synced'), DepositState.deposited);
      expect(depositStateOf(status: 'pending', syncState: 'synced'), DepositState.deposited);
      expect(depositStateOf(status: 'verified', syncState: 'synced'), DepositState.verified);
      expect(depositStateOf(status: 'rejected', syncState: 'synced'), DepositState.rejected);
      expect(depositStateOf(status: 'deleted', syncState: 'synced'), DepositState.deleted);
      expect(depositStateOf(status: 'submitted', syncState: 'queued'), DepositState.onPhone);
      expect(depositStateOf(status: 'submitted', syncState: 'failed'), DepositState.failed);
    });
  });
}
