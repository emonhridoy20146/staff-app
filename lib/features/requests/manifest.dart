import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/theme/tag_colors.dart' show ActionTone;
import '../../l10n/app_localizations.dart';
import 'src/requests_data.dart';
import 'src/requests_ui.dart';

/// Staff requests (FR-M-075, ADR-M38, contract 1.48.0): report, tell or ask the office. `normal` goes to the area
/// manager, `important` to the super admin; the office forwards, assigns, comments and resolves, and every step is
/// on the timeline. New requests and comments work offline (`request`, `request_comment` mutations); the office's
/// steps arrive on the pull (entity `request`) and show behind the bell. Gated by `module.requests` and
/// `request.create` (the server checks every mutation).
final requestsManifest = FeatureManifest(
  name: 'requests',
  flag: 'module.requests',
  permissions: const [Perm.requestCreate],
  routes: [
    GoRoute(path: '/requests', builder: (_, _) => const RequestsScreen()),
    GoRoute(
      path: '/requests/new',
      builder: (_, s) => RequestFormScreen(customerId: s.uri.queryParameters['customerId'], customerName: s.uri.queryParameters['customerName']),
    ),
    GoRoute(path: '/requests/:key', builder: (_, s) => RequestDetailScreen(requestKey: s.pathParameters['key']!)),
  ],
  pullHandlers: [RequestPullHandler()],
  pushHandlers: [RequestPushHandler()],
  customerActions: [
    CustomerActionDef(
      id: 'request',
      order: 50,
      permission: Perm.requestCreate,
      icon: Icons.add_comment_rounded,
      label: (c) => AppLocalizations.of(c).requestCustomerAction,
      onTap: (c, ref, x) => c.push(Uri(path: '/requests/new', queryParameters: {'customerId': x.customerId, 'customerName': x.customerName}).toString()),
    ),
  ],
  alertSources: [
    AlertSourceDef(
      id: 'requests-news',
      read: (ref) => [
        for (final r in ref.watch(requestsWithNewsProvider))
          AppAlert(
            id: 'request/${r.key}',
            kind: r.assignedToMe ? AlertKind.task : AlertKind.notice,
            icon: Icons.forum_rounded,
            title: (l, f) => switch (r.unseenChange?.type) {
              'resolved' => l.alertRequestResolved(r.row.title),
              'comment' => l.alertRequestComment(r.row.title),
              'assigned' || 'forwarded' when r.assignedToMe => l.alertRequestAssigned(r.row.title),
              _ => l.alertRequestChanged(r.row.title),
            },
            subtitle: (l, f) => r.unseenChange?.note ?? requestTypeLabel(l, r.row.type),
            route: '/requests/${r.key}',
          ),
      ],
    ),
  ],
  meEntries: [MeEntryDef(id: 'requests', order: 7, permission: Perm.requestCreate, builder: (_) => const RequestsMeEntry())],
  quickActions: [
    QuickActionDef(id: 'requests', order: 60, icon: Icons.forum_rounded, tone: ActionTone.brand, label: (l) => l.requestsTitle, route: '/requests', permission: Perm.requestCreate, badge: (ref) => ref.watch(requestsWithNewsProvider).length),
  ],
);
