import 'package:drift/drift.dart' show OrderingTerm, ComparableExpr, BooleanExpressionOperators, SimpleSelectStatement;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/time/clock.dart';
import '../../../core/ui/money_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../visits/visits.dart';

/// What the branch's other staff did on one business day (FR-M-057): their
/// visits, promises, collections and pins, latest first, from the phone's own
/// copy (offline). The user's own work is never in here.
final teamActivityProvider = StreamProvider.family<List<ColleagueActivityRow>, String>((ref, date) => teamActivityOn(ref.watch(databaseProvider), date).watch());

/// The query behind [teamActivityProvider]: one Dhaka business day, latest first.
SimpleSelectStatement<$ColleagueActivitiesTable, ColleagueActivityRow> teamActivityOn(AppDatabase db, String date) {
  final start = businessDayStartUtc(date);
  final end = start.add(const Duration(days: 1));
  return db.select(db.colleagueActivities)
    ..where((t) => t.at.isBiggerOrEqualValue(start) & t.at.isSmallerThanValue(end))
    ..orderBy([(t) => OrderingTerm.desc(t.at)]);
}

/// One line of a colleague's work: the customer leads, then what they did and who did it.
class TeamActivityTile extends ConsumerWidget {
  const TeamActivityTile({super.key, required this.row, required this.customerName});
  final ColleagueActivityRow row;
  final String? customerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(fmtProvider);
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final sc = context.statusColors;

    final (IconData icon, StatusStyle style, String title, String by) = switch (row.kind) {
      'visit' => (outcomeIcon(row.outcome ?? 'other'), sem.info, l.timelineVisit(outcomeLabel(l, row.outcome ?? 'other')), l.timelineVisitBy(row.staffName)),
      'promise' => (Icons.handshake_rounded, sc.of(AppStatus.promised), l.timelinePromise(f.money(row.amountPoisha ?? 0), row.promisedDate == null ? '' : f.date(row.promisedDate!)), l.timelinePromiseBy(row.staffName)),
      'collection' => (Icons.payments_rounded, sc.of(AppStatus.paid), l.timelineCollection(f.money(row.amountPoisha ?? 0)), [l.timelineCollector(row.staffName), if (row.status == 'voided' || row.status == 'resolved_voided') (row.voidedKind == 'admin' ? l.statusVoidedByOffice : l.collectionDeletedTag)].join(' · ')),
      _ => (
        Icons.location_on_rounded,
        sem.success,
        switch (row.status) {
          'approved' => l.timelinePinSet,
          'rejected' => l.timelinePinRejected,
          _ => l.timelinePinPending,
        },
        l.timelinePinBy(row.staffName),
      ),
    };
    return ListTile(
      onTap: row.customerId.isEmpty ? null : () => context.push('/customers/${row.customerId}'),
      minTileHeight: Sizes.row3,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: style.bg, borderRadius: Radii.brMd),
        child: Icon(icon, size: 20, color: style.fg),
      ),
      title: Text(customerName ?? title, style: t.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text([if (customerName != null) title, by].join(' · '), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(f.time(row.at), style: t.labelMedium),
          if (row.kind == 'collection' && row.amountPoisha != null) MoneyText(row.amountPoisha!, style: t.titleSmall!),
        ],
      ),
    );
  }
}
