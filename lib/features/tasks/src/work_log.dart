import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/providers.dart';
import '../../../core/time/clock.dart';
import '../../../l10n/app_localizations.dart';

/// Tasks the user reported as done on one business day, for Today's Work (FR-M-041).
Stream<List<WorkLogEntry>> watchTaskWorkLog(BuildContext context, WidgetRef ref, String businessDate) {
  final l = AppLocalizations.of(context);
  final db = ref.read(databaseProvider);
  final from = businessDayStartUtc(businessDate);
  final to = from.add(const Duration(days: 1));
  return (db.select(db.tasks)..where((t) => t.resolveRequestedAt.isBiggerOrEqualValue(from) & t.resolveRequestedAt.isSmallerThanValue(to))).watch().map((rows) => [
        for (final t in rows)
          WorkLogEntry(at: t.resolveRequestedAt!, kind: WorkKind.task, icon: Icons.task_alt_rounded, title: l.workTaskDone(t.title), subtitle: t.resolveNote, route: '/tasks/${t.serverId}'),
      ]);
}
