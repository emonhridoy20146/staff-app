import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/settings/ui_prefs.dart';

/// The collections recorded on this phone on one business day, for Today's
/// Work (FR-M-041). Voided and refused ones are left out. Money that is not
/// in the ERP yet is marked pending and never shown as posted.
Stream<List<WorkLogEntry>> watchCollectionWorkLog(BuildContext context, WidgetRef ref, String businessDate) {
  final l = AppLocalizations.of(context);
  final db = ref.read(databaseProvider);
  return (db.select(db.collections)..where((t) => t.businessDate.equals(businessDate) & t.status.isNotIn(['voided', 'resolved_voided', 'rejected']))).watch().map((rows) {
    final f = ref.read(fmtProvider);
    return [
      for (final r in rows)
        WorkLogEntry(
          at: r.recordedAt,
          kind: WorkKind.collection,
          icon: Icons.payments_rounded,
          title: l.timelineCollection(f.money(r.amountPoisha)),
          subtitle: r.receiptNo,
          customerId: r.customerId,
          amountPoisha: r.amountPoisha,
          pending: r.status != 'posted' && r.status != 'resolved_posted',
        ),
    ];
  });
}
