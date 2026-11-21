import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_models.dart';
import '../../../core/api/field_api.dart';
import '../../../core/providers.dart';

/// One collection whose cash is still in hand (contract 1.27.0, FR-M-049).
class CashInHandItem {
  const CashInHandItem({required this.collectionId, required this.receiptNo, required this.recordedAt, required this.customerId, required this.customerName, required this.customerCode, required this.erpPlanId, required this.amountPoisha, required this.inHandPoisha});
  factory CashInHandItem.fromJson(Json j) {
    final c = (j['customer'] as Json?) ?? const {};
    final amount = (j['amountPoisha'] as num?)?.toInt() ?? 0;
    return CashInHandItem(
      collectionId: (j['collectionId'] as String?) ?? '',
      receiptNo: (j['receiptNo'] as String?) ?? '',
      recordedAt: DateTime.tryParse((j['recordedAt'] as String?) ?? '')?.toUtc(),
      customerId: c['id'] as String?,
      customerName: I18nText.fromJson(c['name'] ?? ''),
      customerCode: (c['code'] as String?) ?? '',
      erpPlanId: (j['erpPlanId'] as String?) ?? '',
      amountPoisha: amount,
      inHandPoisha: (j['inHandPoisha'] as num?)?.toInt() ?? amount,
    );
  }
  final String collectionId;
  final String receiptNo;
  final DateTime? recordedAt;
  final String? customerId;
  final I18nText customerName;
  final String customerCode;

  /// The invoice the money was collected for.
  final String erpPlanId;

  /// The whole collection, and the part of it not yet covered by a deposit.
  final int amountPoisha;
  final int inHandPoisha;

  /// A deposit covered part of this collection.
  bool get partly => inHandPoisha < amountPoisha;
  String nameOf(String lang) {
    final n = lang == 'en' && (customerName.en?.isNotEmpty ?? false) ? customerName.en! : customerName.bn;
    return n.isNotEmpty ? n : customerCode;
  }
}

/// Where my cash on hand came from: deposits pay off the oldest collections
/// first, the rest is listed newest first. As the server counts it, so
/// collections still waiting on this phone are not in it.
class CashInHand {
  const CashInHand({required this.onHandPoisha, required this.pendingDepositsPoisha, required this.count, required this.items});
  factory CashInHand.fromJson(Json j) => CashInHand(
        onHandPoisha: (j['onHandPoisha'] as num?)?.toInt() ?? 0,
        pendingDepositsPoisha: (j['pendingDepositsPoisha'] as num?)?.toInt() ?? 0,
        count: (j['count'] as num?)?.toInt() ?? 0,
        items: [for (final i in (j['items'] as List?) ?? const []) CashInHandItem.fromJson(i as Json)],
      );
  final int onHandPoisha;
  final int pendingDepositsPoisha;

  /// Collections with cash still in hand; may be more than [items] holds.
  final int count;
  final List<CashInHandItem> items;
  int get notListed => count > items.length ? count - items.length : 0;
}

enum CashInHandError { offline, failed }

/// Read online (ADR-M08 exception: a server-computed figure, like the
/// reports). The screen asks this use case, never the API itself.
class CashInHandService {
  CashInHandService(this._ref);
  final Ref _ref;

  /// The answer, or why there is none.
  Future<(CashInHand?, CashInHandError?)> load() async {
    try {
      return (CashInHand.fromJson(await _ref.read(fieldApiProvider).myCashInHand()), null);
    } on ApiException catch (e) {
      return (null, e.isNetwork ? CashInHandError.offline : CashInHandError.failed);
    }
  }
}

final cashInHandServiceProvider = Provider<CashInHandService>(CashInHandService.new);
