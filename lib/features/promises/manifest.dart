import 'package:material_ui/material_ui.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/settings/ui_prefs.dart';
import '../../l10n/app_localizations.dart';
import 'src/promises.dart';

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
  timelineSources: [
    TimelineSourceDef(
      id: 'promises',
      watch: (context, ref, id) {
        final l = AppLocalizations.of(context);
        return watchPromisesFor(ref, id).map((rows) {
          final f = ref.read(fmtProvider);
          return [
            for (final p in rows)
              TimelineEntry(
                at: p.createdAt,
                icon: Icons.handshake_rounded,
                title: l.timelinePromise(f.money(p.promisedAmountPoisha), f.date(p.promisedDate)),
                subtitle: [f.dateTime(p.createdAt), if (p.note != null) p.note!].join(' · '),
                statusChip: Builder(builder: (c) => promiseStatusChip(c, p)),
              ),
          ];
        });
      },
    ),
  ],
);
