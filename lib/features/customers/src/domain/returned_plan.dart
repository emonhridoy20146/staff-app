import 'dart:convert';

import '../../../../core/db/app_database.dart';
import 'customer.dart';

/// One ERP payment posted against a returned invoice (`Plan.payments`, contract 1.53.0). Shown, never counted.
typedef ReturnedPayment = ({String? id, String date, int amountPoisha, String? receiptNo, String? method, String? methodLabel, bool reversed});

/// An invoice returned in the ERP (FR-CUS-024, FR-M-085, ADR-M46): `CustomerDetail.returnedPlans`, kept in the
/// `returned_plans` table. It is never collectable and in no total, count, filter or KPI; the customer page
/// shows it in its own "Returned invoices" section with its payments.
class ReturnedPlan {
  ReturnedPlan(this.row);
  final ReturnedPlanRow row;

  String get erpPlanId => row.erpPlanId;
  String? get invoiceNo => (row.invoiceNo?.trim().isEmpty ?? true) ? null : row.invoiceNo!.trim();
  String get kind => row.kind;
  List<PlanItem> get items => decodePlanItems(row.itemsJson);

  /// Never: a returned invoice takes no money (contract `collectable: false`).
  bool get collectable => false;

  late final List<ReturnedPayment> payments = decodeReturnedPayments(row.paymentsJson);
}

/// Reads `returned_plans.payments_json`, newest first; empty when the ERP sent none or the text is not a list.
List<ReturnedPayment> decodeReturnedPayments(String? json) {
  if (json == null || json.isEmpty) return const [];
  final Object? raw;
  try {
    raw = jsonDecode(json);
  } on FormatException {
    return const [];
  }
  if (raw is! List) return const [];
  final out = <ReturnedPayment>[
    for (final x in raw)
      if (x is Map && x['date'] is String)
        (
          id: x['id'] as String?,
          date: x['date'] as String,
          amountPoisha: (x['amountPoisha'] as num?)?.toInt() ?? 0,
          receiptNo: x['receiptNo'] as String?,
          method: x['method'] as String?,
          methodLabel: x['methodLabel'] as String?,
          reversed: x['reversed'] == true,
        ),
  ];
  out.sort((a, b) => b.date.compareTo(a.date));
  return out;
}
