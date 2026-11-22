/// Pure collection rules (unit-tested, no Flutter / DB).
library;

enum PaymentMethod { cash, bkash, nagad, rocket, bankTransfer, otherMobile }

extension PaymentMethodX on PaymentMethod {
  /// Contract enum value (`PaymentMethod` in openapi.yaml).
  String get wire => switch (this) {
        PaymentMethod.cash => 'cash',
        PaymentMethod.bkash => 'bkash',
        PaymentMethod.nagad => 'nagad',
        PaymentMethod.rocket => 'rocket',
        PaymentMethod.bankTransfer => 'bank_transfer',
        PaymentMethod.otherMobile => 'other_mobile',
      };

  bool get needsTxnRef => this != PaymentMethod.cash;

  static PaymentMethod fromWire(String s) => PaymentMethod.values.firstWhere((m) => m.wire == s, orElse: () => PaymentMethod.otherMobile);
}

/// Transaction ids: letters/digits, 8–20 chars (auto-uppercased).
final _txn = RegExp(r'^[A-Z0-9]{8,20}$');

String normalizeTxnRef(String s) => s.trim().toUpperCase().replaceAll(RegExp(r'\s'), '');

bool isValidTxnRef(String s) => _txn.hasMatch(normalizeTxnRef(s));

enum CollectionValidation { ok, amountZero, txnMissing, txnInvalid }

CollectionValidation validateCollection({required int amountPoisha, required PaymentMethod method, String? txnRef}) {
  if (amountPoisha <= 0) return CollectionValidation.amountZero;
  if (method.needsTxnRef) {
    if (txnRef == null || txnRef.trim().isEmpty) return CollectionValidation.txnMissing;
    if (!isValidTxnRef(txnRef)) return CollectionValidation.txnInvalid;
  }
  return CollectionValidation.ok;
}

/// Receipt number `BRL01-FS014-261115-0007` (ADR-012): block prefix,
/// business date yymmdd, 4-digit sequence. Offline fallback uses `OFF{seq}`.
String formatReceiptNo(String prefix, String businessDate, int seq, {bool offline = false}) {
  final ymd = businessDate.replaceAll('-', '').substring(2);
  final s = offline ? 'OFF${seq.toString().padLeft(3, '0')}' : seq.toString().padLeft(4, '0');
  return '$prefix-$ymd-$s';
}

/// FR-M-031 (contract 1.13.0, OD-27): the ERP takes one payment per installment invoice
/// per day. True when this collection would be the second on [planId] today: the ERP
/// already has one ([erpPaidToday]) or this phone recorded one ([localPlanIdsToday],
/// collections of today that are not voided or rejected). Only a warning: the
/// collection is still saved and the office decides (never dropped, ADR-018).
bool sameDayPaymentRisk({
  required String? planId,
  required bool installment,
  required Set<String> erpPaidToday,
  required Iterable<String?> localPlanIdsToday,
}) =>
    planId != null && installment && (erpPaidToday.contains(planId) || localPlanIdsToday.contains(planId));

/// Remaining numbers below which a new block is requested (FR-M-007).
const receiptLowWater = 20;

/// Cash on hand offline (FR-M-008): server position at last sync + local
/// unsynced cash collections − local unsynced deposits.
int cashOnHand({required int serverOnHand, required int unsyncedCash, required int unsyncedDeposits}) =>
    serverOnHand + unsyncedCash - unsyncedDeposits;

enum CashState { ok, warning, exceeded }

CashState cashState(int onHand, int limit, {int warnPct = 80}) {
  if (limit <= 0) return CashState.ok;
  if (onHand >= limit) return CashState.exceeded;
  if (onHand * 100 >= limit * warnPct) return CashState.warning;
  return CashState.ok;
}

/// Local statuses of a collection that is still in my hand (contract 1.35.0, FR-M-059): saved on
/// the phone (`queued`) or taken by the server (`received`), and not voided, rejected or with the ERP.
const inHandStatuses = {'queued', 'received'};

/// FR-M-059 (field-api FR-CASH-010, ADR-049): a collection of any method stays in my hand until a
/// deposit hands it in; until then it may be changed or deleted. Once [depositId] is set (by the
/// deposit saved on this phone, or by the server) it is locked for good.
bool isInHand({required String status, required String? depositId}) => depositId == null && inHandStatuses.contains(status);

/// Locked: a deposit has handed it in, so it goes to the ERP and cannot be changed or deleted.
bool isLockedByDeposit(String? depositId) => depositId != null;
