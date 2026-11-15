import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/api/api_models.dart';
import '../../../../core/api/field_api.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/sync/sync_handlers.dart';
import '../../../../core/time/clock.dart';
import '../domain/collection_rules.dart';

class ReceiptExhausted implements Exception {}

/// Receipt numbers from server-allocated blocks; transactional increment.
class ReceiptAllocator {
  ReceiptAllocator(this._db);
  final AppDatabase _db;

  /// Next number for [businessDate]. Must run inside the caller's
  /// transaction so the number and the collection are saved together.
  /// Falls back to the device's offline series when no block is left.
  Future<({String receiptNo, bool offline})> next(String businessDate, {required String fallbackPrefix}) async {
    final blocks = await (_db.select(_db.receiptBlocks)
          ..where((t) => t.businessDate.equals(businessDate) & t.offline.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.fromSeq)]))
        .get();
    for (final b in blocks) {
      if (b.lastUsed < b.toSeq) {
        final seq = b.lastUsed < b.fromSeq ? b.fromSeq : b.lastUsed + 1;
        await (_db.update(_db.receiptBlocks)..where((t) => t.id.equals(b.id))).write(ReceiptBlocksCompanion(lastUsed: Value(seq)));
        return (receiptNo: formatReceiptNo(b.prefix, businessDate, seq), offline: false);
      }
    }
    // Offline fallback series, reserved per device and flagged for review.
    final prefix = blocks.isNotEmpty ? blocks.last.prefix : fallbackPrefix;
    var off = await (_db.select(_db.receiptBlocks)..where((t) => t.businessDate.equals(businessDate) & t.offline.equals(true))).getSingleOrNull();
    if (off == null) {
      final id = await _db.into(_db.receiptBlocks).insert(
            ReceiptBlocksCompanion.insert(prefix: prefix, businessDate: businessDate, fromSeq: 1, toSeq: 999, lastUsed: 0, offline: const Value(true)),
          );
      off = await (_db.select(_db.receiptBlocks)..where((t) => t.id.equals(id))).getSingle();
    }
    if (off.lastUsed >= off.toSeq) throw ReceiptExhausted();
    final seq = off.lastUsed + 1;
    await (_db.update(_db.receiptBlocks)..where((t) => t.id.equals(off!.id))).write(ReceiptBlocksCompanion(lastUsed: Value(seq)));
    return (receiptNo: formatReceiptNo(prefix, businessDate, seq, offline: true), offline: true);
  }

  Future<int> remaining(String businessDate) async {
    final blocks = await (_db.select(_db.receiptBlocks)..where((t) => t.businessDate.equals(businessDate) & t.offline.equals(false))).get();
    return blocks.fold<int>(0, (s, b) => s + (b.toSeq - (b.lastUsed < b.fromSeq ? b.fromSeq - 1 : b.lastUsed)));
  }

  /// Requests a new block when below the low-water mark (online only).
  Future<void> topUp(FieldApi api, {required String deviceId, required String businessDate}) async {
    if (await remaining(businessDate) >= receiptLowWater) return;
    final b = await api.allocateReceiptBlock(deviceId: deviceId, businessDate: businessDate);
    await _db.into(_db.receiptBlocks).insert(
          ReceiptBlocksCompanion.insert(prefix: b.prefix, businessDate: b.businessDate, fromSeq: b.from, toSeq: b.to, lastUsed: b.from - 1),
        );
  }
}

/// Push results for `collection` mutations.
class CollectionPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'collection'};

  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) async {
    final c = switch (r.result) {
      'applied' || 'replayed' => CollectionsCompanion(
          serverId: Value(r.entityId),
          status: Value(r.status ?? 'received'),
          syncState: const Value('synced'),
        ),
      'conflict' => CollectionsCompanion(
          serverId: Value(r.entityId),
          status: const Value('conflict'),
          conflictCode: Value(r.conflictCode),
          conflictMessage: Value(r.conflictMessage == null ? null : jsonEncode(r.conflictMessage!.toJson())),
          syncState: const Value('synced'),
        ),
      _ => CollectionsCompanion(
          status: const Value('rejected'),
          conflictCode: Value(r.error?.code),
          conflictMessage: Value(r.error == null ? null : jsonEncode({'bn': r.error!.detail ?? r.error!.title, 'en': r.error!.detail ?? r.error!.title})),
          syncState: const Value('failed'),
        ),
    };
    await (db.update(db.collections)..where((t) => t.clientId.equals(m.mutationId))).write(c);
  }
}

/// Pull handler: server-side status changes (posted, conflict, resolved,
/// voided) for own collections. Payload = contract `Collection`.
class CollectionPullHandler implements PullHandler {
  @override
  String get entity => 'collection';

  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final clientId = d['clientId'] as String?;
    if (clientId == null) return;
    final conflict = d['conflict'] as Json?;
    final resolution = d['resolution'] as Json?;
    await (db.update(db.collections)..where((t) => t.clientId.equals(clientId))).write(
      CollectionsCompanion(
        serverId: Value(id),
        status: Value((d['status'] as String?) ?? 'received'),
        erpReceiptNo: Value(d['erpReceiptNo'] as String?),
        conflictCode: Value(conflict?['code'] as String?),
        conflictMessage: Value(conflict == null ? null : jsonEncode(conflict['message'])),
        resolutionText: Value(resolution == null ? null : '${resolution['action']}: ${resolution['reason'] ?? ''}'),
        flagsJson: Value(jsonEncode(d['flags'] ?? const [])),
        syncState: const Value('synced'),
      ),
    );
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) async {
    // Own collections are never deleted by pull; kept 60 days locally.
  }
}

class DayTotals {
  const DayTotals({this.cash = 0, this.mobile = 0, this.count = 0});
  final int cash;
  final int mobile;
  final int count;
  int get total => cash + mobile;
}

class CollectionRepository {
  CollectionRepository(this._db, this._clock);
  final AppDatabase _db;
  final Clock _clock;

  Stream<List<CollectionRow>> watchForCustomer(String customerId) => (_db.select(_db.collections)
        ..where((t) => t.customerId.equals(customerId))
        ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
      .watch();

  Stream<List<CollectionRow>> watchToday() => (_db.select(_db.collections)
        ..where((t) => t.businessDate.equals(_clock.businessDate()) & t.status.isNotIn(['voided', 'resolved_voided', 'rejected']))
        ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
      .watch();

  Stream<DayTotals> watchTodayTotals() => watchToday().map((rows) {
        var cash = 0, mobile = 0;
        for (final r in rows) {
          if (r.method == 'cash') {
            cash += r.amountPoisha;
          } else {
            mobile += r.amountPoisha;
          }
        }
        return DayTotals(cash: cash, mobile: mobile, count: rows.length);
      });

  /// Local unsynced cash (not yet acknowledged by the server).
  Stream<int> watchUnsyncedCash() {
    final s = _db.collections.amountPoisha.sum();
    final q = _db.selectOnly(_db.collections)
      ..addColumns([s])
      ..where(_db.collections.method.equals('cash') & _db.collections.syncState.isIn(['queued', 'sending']));
    return q.map((r) => r.read(s) ?? 0).watchSingle();
  }

  Stream<List<CollectionRow>> watchProblems() => (_db.select(_db.collections)
        ..where((t) => t.status.isIn(['conflict', 'rejected', 'posting_failed']))
        ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
      .watch();

  Future<CollectionRow?> get(String clientId) => (_db.select(_db.collections)..where((t) => t.clientId.equals(clientId))).getSingleOrNull();
}
