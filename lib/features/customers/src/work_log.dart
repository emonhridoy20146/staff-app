import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/providers.dart';
import '../../../core/time/clock.dart';
import '../../../l10n/app_localizations.dart';
import 'contact_attempts.dart' show callOutcomeIcon, callOutcomeLabel;

/// Map pins the user sent and calls the user logged on one business day, for
/// Today's Work (FR-M-041). A pin proposal has no time column; its client id
/// is a UUIDv7, which carries the moment it was made on this phone.
Stream<List<WorkLogEntry>> watchPinWorkLog(BuildContext context, WidgetRef ref, String businessDate) {
  final l = AppLocalizations.of(context);
  final db = ref.read(databaseProvider);
  final from = businessDayStartUtc(businessDate);
  final to = from.add(const Duration(days: 1));
  return db.select(db.locationProposals).watch().map((rows) => [
        for (final p in rows)
          if (uuidV7Time(p.clientId) case final at? when !at.isBefore(from) && at.isBefore(to))
            WorkLogEntry(at: at, kind: WorkKind.pin, icon: Icons.add_location_alt_rounded, title: l.workPin, subtitle: p.note, customerId: p.customerId, pending: p.status == 'pending'),
      ]);
}

Stream<List<WorkLogEntry>> watchCallWorkLog(BuildContext context, WidgetRef ref, String businessDate) {
  final l = AppLocalizations.of(context);
  final db = ref.read(databaseProvider);
  final from = businessDayStartUtc(businessDate);
  final to = from.add(const Duration(days: 1));
  return (db.select(db.contactAttempts)..where((t) => t.at.isBiggerOrEqualValue(from) & t.at.isSmallerThanValue(to))).watch().map((rows) => [
        for (final a in rows)
          WorkLogEntry(
            at: a.at,
            kind: WorkKind.call,
            icon: callOutcomeIcon(a.outcome),
            title: a.target == 'guarantor' ? l.timelineGuarantorCall(callOutcomeLabel(l, a.outcome ?? '')) : l.timelineCall(callOutcomeLabel(l, a.outcome ?? '')),
            customerId: a.customerId,
          ),
      ]);
}
