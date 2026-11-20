import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/providers.dart';
import '../../../core/time/clock.dart';
import '../../../l10n/app_localizations.dart';
import 'visits.dart' show outcomeIcon, outcomeLabel;

/// The user's own visits of one business day, for Today's Work (FR-M-041).
/// A visit recorded by someone else carries that person's name and is left out.
Stream<List<WorkLogEntry>> watchVisitWorkLog(BuildContext context, WidgetRef ref, String businessDate) {
  final l = AppLocalizations.of(context);
  final db = ref.read(databaseProvider);
  final from = businessDayStartUtc(businessDate);
  final to = from.add(const Duration(days: 1));
  return (db.select(db.visits)..where((t) => t.checkInAt.isBiggerOrEqualValue(from) & t.checkInAt.isSmallerThanValue(to) & t.userName.isNull())).watch().map((rows) => [
        for (final v in rows)
          WorkLogEntry(at: v.checkInAt, kind: WorkKind.visit, icon: outcomeIcon(v.outcome), title: l.timelineVisit(outcomeLabel(l, v.outcome)), subtitle: v.note, customerId: v.customerId),
      ]);
}
