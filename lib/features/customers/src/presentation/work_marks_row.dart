import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/status_colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../customer_providers.dart';
import '../domain/customer.dart';
import '../domain/work_marks.dart';

/// Four small marks on a customer row (FR-M-038): visited, money, promise
/// and map pin, for the current month, in every filter. A mark that is "on"
/// has its status colour and icon; one that is "off" is a grey outline. Each
/// has its meaning in words for TalkBack (never colour alone).
class WorkMarksRow extends ConsumerWidget {
  const WorkMarksRow({super.key, required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final m = workMarksFor(ref, customer);
    final sc = context.statusColors;
    final sem = context.semanticColors;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _Mark(
        on: m.visit != VisitMark.none,
        style: m.visit == VisitMark.today ? sem.success : sem.info,
        icon: Icons.directions_walk_rounded,
        label: switch (m.visit) { VisitMark.today => l.marksVisitToday, VisitMark.month => l.marksVisitMonth, VisitMark.none => l.marksVisitNone },
      ),
      _Mark(
        on: m.money != MoneyMark.none,
        style: sc.of(m.money == MoneyMark.pending ? AppStatus.pending : AppStatus.paid),
        icon: m.money == MoneyMark.pending ? Icons.cloud_upload_outlined : Icons.payments_rounded,
        label: switch (m.money) { MoneyMark.paid => l.marksPaid, MoneyMark.pending => l.marksPending, MoneyMark.none => l.marksPaidNone },
      ),
      _Mark(
        on: m.promise != PromiseMark.none,
        style: sc.of(AppStatus.promised),
        icon: Icons.handshake_rounded,
        label: m.promise == PromiseMark.open ? l.marksPromiseOpen : l.marksPromiseNone,
      ),
      _Mark(
        on: true,
        style: m.pin ? sem.success : sem.danger,
        icon: m.pin ? Icons.location_on_rounded : Icons.location_off_rounded,
        label: m.pin ? l.marksPinSet : l.marksPinMissing,
      ),
    ]);
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.on, required this.style, required this.icon, required this.label});
  final bool on;
  final StatusStyle style;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      child: Container(
        width: 22,
        height: 22,
        margin: const EdgeInsetsDirectional.only(end: Space.s4),
        decoration: BoxDecoration(
          color: on ? style.bg : null,
          borderRadius: Radii.brSm,
          border: on ? null : Border.all(color: cs.outlineVariant),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: on ? style.fg : cs.outline),
      ),
    );
  }
}
