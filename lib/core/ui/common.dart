import 'package:material_ui/material_ui.dart';

import '../theme/status_colors.dart';
import '../theme/tokens.dart';

/// Empty state: 48 dp icon, title, one sentence, optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body, this.action});
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(Space.s32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: Space.s16),
          Text(title, style: t.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: Space.s4),
          Text(body, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: Space.s16), action!],
        ],
      ),
    );
  }
}

/// Section header with optional count and trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.count, this.trailing, this.color});
  final String title;
  final String? count;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.screen, Space.s20, Space.s8, Space.s8),
      child: Row(
        children: [
          if (color != null) ...[
            Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: Radii.brXs)),
            const SizedBox(width: Space.s8),
          ],
          Flexible(child: Text(title, style: t.titleSmall)),
          if (count != null) ...[
            const SizedBox(width: Space.s8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: 1),
              decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: const BorderRadius.all(Radius.circular(Radii.full))),
              child: Text(count!, style: t.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
            ),
          ],
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

enum BannerTone { info, warning, danger, success }

/// Inline banner for problems / handover / cash warnings.
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.icon, required this.text, this.tone = BannerTone.info, this.onTap, this.trailing});
  final IconData icon;
  final String text;
  final BannerTone tone;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = context.semanticColors;
    final st = switch (tone) {
      BannerTone.info => s.info,
      BannerTone.warning => s.warning,
      BannerTone.danger => s.danger,
      BannerTone.success => s.success,
    };
    return Material(
      color: st.bg,
      // xl like the cards around it (Home redesign 2026-11-26), so banners and cards share one corner.
      borderRadius: Radii.brXl,
      child: InkWell(
        borderRadius: Radii.brXl,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s12),
            child: Row(
              children: [
                Icon(icon, color: st.fg),
                const SizedBox(width: Space.s12),
                Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: st.fg, fontWeight: FontWeight.w600))),
                trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: st.fg) : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card with token padding.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(Space.s16), this.onTap, this.color});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Card(
        color: color,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      );
}

/// Labelled value used in summaries.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({super.key, required this.label, required this.value});
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: t.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          const SizedBox(width: Space.s12),
          Expanded(child: DefaultTextStyle(style: t.bodyLarge!.copyWith(fontWeight: FontWeight.w600), child: value)),
        ],
      ),
    );
  }
}

/// Shows a floating snackbar with optional undo.
void showAppSnack(BuildContext context, String text, {String? actionLabel, VoidCallback? onAction, IconData icon = Icons.check_circle_rounded}) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(children: [Icon(icon, color: cs.onInverseSurface, size: 20), const SizedBox(width: Space.s12), Expanded(child: Text(text))]),
        action: actionLabel == null ? null : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
}
