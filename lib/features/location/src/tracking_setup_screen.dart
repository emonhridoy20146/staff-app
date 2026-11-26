import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/location/tracking/native_tracking_service.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'location_tracker.dart';
import 'oem_battery_guide_screen.dart';
import 'tracking_health.dart';

/// Background location set-up (FR-M-078): why it is needed, then 1. ignore battery optimisation (Android's own
/// dialog), 2. the phone brand's autostart / background screen with its steps and a deep link where one exists,
/// 3. what is running right now. Pull to read the phone's state again. Tracking itself still only runs on duty.
class TrackingSetupScreen extends ConsumerWidget {
  const TrackingSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final probe = ref.watch(trackingProbeStateProvider).value ?? const DeviceTrackingProbe();
    final onDuty = ref.watch(trackingOnDutyProvider);
    final running = ref.watch(trackingStatusProvider).running && probe.nativeRunning != false;
    final brandId = oemBrandFor(probe.manufacturer);
    final brand = oemBrands(l).firstWhere((b) => b.id == brandId);
    final makerName = (probe.manufacturer ?? '').isEmpty ? brand.name : probe.manufacturer!;

    Future<void> recheck() async {
      ref.invalidate(trackingProbeStateProvider);
      await ref.read(trackingProbeStateProvider.future);
    }

    final (batteryLabel, batteryStyle) = switch (probe.batteryOptimised) {
      false => (l.trackSetupAllowed, sem.success),
      true => (l.trackSetupNotAllowed, sem.warning),
      null => (l.trackSetupUnknown, StatusStyle(fg: cs.onSurfaceVariant, bg: cs.surfaceContainerHigh)),
    };
    final (statusLabel, statusStyle, statusIcon) = !onDuty
        ? (l.trackSetupOffDuty, StatusStyle(fg: cs.onSurfaceVariant, bg: cs.surfaceContainerHigh), Icons.location_disabled_rounded)
        : probe.authFailed == true
            ? (l.trackSetupAuthFailed, sem.warning, Icons.sync_problem_rounded)
            : running
                ? (l.trackSetupRunning, sem.success, Icons.my_location_rounded)
                : (l.trackSetupNotRunning, sem.danger, Icons.location_off_rounded);

    return Scaffold(
      appBar: AppBar(title: Text(l.trackSetupTitle)),
      body: RefreshIndicator(
        onRefresh: recheck,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
          children: [
            InfoBanner(icon: Icons.info_outline_rounded, text: l.trackSetupWhy),
            const SizedBox(height: Space.s16),
            _StepCard(
              title: l.trackSetupBatteryTitle,
              status: _StatusPill(label: batteryLabel, style: batteryStyle),
              children: [
                Text(l.trackSetupBatteryBody, style: t.bodyMedium),
                if (probe.batteryOptimised != false) ...[
                  const SizedBox(height: Space.s12),
                  FilledButton.icon(
                    key: const Key('tracking-setup-battery'),
                    icon: const Icon(Icons.battery_charging_full_rounded),
                    label: Text(l.trackSetupAllow),
                    onPressed: () async {
                      await NativeTrackingService.requestIgnoreBatteryOptimisations();
                      await recheck();
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: Space.cardGap),
            _StepCard(
              title: l.trackSetupAutostartTitle,
              children: [
                Text(l.trackSetupAutostartBody(makerName), style: t.bodyMedium),
                const SizedBox(height: Space.s12),
                for (final (i, step) in brand.steps.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.s8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: Space.s24,
                        height: Space.s24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
                        child: Text('${i + 1}', style: t.labelSmall!.copyWith(color: cs.onPrimaryContainer)),
                      ),
                      const SizedBox(width: Space.s8),
                      Expanded(child: Text(step, style: t.bodyMedium)),
                    ]),
                  ),
                const SizedBox(height: Space.s4),
                OutlinedButton.icon(
                  key: const Key('tracking-setup-oem'),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(l.trackSetupOpenSettings),
                  onPressed: () async {
                    final ok = await NativeTrackingService.openBackgroundSettings();
                    if (!ok && context.mounted) showAppSnack(context, l.trackSetupOpenFailed, icon: Icons.info_outline_rounded);
                  },
                ),
                TextButton(onPressed: () => context.push('/location/battery-guide'), child: Text(l.trackSetupAllBrands)),
              ],
            ),
            const SizedBox(height: Space.cardGap),
            _StepCard(
              title: l.trackSetupStatusTitle,
              children: [
                Row(children: [
                  Icon(statusIcon, color: statusStyle.fg),
                  const SizedBox(width: Space.s8),
                  Expanded(child: Text(statusLabel, style: t.bodyLarge!.copyWith(color: statusStyle.fg, fontWeight: FontWeight.w600))),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.title, required this.children, this.status});
  final String title;
  final Widget? status;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: Space.s8, runSpacing: Space.s4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(title, style: t.titleMedium),
          ?status,
        ]),
        const SizedBox(height: Space.s8),
        ...children,
      ]),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.style});
  final String label;
  final StatusStyle style;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: style.bg, borderRadius: const BorderRadius.all(Radius.circular(Radii.full))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s2),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: style.fg)),
        ),
      );
}

/// Today card (FR-M-078): shown only on duty when background tracking is not healthy; a tap opens the set-up.
class TrackingHealthBanner extends ConsumerWidget {
  const TrackingHealthBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issue = ref.watch(trackingIssueProvider);
    if (issue == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final (text, tone, icon) = switch (issue) {
      TrackingIssue.notRunning => (l.trackHealthOff, BannerTone.danger, Icons.location_off_rounded),
      TrackingIssue.authRefused => (l.trackHealthAuth, BannerTone.warning, Icons.sync_problem_rounded),
      TrackingIssue.batteryOptimised => (l.trackHealthBattery, BannerTone.warning, Icons.battery_alert_rounded),
    };
    return Semantics(
      liveRegion: true,
      child: InfoBanner(key: const Key('tracking-health-banner'), icon: icon, tone: tone, text: text, onTap: () => context.push('/location/background-setup')),
    );
  }
}
