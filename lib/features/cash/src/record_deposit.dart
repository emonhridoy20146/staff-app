import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../collections/collections.dart';
import 'deposit_rules.dart';

/// What saving a deposit came to.
enum DepositSaveResult { saved, changed, nothing }

/// Records "deposit everything in hand" offline-first (FR-M-059, contract 1.35.0).
///
/// In one transaction: the deposit row (`submitted`), the lock on every collection of mine still
/// in hand (its `depositId` = this deposit's clientId, so nothing can be changed or deleted from
/// this moment, offline too) and the outbox mutation. The clientId is a UUIDv7 made once here and
/// is the server's idempotency key. When the server refuses the deposit, [DepositPushHandler]
/// takes the lock off again; nothing is ever deleted.
class RecordDeposit {
  RecordDeposit(this._ref);
  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);

  /// What a deposit would take right now.
  Future<DepositPlan> plan() async {
    final cash = await readCashOnHand(_db, _ref.read(serverCashProvider)?.onHandPoisha ?? 0);
    final rows = await _ref.read(collectionRepositoryProvider).inHand();
    return planDeposit(cashOnHandPoisha: cash, inHand: [for (final r in rows) (method: r.method, amountPoisha: r.amountPoisha)]);
  }

  /// Saves the deposit only if what is in hand is still [shown] (what the user confirmed).
  Future<DepositSaveResult> call({required DepositPlan shown, required String destination, String? reference}) async {
    final clock = _ref.read(clockProvider);
    final id = const Uuid().v7();
    final at = clock.nowUtc();
    final fix = await _ref.read(locationEngineProvider).currentFix(timeout: const Duration(seconds: 8));
    var result = DepositSaveResult.saved;
    await _db.transaction(() async {
      final p = await plan();
      if (p.isEmpty) {
        result = DepositSaveResult.nothing;
        return;
      }
      if (p != shown) {
        result = DepositSaveResult.changed;
        return;
      }
      await _db.into(_db.deposits).insert(DepositsCompanion.insert(
            clientId: id,
            amountPoisha: p.cashPoisha,
            destination: destination,
            reference: Value(reference),
            depositedAt: at,
            status: const Value('submitted'),
            collectionCount: Value(p.collectionCount),
            nonCashPoisha: Value(p.nonCashPoisha),
            nonCashCount: Value(p.nonCashCount),
          ));
      await (_db.update(_db.collections)..where((t) => t.depositId.isNull() & t.status.isIn(inHandStatuses)))
          .write(CollectionsCompanion(depositId: Value(id), depositedAt: Value(at)));
      await _ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'deposit', payload: {
        'clientId': id,
        'amountPoisha': p.cashPoisha,
        'destination': destination,
        'reference': ?reference,
        'depositedAt': at.toIso8601String(),
        'geo': ?fix?.toJson(),
      });
    });
    if (result == DepositSaveResult.saved) unawaited(_ref.read(syncEngineProvider).kick(reason: 'money'));
    return result;
  }
}

final recordDepositProvider = Provider<RecordDeposit>(RecordDeposit.new);
