import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/status_colors.dart';
import '../theme/tokens.dart';
import 'dashed_border.dart';

IconData statusIcon(AppStatus s) => switch (s) {
      AppStatus.overdue => Icons.schedule_rounded,
      AppStatus.dueToday => Icons.event_rounded,
      AppStatus.promised => Icons.handshake_rounded,
      AppStatus.current => Icons.radio_button_checked_rounded,
      AppStatus.paid => Icons.verified_rounded,
      AppStatus.badSuggested => Icons.outlined_flag_rounded,
      AppStatus.tagged => Icons.flag_rounded,
      AppStatus.pending => Icons.cloud_upload_rounded,
      AppStatus.mock => Icons.gpp_maybe_rounded,
    };

String statusLabel(AppLocalizations l, AppStatus s) => switch (s) {
      AppStatus.overdue => l.statusOverdue,
      AppStatus.dueToday => l.statusDueToday,
      AppStatus.promised => l.statusPromised,
      AppStatus.current => l.statusCurrent,
      AppStatus.paid => l.statusPaid,
      AppStatus.badSuggested => l.statusBadSuggested,
      AppStatus.tagged => l.statusTagged,
      AppStatus.pending => l.statusPending,
      AppStatus.mock => l.statusMock,
    };

/// 24 dp status pill: icon 16 + label (design guide §6). Colour never
/// carries meaning alone — there is always an icon and a label.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.label, this.dense = false});
  final AppStatus status;
  final String? label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final st = context.statusColors.of(status);
    final text = label ?? statusLabel(AppLocalizations.of(context), status);
    final style = Theme.of(context).textTheme.labelMedium!.copyWith(color: st.fg, height: 1.2);
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: dense ? Space.s4 + 2 : Space.s8, vertical: Space.s2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(status), size: 16, color: st.fg),
          const SizedBox(width: Space.s4),
          Flexible(child: Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24),
      child: st.dashed
          ? CustomPaint(
              painter: DashedRRectPainter(color: st.fg, radius: Radii.sm),
              child: DecoratedBox(
                decoration: BoxDecoration(color: st.bg, borderRadius: Radii.brSm),
                child: content,
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(color: st.bg, borderRadius: Radii.brSm),
              child: content,
            ),
    );
  }
}
