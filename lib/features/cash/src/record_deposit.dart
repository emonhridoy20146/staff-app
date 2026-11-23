import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/location/location_engine.dart';
import '../../../core/media/media.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/sync/outbox.dart';
import '../../collections/collections.dart';
import 'deposit_rules.dart';

/// What saving a deposit came to.
enum DepositSaveResult { saved, changed, nothing, slipRequired }

/// The media kind of a bank deposit slip (contract media kinds).
const depositSlipKind = 'deposit_slip';

/// Records "deposit everything in hand" offline-first (FR-M-059, contract 1.35.0).
///
/// In one transaction: the deposit row (`submitted`), the lock on every collection of mine still
/// in hand (its `depositId` = this deposit's clientId, so nothing can be changed or deleted from
/// this moment, offline too) and the outbox mutation. The clientId is a UUIDv7 made once here and
/// is the server's idempotency key. When the server refuses the deposit, [DepositPushHandler]
/// takes the lock off again; nothing is ever deleted.
///
/// A bank deposit needs a camera photo of the slip (field-api `SLIP_REQUIRED`): the photo goes to the
/// media queue (kind `deposit_slip`, owner `deposit`/clientId, `deposits.slip_media_client_id`) in the same transaction, and the
/// deposit mutation is saved `held`. When the photo is confirmed on the server, [linkDepositSlip]
/// releases it with `slipMediaId`; a bank deposit is never sent without it.
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
  /// [slipPhoto] (raw camera bytes) is required when [destination] is `bank` and ignored otherwise.
  Future<DepositSaveResult> call({required DepositPlan shown, required String destination, String? reference, Uint8List? slipPhoto}) async {
    final needsSlip = depositNeedsSlip(destination);
    if (needsSlip && slipPhoto == null) return DepositSaveResult.slipRequired;
    final clock = _ref.read(clockProvider);
    final id = const Uuid().v7();
    final at = clock.nowUtc();
    final fix = await _ref.read(locationEngineProvider).currentFix(timeout: const Duration(seconds: 8));
    final slip = needsSlip ? await processPhoto(slipPhoto!, watermark: await _watermark(at, fix)) : null;
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
      final slipId = slip == null
          ? null
          : await _ref.read(mediaServiceProvider).enqueue(photo: slip, kind: depositSlipKind, ownerEntity: 'deposit', ownerClientId: id, fix: fix);
      await _db.into(_db.deposits).insert(DepositsCompanion.insert(
            clientId: id,
            amountPoisha: p.cashPoisha,
            destination: destination,
            reference: Value(reference),
            slipMediaClientId: Value(slipId),
            depositedAt: at,
            status: const Value('submitted'),
            collectionCount: Value(p.collectionCount),
            nonCashPoisha: Value(p.nonCashPoisha),
            nonCashCount: Value(p.nonCashCount),
          ));
      await (_db.update(_db.collections)..where((t) => t.depositId.isNull() & t.status.isIn(inHandStatuses)))
          .write(CollectionsCompanion(depositId: Value(id), depositedAt: Value(at)));
      // A bank deposit waits (held) for its slip; see [linkDepositSlip].
      await _ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'deposit', held: slip != null, payload: {
        'clientId': id,
        'amountPoisha': p.cashPoisha,
        'destination': destination,
        'reference': ?reference,
        'depositedAt': at.toIso8601String(),
        'geo': ?fix?.toJson(),
      });
    });
    if (result == DepositSaveResult.saved) {
      if (slip != null) unawaited(_ref.read(mediaServiceProvider).uploadPending().catchError((Object _) {}));
      unawaited(_ref.read(syncEngineProvider).kick(reason: 'money'));
    }
    return result;
  }

  /// Time, staff code and place burnt into the slip photo, as on visit photos.
  Future<String> _watermark(DateTime at, GeoFix? fix) async {
    final user = await _ref.read(secureStoreProvider).read('session_user');
    final code = user == null ? '' : ((jsonDecode(user) as Map)['employeeCode'] ?? '').toString();
    final f = _ref.read(fmtProvider);
    final wm = '${f.dateTime(at).replaceAll(RegExp('[^\\x00-\\x7F]'), '')} $code${fix == null ? '' : ' ${fix.lat.toStringAsFixed(5)},${fix.lng.toStringAsFixed(5)}'}';
    return wm.trim();
  }
}

/// Media hook (owner `deposit`): the slip is on the server → the held bank deposit is sent with
/// `slipMediaId`. Called again for the same deposit it does nothing (already released).
Future<void> linkDepositSlip(OutboxWriter outbox, AppDatabase db, String depositClientId, List<String> mediaIds) async {
  if (mediaIds.isEmpty) return;
  await outbox.release(depositClientId, {'slipMediaId': mediaIds.first});
}

final recordDepositProvider = Provider<RecordDeposit>(RecordDeposit.new);
