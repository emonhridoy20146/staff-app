import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/theme/tag_colors.dart' show ActionTone;
import 'src/cowork_data.dart';
import 'src/cowork_widgets.dart';

/// Co-work (FR-CW-001…005, contract 1.9.0): staff of one branch work
/// together for the day. Asking, answering and leaving are online-only;
/// the session is kept on the phone, so joint visits work offline.
final coworkManifest = FeatureManifest(
  name: 'cowork',
  flag: 'module.cowork',
  permissions: const [Perm.coworkUse],
  routes: [GoRoute(path: '/cowork', builder: (_, _) => const CoworkScreen())],
  pullHandlers: [CoworkSessionPullHandler()],
  alertSources: [
    AlertSourceDef(
      id: 'cowork-invites',
      read: (ref) => [
        for (final s in ref.watch(coworkTodayProvider).invites)
          AppAlert(id: 'cowork/${s.id}', kind: AlertKind.cowork, icon: Icons.groups_rounded, title: (l, f) => l.alertCoworkInvite(s.nameOf(s.createdBy) ?? '—'), route: '/cowork'),
      ],
    ),
  ],
  todayCards: [TodayCardDef(id: 'cowork', order: 4, permission: Perm.coworkUse, builder: (_) => const CoworkTodayCard())],
  meEntries: [MeEntryDef(id: 'cowork', order: 25, permission: Perm.coworkUse, builder: (_) => const CoworkMeEntry())],
  quickActions: [
    QuickActionDef(id: 'cowork', order: 120, icon: Icons.groups_rounded, tone: ActionTone.teal, label: (l) => l.coworkTitle, route: '/cowork', permission: Perm.coworkUse, badge: (ref) => ref.watch(coworkTodayProvider).invites.length),
  ],
);
