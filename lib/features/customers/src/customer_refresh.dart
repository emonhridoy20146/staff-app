import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/field_api.dart';
import '../../../core/providers.dart';

/// How a customer refresh ended (FR-M-063).
enum CustomerRefreshOutcome {
  /// Fresh ERP figures, invoices and payments are on the phone.
  ok,

  /// No internet: nothing changed, the saved data stays on screen.
  offline,

  /// The ERP is slow or busy (503), or too many refreshes (429).
  busy,

  /// The server no longer has this customer for me (404).
  notFound,

  /// No permission (403).
  denied,

  /// Anything else; [CustomerRefreshResult.code] says what.
  failed,
}

class CustomerRefreshResult {
  const CustomerRefreshResult(this.outcome, [this.code]);
  final CustomerRefreshOutcome outcome;
  final String? code;
}

/// Refreshes one customer from the server on request (reload button and pull
/// down on the customer page, owner request 2026-11-22).
///
/// `POST /customers/{id}/refresh` asks field-api to re-read the ERP and answers
/// the full `CustomerDetail`; it is stored through the same `customer` pull
/// handler as sync, so pending field amounts and numbers typed on this phone
/// are kept and nothing unsynced is touched. Online only (ADR-M27, an ADR-M08
/// exception); a sync kick follows so queued work goes out and the rest
/// (notes, visits, promises) comes in.
class CustomerRefreshService {
  CustomerRefreshService(this._ref);
  final Ref _ref;

  Future<CustomerRefreshResult> refresh(String customerId) async {
    final sync = _ref.read(syncEngineProvider);
    try {
      final detail = await _ref.read(fieldApiProvider).refreshCustomer(customerId);
      final handler = _ref.read(syncHandlerRegistryProvider).pullFor('customer');
      if (handler != null) {
        final db = _ref.read(databaseProvider);
        await db.transaction(() => handler.upsert(db, customerId, detail));
      }
    } on ApiException catch (e) {
      final code = e.statusCode;
      if (code == null && e.isNetwork) {
        // Still try: the server may be reachable for sync even if this call was cut.
        unawaited(sync.kick(reason: 'customer_refresh'));
        return const CustomerRefreshResult(CustomerRefreshOutcome.offline);
      }
      unawaited(sync.syncNow());
      return switch (code) {
        503 || 429 => CustomerRefreshResult(CustomerRefreshOutcome.busy, e.code),
        404 => CustomerRefreshResult(CustomerRefreshOutcome.notFound, e.code),
        403 => CustomerRefreshResult(CustomerRefreshOutcome.denied, e.code),
        _ => CustomerRefreshResult(CustomerRefreshOutcome.failed, e.code),
      };
    }
    unawaited(sync.syncNow());
    return const CustomerRefreshResult(CustomerRefreshOutcome.ok);
  }
}

final customerRefreshServiceProvider = Provider<CustomerRefreshService>(CustomerRefreshService.new);
