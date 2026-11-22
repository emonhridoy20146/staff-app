import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/field_api.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';

/// Why a withdraw or edit of a collection did not happen.
enum CashActionError { offline, covered, notEditable, posted, busy, notAllowed, failed }

/// Maps the server's 409 `INVALID_STATE` reasons (contract 1.32.0) to what the user is told.
/// `NOT_CASH` is no longer sent from 1.35.0 (any method can be changed until deposited); an older
/// server may still send it.
CashActionError cashActionErrorOf(ApiException e) {
  if (e.isNetwork) return CashActionError.offline;
  if (e.statusCode == 403 || e.statusCode == 404) return CashActionError.notAllowed;
  return switch (e.problem?.details?['reason']) {
    'COVERED_BY_DEPOSIT' => CashActionError.covered,
    'NOT_EDITABLE' || 'USE_RESOLVE' || 'NOT_CASH' => CashActionError.notEditable,
    'ALREADY_POSTED_OR_CLOSED' => CashActionError.posted,
    'POSTING_IN_PROGRESS' || 'STATUS_CHANGED' => CashActionError.busy,
    _ => CashActionError.failed,
  };
}

/// Withdraw or edit one of my own collections that no deposit has handed in yet
/// (FR-M-058; any method since contract 1.35.0, FR-M-059). Online only (ADR-M23):
/// the server decides whether it is still in hand. A collection locked by a
/// deposit (saved on this phone or known from the server) is refused here
/// without asking the server. The row stays in the history as voided; its
/// receipt number stays used.
class CashActionsService {
  CashActionsService(this._ref);
  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);

  /// Null when done, otherwise why not.
  Future<CashActionError?> withdraw(String collectionId, {required String customerId, required int amountPoisha, String? reason}) async {
    if (await _locked(collectionId)) return CashActionError.covered;
    try {
      await _ref.read(fieldApiProvider).withdrawCollection(collectionId, reason: reason);
    } on ApiException catch (e) {
      return cashActionErrorOf(e);
    }
    await (_db.update(_db.collections)..where((t) => t.serverId.equals(collectionId))).write(CollectionsCompanion(status: const Value('voided'), voidedKind: const Value('withdrawn'), voidedReason: Value(reason)));
    await _movePending(customerId, -amountPoisha);
    return null;
  }

  Future<CashActionError?> edit(String collectionId, {required String customerId, required int oldAmountPoisha, int? amountPoisha, String? note, String? payerName}) async {
    if (await _locked(collectionId)) return CashActionError.covered;
    try {
      await _ref.read(fieldApiProvider).editCollection(collectionId, amountPoisha: amountPoisha, note: note, payerName: payerName);
    } on ApiException catch (e) {
      return cashActionErrorOf(e);
    }
    final before = await (_db.select(_db.collections)..where((t) => t.serverId.equals(collectionId))).getSingleOrNull();
    await (_db.update(_db.collections)..where((t) => t.serverId.equals(collectionId))).write(CollectionsCompanion(
      previousAmountPoisha: amountPoisha == null ? const Value.absent() : Value(before?.previousAmountPoisha ?? oldAmountPoisha),
      amountPoisha: amountPoisha == null ? const Value.absent() : Value(amountPoisha),
      note: note == null ? const Value.absent() : Value(note),
      payerName: payerName == null ? const Value.absent() : Value(payerName),
    ));
    if (amountPoisha != null) await _movePending(customerId, amountPoisha - oldAmountPoisha);
    return null;
  }

  /// FR-M-059: handed in by a deposit (a deposit still waiting to be sent locks everything in hand).
  Future<bool> _locked(String collectionId) async {
    final row = await (_db.select(_db.collections)..where((t) => t.serverId.equals(collectionId))).getSingleOrNull();
    if (row?.depositId != null) return true;
    return _ref.read(outboxReaderProvider).hasUnsentOf('deposit');
  }

  /// The phone's own estimate of money waiting for the ERP (never shown as official).
  Future<void> _movePending(String customerId, int delta) async {
    final row = await (_db.select(_db.customers)..where((t) => t.serverId.equals(customerId))).getSingleOrNull();
    if (row == null) return;
    final next = row.pendingFieldPoisha + delta;
    await (_db.update(_db.customers)..where((t) => t.serverId.equals(customerId))).write(CustomersCompanion(pendingFieldPoisha: Value(next < 0 ? 0 : next)));
  }
}

final cashActionsServiceProvider = Provider<CashActionsService>(CashActionsService.new);
