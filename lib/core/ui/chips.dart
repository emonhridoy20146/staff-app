import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../settings/ui_prefs.dart';
import '../theme/status_colors.dart';
import '../theme/tokens.dart';

/// Quiet pill used by SyncChip and DutyChip.
class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.fg, required this.bg, this.onTap, this.spinning = false, this.dot});
  final IconData icon;
  final String label;
  final Color fg;
  final Color bg;
  final VoidCallback? onTap;
  final bool spinning;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.labelMedium!.copyWith(color: fg);
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36, minWidth: Sizes.minTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dot != null) ...[
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                    const SizedBox(width: Space.s8),
                  ] else if (spinning)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                    )
                  else
                    Icon(icon, size: 16, color: fg),
                  if (dot == null) const SizedBox(width: Space.s4 + 2),
                  Text(label, style: t),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sync state chip: synced · syncing · queued N · problem N · offline.
class SyncChip extends ConsumerWidget {
  const SyncChip({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final cs = Theme.of(context).colorScheme;
    final st = context.statusColors;
    final status = ref.watch(syncStatusProvider).value ?? ref.read(syncEngineProvider).current;
    final pending = ref.watch(pendingCountProvider).value ?? 0;
    final failed = (ref.watch(failedCountProvider).value ?? 0) + (ref.watch(openConflictCountProvider).value ?? 0);

    if (failed > 0) {
      return _Pill(icon: Icons.error_rounded, label: l.syncProblems(f.num(failed)), fg: cs.error, bg: cs.errorContainer, onTap: onTap);
    }
    if (status.running) {
      return _Pill(icon: Icons.sync_rounded, label: l.syncSyncing, fg: cs.onSurfaceVariant, bg: cs.surfaceContainerHigh, onTap: onTap, spinning: true);
    }
    if (!status.online) {
      return _Pill(icon: Icons.cloud_off_rounded, label: pending > 0 ? '${l.syncOffline} · ${f.num(pending)}' : l.syncOffline, fg: st.of(AppStatus.pending).fg, bg: st.of(AppStatus.pending).bg, onTap: onTap);
    }
    if (pending > 0) {
      return _Pill(icon: Icons.cloud_upload_rounded, label: l.syncQueued(f.num(pending)), fg: st.of(AppStatus.pending).fg, bg: st.of(AppStatus.pending).bg, onTap: onTap);
    }
    return _Pill(icon: Icons.cloud_done_rounded, label: l.syncSynced, fg: cs.onSurfaceVariant, bg: cs.surfaceContainerHigh, onTap: onTap);
  }
}

/// Always-visible connection mark in the app's top bar, just left of the GPS icon (owner requests 2026-11-19,
/// 2026-11-23; it was a strip above the bottom navigation before): green dot + "অনলাইন" while the server can be
/// reached, grey dot + "অফলাইন" when the phone has no network or the last sync could not reach the server. The
/// word is always there, so the state never rests on colour alone.
class OnlineDot extends ConsumerWidget {
  const OnlineDot({super.key, this.color});

  /// Text colour; defaults to `onSurface`. The top bar passes `onPrimaryContainer`.
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final online = (ref.watch(syncStatusProvider).value ?? ref.read(syncEngineProvider).current).online;
    final label = online ? l.networkOnline : l.syncOffline;
    final dot = online ? context.semanticColors.success.fg : cs.outline;
    final fg = color ?? cs.onSurface;
    return Semantics(
      liveRegion: true,
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.s4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: const Key('online-dot'),
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle, border: Border.all(color: cs.surface, width: 1.5)),
            ),
            const SizedBox(width: Space.s4),
            Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: online ? fg : fg.withValues(alpha: 0.75)), maxLines: 1),
          ],
        ),
      ),
    );
  }
}

enum DutyState { off, on, onBreak }

/// Duty chip: off duty (neutral) · on duty (success dot) · on break (warning).
class DutyChip extends StatelessWidget {
  const DutyChip({super.key, required this.state, this.onTap, this.trackingOn = false});
  final DutyState state;
  final bool trackingOn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    return switch (state) {
      DutyState.off => _Pill(icon: Icons.work_off_rounded, label: l.dutyOff, fg: cs.onSurfaceVariant, bg: cs.surfaceContainerHigh, onTap: onTap),
      DutyState.on => _Pill(
          icon: Icons.work_rounded,
          label: trackingOn ? '${l.dutyOn} · ${l.dutyTracking}' : l.dutyOn,
          fg: sem.success.fg,
          bg: sem.success.bg,
          dot: sem.success.fg,
          onTap: onTap,
        ),
      DutyState.onBreak => _Pill(icon: Icons.coffee_rounded, label: l.dutyOnBreak, fg: sem.warning.fg, bg: sem.warning.bg, onTap: onTap),
    };
  }
}
