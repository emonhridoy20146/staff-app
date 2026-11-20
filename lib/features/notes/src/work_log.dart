import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/providers.dart';
import '../../../core/time/clock.dart';
import '../../auth/auth.dart';

/// Notes the user wrote on one business day, for Today's Work (FR-M-041).
/// A note by someone else (it carries that person's id) is left out.
Stream<List<WorkLogEntry>> watchNoteWorkLog(BuildContext context, WidgetRef ref, String businessDate) {
  final db = ref.read(databaseProvider);
  final me = ref.read(sessionProvider).user?.id;
  final from = businessDayStartUtc(businessDate);
  final to = from.add(const Duration(days: 1));
  return (db.select(db.notes)..where((t) => t.createdAt.isBiggerOrEqualValue(from) & t.createdAt.isSmallerThanValue(to))).watch().map((rows) => [
        for (final n in rows)
          if (n.authorId == null || n.authorId == me)
            WorkLogEntry(at: n.createdAt, kind: WorkKind.note, icon: Icons.sticky_note_2_rounded, title: n.body, customerId: n.customerId),
      ]);
}
