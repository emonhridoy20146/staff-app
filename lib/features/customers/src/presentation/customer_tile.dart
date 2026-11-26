import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/settings/ui_prefs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/money_text.dart';
import '../../../../core/ui/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../customer_providers.dart';
import '../../../../core/theme/tag_colors.dart';
import '../domain/customer.dart';
import 'bad_tag_frame.dart';
import 'invoice_kind_label.dart';
import 'returned_mark.dart';
import 'work_marks_row.dart';

/// 88 dp customer row (design guide §5.2): status-tinted initial, name,
/// code · area, outstanding, badge, distance; optional trailing action.
class CustomerTile extends ConsumerWidget {
  const CustomerTile({super.key, required this.customer, this.onTap, this.trailing, this.amountOverride, this.amountCaption});
  final Customer customer;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// e.g. promised amount on Today instead of outstanding.
  final int? amountOverride;
  final String? amountCaption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final today = ref.watch(todayProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final primary = customer.primaryStatus(today);
    // FR-M-081: a bad-tag customer's initial is in its tag kind's colours, and the frame's chip says what the
    // plain "tagged" badge said.
    final bad = customer.badTag;
    final st = bad == null ? context.statusColors.of(primary) : context.tagColors.of(bad.kind);
    final badges = customer.badges(today).where((b) => b != AppStatus.current && (bad == null || b != AppStatus.tagged)).take(2).toList();
    final name = customer.nameOf(lang);
    // Staff in several branches (1.19.0): each row says which branch it is in.
    final branch = ref.watch(multiBranchProvider) ? customer.branchName(lang) : null;

    // FR-M-085: a customer whose every invoice was returned is listed with the marker but does not open.
    return returnedRowSemantics(context, customer, InkWell(
      onTap: customer.onlyReturned ? null : onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Sizes.row3),
        child: BadTagRowBody(
          customer: customer,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: st.bg, shape: BoxShape.circle, border: Border.all(color: st.fg.withValues(alpha: 0.25))),
                alignment: Alignment.center,
                child: Text(_initial(name), style: t.titleMedium!.copyWith(color: st.fg, height: 1.1)),
              ),
              const SizedBox(width: Space.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      [
                        customer.code,
                        ?branch,
                        if (customer.areaName != null) customer.areaName!,
                        if (customer.distanceM != null) f.distance(customer.distanceM!),
                      ].join(' · '),
                      style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // FR-M-038: what was done with the customer this month, in every filter.
                    const SizedBox(height: Space.s4 + 2),
                    WorkMarksRow(customer: customer),
                    if (badges.isNotEmpty || !customer.kinds.isEmpty || customer.hasReturned) ...[
                      const SizedBox(height: Space.s4 + 2),
                      Wrap(
                        spacing: Space.s4 + 2,
                        runSpacing: Space.s4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // FR-M-066: "কিস্তি" / "বাকি", or the count of each when there are several invoices.
                          if (!customer.kinds.isEmpty) InvoiceKindLabel(kinds: customer.kinds),
                          // FR-M-085: has an invoice returned in the ERP (never counted).
                          if (customer.hasReturned) const ReturnedCustomerMark(),
                          for (final b in badges)
                            StatusBadge(
                              b,
                              dense: true,
                              label: b == AppStatus.overdue ? l.statusOverdueDays(f.daySpan(customer.row.daysOverdue)) : null,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Space.s8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MoneyText(amountOverride ?? customer.outstanding, style: AppTheme.tabular(t.titleMedium!)),
                  if (amountCaption != null) Text(amountCaption!, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
              if (trailing != null && !customer.onlyReturned) ...[const SizedBox(width: Space.s8), trailing!],
            ],
          ),
        ),
      ),
    ));
  }

  static String _initial(String name) {
    final cleaned = name.replaceFirst(RegExp(r'^(মোঃ|মো\.|Md\.?)\s*'), '').trim();
    if (cleaned.isEmpty) return '?';
    return cleaned.characters.first;
  }
}
