import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import '../../customers/customers.dart';

/// What waits for me (FR-M-044), behind the bell: promises due today, new
/// tasks, co-work requests, unread notices and handovers. Each feature
/// supplies its own items through the `alertSources` extension point; a tap
/// opens the customer or the page that deals with it. From the phone's own
/// data, so it also works offline.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final sc = context.statusColors;
    final lang = Localizations.localeOf(context).languageCode;
    final alerts = ref.watch(alertsProvider);
    final names = {for (final c in ref.watch(allCustomersProvider).value ?? const <Customer>[]) c.id: c.nameOf(lang)};
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.alertsTitle)),
      body: alerts.isEmpty
          ? EmptyState(icon: Icons.notifications_none_rounded, title: l.alertsEmptyTitle, body: l.alertsEmptyBody)
          : ListView(
              padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(children: [
                    for (var i = 0; i < alerts.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                      Builder(builder: (context) {
                        final a = alerts[i];
                        final style = switch (a.kind) {
                          AlertKind.promise => sc.of(AppStatus.promised),
                          AlertKind.task => sem.warning,
                          AlertKind.cowork => sem.info,
                          AlertKind.notice => sem.info,
                          AlertKind.handover => sem.warning,
                        };
                        final name = a.customerId == null ? null : names[a.customerId];
                        final target = a.customerId != null ? '/customers/${a.customerId}' : a.route;
                        final lines = [if (name != null) a.title(l, f), ?a.subtitle?.call(l, f)];
                        return ListTile(
                          onTap: target == null ? null : () => context.push(target),
                          minTileHeight: Sizes.row3,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: style.bg, borderRadius: Radii.brMd),
                            child: Icon(a.icon, size: 20, color: style.fg),
                          ),
                          title: Text(name ?? a.title(l, f), style: t.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: lines.isEmpty ? null : Text(lines.join(' · '), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                        );
                      }),
                    ],
                  ]),
                ),
              ],
            ),
    );
  }
}
