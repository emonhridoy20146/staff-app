import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../customers/customers.dart';
import 'application/record_collection.dart';
import 'data/collection_repository.dart';

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) => CollectionRepository(ref.watch(databaseProvider), ref.watch(clockProvider)));

final receiptAllocatorProvider = Provider<ReceiptAllocator>((ref) => ReceiptAllocator(ref.watch(databaseProvider)));

final recordCollectionProvider = Provider<RecordCollection>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return RecordCollection(
    db: ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    outbox: ref.watch(outboxWriterProvider),
    receipts: ref.watch(receiptAllocatorProvider),
    customers: ref.watch(customerRepositoryProvider),
    kickSync: () => unawaited(engine.kick(reason: 'money')),
    fallbackReceiptPrefix: 'DEV-${ref.watch(deviceIdentityProvider).deviceId.substring(0, 6).toUpperCase()}',
  );
});

final todayTotalsProvider = StreamProvider<DayTotals>((ref) => ref.watch(collectionRepositoryProvider).watchTodayTotals());
final todayCollectionsProvider = StreamProvider<List<CollectionRow>>((ref) => ref.watch(collectionRepositoryProvider).watchToday());
final collectionProblemsProvider = StreamProvider<List<CollectionRow>>((ref) => ref.watch(collectionRepositoryProvider).watchProblems());

final collectionProvider = StreamProvider.family<CollectionRow?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.collections)..where((t) => t.clientId.equals(id))).watchSingleOrNull();
});

/// Keeps receipt blocks topped up whenever a sync succeeds (online).
final receiptTopUpProvider = Provider<void>((ref) {
  final sub = ref.watch(syncEngineProvider).status.listen((s) async {
    if (s.running || s.lastErrorCode != null || s.lastSuccessAt == null) return;
    try {
      await ref.read(receiptAllocatorProvider).topUp(
            ref.read(fieldApiProvider),
            deviceId: ref.read(deviceIdentityProvider).deviceId,
            businessDate: ref.read(clockProvider).businessDate(),
          );
    } catch (_) {}
  });
  ref.onDispose(sub.cancel);
});

/// Online receipt numbers left for today (Today banner when low).
final receiptsRemainingProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final today = ref.watch(clockProvider).businessDate();
  final alloc = ref.watch(receiptAllocatorProvider);
  return (db.select(db.receiptBlocks)..where((t) => t.businessDate.equals(today))).watch().asyncMap((_) => alloc.remaining(today));
});
