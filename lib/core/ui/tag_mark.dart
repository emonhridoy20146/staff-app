import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/tag_colors.dart';
import '../theme/tokens.dart';

/// Icon of a bad-tag kind (design guide §2 `status.tag.*`): the same glyphs the app already uses for the
/// same thing (runaway and refused visits, the mock-location shield, the broken-promise heart, the tag flag).
IconData tagKindIcon(TagKind k) => switch (k) {
      TagKind.absconded => Icons.directions_run_rounded,
      TagKind.legal => Icons.gavel_rounded,
      TagKind.refusedToPay => Icons.block_rounded,
      TagKind.other => Icons.flag_rounded,
      TagKind.fraudSuspected => Icons.gpp_maybe_rounded,
      TagKind.brokenPromise => Icons.heart_broken_rounded,
      TagKind.planEndedUnpaid => Icons.event_busy_rounded,
    };

/// The short word on the chip, the same words as the tag sheet's options.
String tagKindLabel(AppLocalizations l, TagKind k) => switch (k) {
      TagKind.absconded => l.tagKindAbsconded,
      TagKind.legal => l.tagKindLegal,
      TagKind.refusedToPay => l.tagKindRefused,
      TagKind.other => l.tagKindOther,
      TagKind.fraudSuspected => l.tagKindFraud,
      TagKind.brokenPromise => l.tagKindBrokenPromise,
      TagKind.planEndedUnpaid => l.tagKindPlanEnded,
    };

/// Height of a [TagChip] at the current text size (24 dp at 1.0); [TagFrame] hangs the chip on its top edge
/// by half of it.
double tagChipHeight(BuildContext context) => math.max(Space.s24, MediaQuery.textScalerOf(context).scale(14) * 1.2 + Space.s8);

/// The chip of a bad-tag kind: icon and short word in the kind's colour on its tint, with a hairline in the
/// frame colour. The strongest kind (পলাতক) is filled. Colour never stands alone: icon and word are always there.
class TagChip extends StatelessWidget {
  const TagChip(this.kind, {super.key, this.semanticsLabel});
  final TagKind kind;

  /// Spoken instead of the bare word ("খারাপ ট্যাগ: পলাতক"); defaults to that sentence.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final st = context.tagColors.of(kind);
    final fg = kind.strong ? st.bg : st.fg;
    final label = tagKindLabel(l, kind);
    return Semantics(
      label: semanticsLabel ?? l.tagA11y(label),
      excludeSemantics: true,
      child: Container(
        height: tagChipHeight(context),
        padding: const EdgeInsets.symmetric(horizontal: Space.s8),
        decoration: BoxDecoration(
          color: kind.strong ? st.fg : st.bg,
          borderRadius: Radii.brSm,
          border: Border.all(color: st.fg),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(tagKindIcon(kind), size: 16, color: fg),
          const SizedBox(width: Space.s4),
          Flexible(
            child: Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: fg, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }
}

/// The frame of a bad-tag customer (FR-M-081, design guide §6): a border in the kind's colour around [child]
/// with the [TagChip] sitting on its top edge, like the label of an outlined field. 1.5 dp, 2 dp for the
/// strongest kind, +0.5 dp in high-contrast mode. The frame is [inset] inside the row (8 dp) and the chip
/// starts 8 dp inside the frame, so a row's content keeps its 16 dp column whether framed or not.
///
/// [child] brings its own padding below the chip; the frame adds the room the chip needs above it.
class TagFrame extends StatelessWidget {
  const TagFrame({super.key, required this.kind, required this.child, this.semanticsLabel, this.inset = Space.s8, this.radius = Radii.md});
  final TagKind kind;
  final Widget child;
  final String? semanticsLabel;

  /// Gap between the row's edges and the frame, left and right.
  final double inset;
  final double radius;

  /// Room the frame takes above and below [child], besides the chip's own height.
  static const _gapAbove = Space.s4;
  static const _gapBelow = Space.s8;

  static double strokeOf(BuildContext context, TagKind kind) {
    // High contrast is told by the theme's thicker card border (app_theme.dart).
    final shape = Theme.of(context).cardTheme.shape;
    final hc = shape is RoundedRectangleBorder && shape.side.width > 1;
    return (kind.strong ? 2.0 : 1.5) + (hc ? 0.5 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final st = context.tagColors.of(kind);
    final chip = tagChipHeight(context);
    final stroke = strokeOf(context, kind);
    return Padding(
      padding: EdgeInsets.fromLTRB(inset, _gapAbove, inset, _gapBelow),
      child: Stack(clipBehavior: Clip.none, children: [
        Padding(
          padding: EdgeInsets.only(top: chip / 2),
          child: DecoratedBox(
            key: const Key('tag-frame'),
            decoration: BoxDecoration(border: Border.all(color: st.fg, width: stroke), borderRadius: BorderRadius.all(Radius.circular(radius))),
            // The chip's lower half hangs into the frame; the content starts under it.
            child: Padding(padding: EdgeInsets.only(top: chip / 2), child: child),
          ),
        ),
        PositionedDirectional(top: 0, start: Space.s8, end: Space.s8, child: Align(alignment: AlignmentDirectional.centerStart, child: TagChip(kind, semanticsLabel: semanticsLabel))),
      ]),
    );
  }
}
