import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'location_tracker.dart';
import 'tracking_health.dart';
import 'tracking_setup_screen.dart';

/// Today card: "Near (customer)? Record a visit" after a 5-minute dwell.
class VisitSuggestionCard extends ConsumerWidget {
  const VisitSuggestionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(visitSuggestionProvider);
    if (s == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.place_rounded, color: cs.primary),
            const SizedBox(width: Space.s8),
            Expanded(child: Text(l.visitSuggestTitle(s.customerName), style: t.titleMedium)),
          ]),
          const SizedBox(height: Space.s8),
          Text(l.visitSuggestBody(f.duration(s.dwell)), style: t.bodyLarge),
          const SizedBox(height: Space.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => ref.read(locationTrackerProvider).dismissSuggestion(), child: Text(l.visitSuggestNo)),
              const SizedBox(width: Space.s8),
              FilledButton.icon(
                icon: const Icon(Icons.how_to_reg_rounded),
                label: Text(l.visitSuggestYes),
                onPressed: () {
                  ref.read(locationTrackerProvider).dismissSuggestion();
                  context.push('/visit/${s.customerId}');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Me tab: tracking status, so location sharing is always visible to the
/// user (CLAUDE.md §2.6).
class TrackingStatusCard extends ConsumerWidget {
  const TrackingStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final sem = context.semanticColors;
    final s = ref.watch(trackingStatusProvider);
    final pending = ref.watch(pendingPointsProvider).value ?? 0;
    final provider = s.providerId == 'paid' ? l.trackingProviderPaid : l.trackingProviderFree;
    final tone = s.running ? sem.success : sem.info;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(s.running ? Icons.my_location_rounded : Icons.location_disabled_rounded, color: tone.fg),
            const SizedBox(width: Space.s8),
            Expanded(child: Text(l.trackingTitle, style: t.titleMedium)),
          ]),
          const SizedBox(height: Space.s8),
          Text(s.running ? l.trackingOn(provider) : l.trackingOff, style: t.bodyLarge),
          if (s.lastPointAt != null) ...[
            const SizedBox(height: Space.s4),
            Text(l.trackingLastPoint(f.time(s.lastPointAt!)), style: t.bodyMedium),
          ],
          if (pending > 0) ...[
            const SizedBox(height: Space.s4),
            Text(l.trackingPending(f.num(pending)), style: t.bodyMedium),
          ],
          if (s.fellBack) ...[
            const SizedBox(height: Space.s12),
            InfoBanner(icon: Icons.info_outline_rounded, tone: BannerTone.warning, text: l.trackingFallback),
          ],
          // FR-M-078: the same health line as on Today, and the way to the background set-up.
          if (ref.watch(trackingIssueProvider) != null) ...[const SizedBox(height: Space.s12), const TrackingHealthBanner()],
          const SizedBox(height: Space.s12),
          OutlinedButton.icon(
            key: const Key('tracking-setup-entry'),
            onPressed: () => context.push('/location/background-setup'),
            icon: const Icon(Icons.settings_suggest_rounded),
            label: Text(l.trackSetupEntry),
          ),
        ],
      ),
    );
  }
}
