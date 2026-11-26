import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/settings/ui_prefs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/money_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../customer_providers.dart';
import '../domain/customer.dart';
import 'bad_tag_frame.dart';
import 'invoice_kind_label.dart';
import 'work_marks_row.dart';

/// The Home work-list row (FR-M-067, owner request 2026-11-23, design guide §5.1), four lines:
/// 1. name, and only the amount at the far right;
/// 2. branch and invoice numbers, full width;
/// 3. the larger work marks (visit, paid this month, promise, map pin) and, at the right, [action] (Collect);
/// 4. how long it is overdue, full width; and for an open promise, who took it.
///
/// The Customers list uses the same row (owner request 2026-11-23) with [listDetails]: line 2 then also says the
/// invoice type and how far away the customer is, and [action] is an arrow to the details page instead of Collect.
///
/// A customer with a bad tag (or whose latest visit says runaway) gets the frame and chip of its tag kind
/// around these lines (FR-M-081, owner request 2026-11-26).
class CustomerWorkRow extends ConsumerWidget {
  const CustomerWorkRow({super.key, required this.customer, this.onTap, this.action, this.listDetails = false});
  final Customer customer;
  final VoidCallback? onTap;

  /// Customers list: show the invoice type (FR-M-066) and the distance on line 2.
  final bool listDetails;

  /// The button at the end of line 3 (Home passes Collect); null leaves the marks alone on the line.
  final Widget? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sc = context.statusColors;
    final where = [?customer.branchName(lang), ...customer.invoiceNos];
    final days = customer.row.daysOverdue;
    final promisedBy = customer.row.openPromiseDate == null ? null : ref.watch(promiseMakersProvider.select((m) => m.value?[customer.id]));

    return InkWell(
      onTap: onTap,
      // FR-M-081: a bad-tag customer's row sits in the frame of its tag kind, chip on the frame.
      child: BadTagRowBody(
        customer: customer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Text(customer.nameOf(lang), key: const Key('work-row-name'), style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: Space.s8),
                MoneyText(customer.outstanding, key: const Key('work-row-amount'), style: AppTheme.tabular(t.titleMedium!)),
              ],
            ),
            if (listDetails && (!customer.kinds.isEmpty || where.isNotEmpty || customer.distanceM != null)) ...[
              const SizedBox(height: Space.s4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!customer.kinds.isEmpty) ...[InvoiceKindLabel(kinds: customer.kinds), const SizedBox(width: Space.s8)],
                  Expanded(
                    child: Text(
                      [...where, if (customer.distanceM != null) f.distance(customer.distanceM!)].join(' · '),
                      key: const Key('work-row-where'),
                      style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ] else if (where.isNotEmpty) ...[
              const SizedBox(height: Space.s2),
              Text(where.join(' · '), key: const Key('work-row-where'), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: Space.s8),
            Row(
              children: [
                Expanded(child: WorkMarksRow(customer: customer, large: true)),
                if (action != null) ...[const SizedBox(width: Space.s8), action!],
              ],
            ),
            if (days > 0) ...[
              const SizedBox(height: Space.s8),
              Text(
                l.statusOverdueDays(f.daySpan(days)),
                key: const Key('work-row-overdue'),
                style: t.bodyMedium!.copyWith(color: sc.of(AppStatus.overdue).fg, fontWeight: FontWeight.w600),
              ),
            ],
            if (promisedBy != null) ...[
              const SizedBox(height: Space.s4),
              Row(children: [
                Icon(Icons.handshake_rounded, size: 18, color: sc.of(AppStatus.promised).fg),
                const SizedBox(width: Space.s4),
                Expanded(child: Text(l.promisedBy(promisedBy), key: const Key('work-row-promised-by'), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant))),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

/// The Customers-list end of line 3: an arrow that says "tap to open the details" (owner request 2026-11-23).
class OpenDetailsArrow extends StatelessWidget {
  const OpenDetailsArrow({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: cs.secondaryContainer, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(Icons.chevron_right_rounded, size: 28, color: cs.onSecondaryContainer),
      ),
    );
  }
}
