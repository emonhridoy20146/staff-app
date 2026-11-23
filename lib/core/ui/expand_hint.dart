import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/tokens.dart';

/// The "Details ▾ / Hide ▴" pill on a card that opens on tap (owner request 2026-11-23): a bare chevron did not
/// say the card can be tapped, so the hint is a word plus the arrow on a tinted pill. [color] follows the card's
/// tone (e.g. the green on-duty card); the default is the primary colour.
class ExpandHint extends StatelessWidget {
  const ExpandHint({super.key, required this.open, this.color});
  final bool open;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fg = color ?? Theme.of(context).colorScheme.primary;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(color: fg.withValues(alpha: 0.12), borderRadius: const BorderRadius.all(Radius.circular(Radii.full))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.s8 + 2, Space.s4, Space.s4, Space.s4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                open ? l.expandHide : l.expandShow,
                style: t.labelMedium!.copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(Icons.expand_more_rounded, size: 20, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
