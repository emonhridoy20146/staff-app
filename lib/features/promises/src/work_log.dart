import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/providers.dart';
import '../../../core/time/clock.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/settings/ui_prefs.dart';

/// Promises taken on one business day, for Today's Work (FR-M-041).
Stream<List<WorkLogEntry>> watchPromiseWorkLog(BuildContext context, WidgetRef ref, String businessDate) {
  final l = AppLocalizations.of(context);
  final db = ref.read(databaseProvider);
  final from = businessDayStartUtc(businessDate);
  final to = from.add(const Duration(days: 1));
  return (db.select(db.promises)..where((t) => t.createdAt.isBiggerOrEqualValue(from) & t.createdAt.isSmallerThanValue(to))).watch().map((rows) {
    final f = ref.read(fmtProvider);
    return [
      for (final p in rows)
        WorkLogEntry(at: p.createdAt, kind: WorkKind.promise, icon: Icons.handshake_rounded, title: l.timelinePromise(f.money(p.promisedAmountPoisha), f.date(p.promisedDate)), subtitle: p.note, customerId: p.customerId),
    ];
  });
}
