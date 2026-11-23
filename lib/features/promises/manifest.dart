import 'package:material_ui/material_ui.dart';

import '../../core/db/app_database.dart' show PromiseRow;
import '../../core/db/colleague_activity.dart';
import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/providers.dart' show databaseProvider;
import '../../core/settings/ui_prefs.dart';
import '../auth/auth.dart' show sessionProvider;
import '../../l10n/app_localizations.dart';
import 'src/promises.dart';
import 'src/work_log.dart';

/// Promises to pay with a local 09:00 reminder (FR-PRM-001…004, ADR-M06).
final promisesManifest = FeatureManifest(
  name: 'promises',
  flag: 'module.promises',
  permissions: const [Perm.promiseCreate, Perm.promiseView],
  pullHandlers: [PromisePullHandler()],
  pushHandlers: [PromisePushHandler()],
  customerActions: [
    CustomerActionDef(
      id: 'promise',
      order: 20,
      permission: Perm.promiseCreate,
      icon: Icons.handshake_rounded,
      label: (c) => AppLocalizations.of(c).actionPromise,
      onTap: (c, ref, x) => showPromiseSheet(c, x.customerId),
    ),
  ],
  alertSources: [
    AlertSourceDef(
      id: 'promises-today',
      read: (ref) => [
        for (final p in ref.watch(promisesDueTodayProvider).value ?? const <PromiseRow>[])
          AppAlert(id: 'promise/${p.clientId}', kind: AlertKind.promise, icon: Icons.handshake_rounded, title: (l, f) => l.alertPromiseToday(f.money(p.promisedAmountPoisha)), customerId: p.customerId),
      ],
    ),
  ],
  // FR-M-072: broken promises without a follow-up, on Home.
  todayCards: [TodayCardDef(id: 'broken-promises', order: 15, permission: Perm.promiseCreate, builder: (_) => const BrokenPromisesCard())],
  workLogSources: const [WorkLogSourceDef(id: 'promises', watch: watchPromiseWorkLog)],
  timelineSources: [
    TimelineSourceDef(
      id: 'promises',
      watch: (context, ref, id) {
        final l = AppLocalizations.of(context);
        final lang = Localizations.localeOf(context).languageCode;
        return combineLatest2(watchPromisesFor(ref, id), watchColleagueActivities(ref.read(databaseProvider), id, 'promise'), (rows, others) {
          final f = ref.read(fmtProvider);
          final myName = ref.read(sessionProvider).user?.name.of(lang);
          // FR-M-072: a chain shows its attempt number on every promise in it (attempt 1 too, once followed up).
          final inChain = {for (final p in rows) if (p.followUpOf != null) p.followUpOf!};
          return [
            for (final p in rows)
              TimelineEntry(
                at: p.createdAt,
                icon: p.attempt > 1 ? Icons.replay_rounded : Icons.handshake_rounded,
                title: l.timelinePromise(f.money(p.promisedAmountPoisha), f.date(p.promisedDate)),
                subtitle: [
                  if (p.attempt > 1 || inChain.contains(p.serverId) || inChain.contains(p.clientId)) l.promiseAttempt(f.num(p.attempt)),
                  f.dateTime(p.createdAt),
                  if ((p.createdByName ?? myName) != null) l.timelinePromiseBy((p.createdByName ?? myName)!),
                  if (p.note != null) p.note!,
                ].join(' · '),
                statusChip: Builder(builder: (c) => promiseStatusChip(c, p)),
                trailing: needsFollowUp(p, rows) && ref.read(accessProvider).can(Perm.promiseCreate) ? PromiseFollowUpButton(promise: p) : null,
              ),
            for (final o in others)
              TimelineEntry(
                at: o.at,
                icon: Icons.handshake_rounded,
                title: l.timelinePromise(f.money(o.amountPoisha ?? 0), o.promisedDate == null ? '' : f.date(o.promisedDate!)),
                subtitle: [f.dateTime(o.at), l.timelinePromiseBy(o.staffName), if (o.note != null) o.note!].join(' · '),
              ),
          ];
        });
      },
    ),
  ],
);
