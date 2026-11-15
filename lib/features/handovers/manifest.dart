import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/settings/ui_prefs.dart';
import '../../core/ui/common.dart';
import '../../l10n/app_localizations.dart';
import 'src/handovers.dart';

/// Customer handovers between staff (FR-HND-001…004). Accept / reject is
/// online-only; everything else is visible offline.
final handoversManifest = FeatureManifest(
  name: 'handovers',
  flag: 'module.handovers',
  permissions: const [Perm.handoverRequest],
  routes: [GoRoute(path: '/handovers', builder: (_, _) => const HandoversScreen())],
  pullHandlers: [HandoverPullHandler()],
  todayCards: [TodayCardDef(id: 'handover-banner', order: 5, builder: (_) => const _HandoverBanner())],
  meEntries: [MeEntryDef(id: 'handovers', order: 30, builder: (_) => const _HandoverMeEntry())],
);

class _HandoverBanner extends ConsumerWidget {
  const _HandoverBanner();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingHandoversProvider);
    if (pending.isEmpty) return const SizedBox.shrink();
    return InfoBanner(
      icon: Icons.swap_horizontal_circle_rounded,
      tone: BannerTone.info,
      text: AppLocalizations.of(context).todayHandoverBanner(pending.first.fromUserName),
      onTap: () => context.push('/handovers'),
    );
  }
}

class _HandoverMeEntry extends ConsumerWidget {
  const _HandoverMeEntry();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final n = ref.watch(pendingHandoversProvider).length;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/handovers'),
      child: ListTile(
        minTileHeight: 64,
        leading: const Icon(Icons.swap_horiz_rounded),
        title: Text(l.meHandovers),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (n > 0) Badge(label: Text(f.num(n))),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    );
  }
}
