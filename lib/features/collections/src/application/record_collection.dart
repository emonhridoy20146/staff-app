import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/location/location_engine.dart';
import '../../../../core/sync/outbox.dart';
import '../../../../core/time/clock.dart';
import '../../../customers/customers.dart';
import '../data/collection_repository.dart';
import '../domain/collection_rules.dart';

class CollectionInput {
  const CollectionInput({
    required this.customerId,
    required this.customerName,
    required this.customerCode,
    required this.amountPoisha,
    required this.method,
    this.erpPlanId,
    this.txnRef,
    this.physicalReceiptNo,
    this.payerName,
    this.note,
    this.visitClientId,
    this.outstandingPoisha,
  });
  final String customerId;
  final String customerName;
  final String customerCode;
  final String? erpPlanId;
  final int amountPoisha;
  final PaymentMethod method;
  final String? txnRef;
  final String? physicalReceiptNo;
  final String? payerName;
  final String? note;
  final String? visitClientId;
  final int? outstandingPoisha;
}

class CollectionResult {
  const CollectionResult({required this.clientId, required this.receiptNo, required this.offlineReceipt, required this.fix});
  final String clientId;
  final String receiptNo;
  final bool offlineReceipt;
  final GeoFix? fix;
}

class InvalidCollection implements Exception {
  const InvalidCollection(this.reason);
  final CollectionValidation reason;
}

/// RecordCollection (04-architecture §5.1). The UUIDv7 is created ONCE here
/// and becomes clientId = mutationId = server idempotency key. Entity +
/// outbox + receipt counter are written in one transaction, then the sync
/// engine is kicked for an immediate attempt.
class RecordCollection {
  RecordCollection({
    required AppDatabase db,
    required Clock clock,
    required OutboxWriter outbox,
    required ReceiptAllocator receipts,
    required CustomerRepository customers,
    required void Function() kickSync,
    required String fallbackReceiptPrefix,
    Uuid uuid = const Uuid(),
  })  : _db = db,
        _clock = clock,
        _outbox = outbox,
        _receipts = receipts,
        _customers = customers,
        _kick = kickSync,
        _prefix = fallbackReceiptPrefix,
        _uuid = uuid;

  final AppDatabase _db;
  final Clock _clock;
  final OutboxWriter _outbox;
  final ReceiptAllocator _receipts;
  final CustomerRepository _customers;
  final void Function() _kick;
  final String _prefix;
  final Uuid _uuid;

  /// [fix] is obtained by the caller beforehand (review step shows it).
  Future<CollectionResult> call(CollectionInput input, {GeoFix? fix, String? noFixReason}) async {
    final v = validateCollection(amountPoisha: input.amountPoisha, method: input.method, txnRef: input.txnRef);
    if (v != CollectionValidation.ok) throw InvalidCollection(v);

    final clientId = _uuid.v7();
    final recordedAt = _clock.nowUtc();
    final deviceTime = _clock.deviceNowUtc();
    final businessDate = _clock.businessDate();
    final txn = input.method.needsTxnRef ? normalizeTxnRef(input.txnRef!) : null;
    final flags = <String>[
      if (fix == null) 'no_location',
      if (fix?.mock ?? false) 'mock_location',
      if (input.outstandingPoisha != null && input.amountPoisha > input.outstandingPoisha!) 'over_outstanding',
    ];

    late ({String receiptNo, bool offline}) receipt;
    await _db.transaction(() async {
      receipt = await _receipts.next(businessDate, fallbackPrefix: _prefix);
      if (receipt.offline) flags.add('offline_receipt');
      await _db.into(_db.collections).insert(CollectionsCompanion.insert(
            clientId: clientId,
            customerId: input.customerId,
            customerName: input.customerName,
            customerCode: input.customerCode,
            erpPlanId: Value(input.erpPlanId),
            amountPoisha: input.amountPoisha,
            method: input.method.wire,
            transactionRef: Value(txn),
            receiptNo: receipt.receiptNo,
            physicalReceiptNo: Value(input.physicalReceiptNo),
            payerName: Value(input.payerName),
            note: Value(input.note),
            recordedAt: recordedAt,
            deviceTime: deviceTime,
            businessDate: businessDate,
            lat: Value(fix?.lat),
            lng: Value(fix?.lng),
            accuracyM: Value(fix?.accuracyM),
            mock: Value(fix?.mock ?? false),
            visitClientId: Value(input.visitClientId),
            flagsJson: Value('[${flags.map((f) => '"$f"').join(',')}]'),
          ));
      await _outbox.enqueue(
        mutationId: clientId,
        entity: 'collection',
        dependsOn: [?input.visitClientId],
        payload: {
          'clientId': clientId,
          'customerId': input.customerId,
          'erpPlanId': ?input.erpPlanId,
          'amountPoisha': input.amountPoisha,
          'method': input.method.wire,
          'transactionRef': ?txn,
          'payerName': ?input.payerName,
          'receiptNo': receipt.receiptNo,
          'physicalReceiptNo': ?input.physicalReceiptNo,
          'recordedAt': recordedAt.toIso8601String(),
          'deviceTime': deviceTime.toIso8601String(),
          ...geoFields(fix, noFixReason),
          'visitClientId': ?input.visitClientId,
          'note': ?input.note,
        },
      );
      await _customers.applyLocalCollection(input.customerId, input.amountPoisha, recordedAt);
    });
    _kick();
    return CollectionResult(clientId: clientId, receiptNo: receipt.receiptNo, offlineReceipt: receipt.offline, fix: fix);
  }
}
