import 'package:go_router/go_router.dart';

import '../../core/feature/feature_manifest.dart';
import 'src/notices_data.dart';
import 'src/notices_screens.dart';

/// Notices from the office with "পড়েছি" (master FR-NOT-005, FR-M-027,
/// contract 1.12.0). Self-service: every staff member reads what was sent
/// to them. Works offline; the read tap is the `broadcast_ack` mutation.
final noticesManifest = FeatureManifest(
  name: 'notices',
  flag: 'module.notifications',
  routes: [
    GoRoute(path: '/notices', builder: (_, _) => const NoticesScreen()),
    GoRoute(path: '/notices/:id', builder: (_, s) => NoticeDetailScreen(id: s.pathParameters['id']!)),
  ],
  pullHandlers: [BroadcastPullHandler()],
  pushHandlers: [BroadcastAckPushHandler()],
  todayCards: [TodayCardDef(id: 'notices', order: 0, builder: (_) => const NoticesTodayBanner())],
  meEntries: [MeEntryDef(id: 'notices', order: 6, builder: (_) => const NoticesMeEntry())],
);
