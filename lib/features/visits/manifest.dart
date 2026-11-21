import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/db/colleague_activity.dart';
import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/providers.dart' show databaseProvider;
import '../../core/settings/ui_prefs.dart';
import '../auth/auth.dart' show sessionProvider;
import '../cowork/cowork.dart';
import '../../l10n/app_localizations.dart';
import 'src/visits.dart';
import 'src/work_log.dart';

/// Visits: check-in with camera photo, outcome, GPS distance to pin
/// (FR-VIS-001…005, FR-MED-001 client side, FR-M-009).
final visitsManifest = FeatureManifest(
  name: 'visits',
  flag: 'module.visits',
  permissions: const [Perm.visitRecord, Perm.visitView],
  routes: [GoRoute(path: '/visit/:customerId', builder: (_, s) => VisitScreen(customerId: s.pathParameters['customerId']!))],
  pullHandlers: [VisitPullHandler()],
  pushHandlers: [VisitPushHandler()],
  customerActions: [
    CustomerActionDef(
      id: 'visit',
      order: 10,
      permission: Perm.visitRecord,
      icon: Icons.where_to_vote_rounded,
      label: (c) => AppLocalizations.of(c).actionVisit,
      onTap: (c, ref, x) => c.push('/visit/${x.customerId}'),
    ),
  ],
  workLogSources: const [WorkLogSourceDef(id: 'visits', watch: watchVisitWorkLog)],
  timelineSources: [
    TimelineSourceDef(
      id: 'visits',
      watch: (context, ref, id) {
        final l = AppLocalizations.of(context);
        final lang = Localizations.localeOf(context).languageCode;
        return combineLatest2(watchVisitsFor(ref, id), watchColleagueActivities(ref.read(databaseProvider), id, 'visit'), (rows, others) {
          final f = ref.read(fmtProvider);
          final names = ref.read(coworkNamesProvider);
          final me = ref.read(myUserIdProvider);
          final myName = ref.read(sessionProvider).user?.name.of(lang);
          return [
            for (final v in rows)
              TimelineEntry(
                at: v.checkInAt,
                icon: outcomeIcon(v.outcome),
                title: l.timelineVisit(outcomeLabel(l, v.outcome)),
                subtitle: [
                  f.dateTime(v.checkInAt),
                  if (v.userName != null) v.userName! else if (myName != null) l.timelineVisitBy(myName),
                  if (v.userId != null && v.userId != me && names[v.userId] != null) l.timelineRecordedBy(names[v.userId]!),
                  if (v.coWorkSessionId != null) ?coworkWithText(l, v, names, me),
                  if (v.distanceToPinM != null) f.distance(v.distanceToPinM!),
                ].join(' · '),
                statusChip: v.coWorkSessionId != null ? const CoworkChip() : null,
              ),
            for (final o in others)
              TimelineEntry(
                at: o.at,
                icon: outcomeIcon(o.outcome ?? 'other'),
                title: l.timelineVisit(outcomeLabel(l, o.outcome ?? 'other')),
                subtitle: [f.dateTime(o.at), l.timelineVisitBy(o.staffName)].join(' · '),
              ),
          ];
        });
      },
    ),
  ],
);
