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
import '../domain/customer.dart';

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
    final st = context.statusColors.of(primary);
    final badges = customer.badges(today).where((b) => b != AppStatus.current).take(2).toList();
    final name = customer.nameOf(lang);
    // Staff in several branches (1.19.0): each row says which branch it is in.
    final branch = ref.watch(multiBranchProvider) ? customer.branchName(lang) : null;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Sizes.row3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.screen, vertical: Space.s12),
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
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: Space.s4 + 2),
                      Wrap(
                        spacing: Space.s4 + 2,
                        runSpacing: Space.s4,
                        children: [
                          for (final b in badges)
                            StatusBadge(
                              b,
                              dense: true,
                              label: b == AppStatus.overdue ? l.statusOverdueDays(f.num(customer.row.daysOverdue)) : null,
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
              if (trailing != null) ...[const SizedBox(width: Space.s8), trailing!],
            ],
          ),
        ),
      ),
    );
  }

  static String _initial(String name) {
    final cleaned = name.replaceFirst(RegExp(r'^(মোঃ|মো\.|Md\.?)\s*'), '').trim();
    if (cleaned.isEmpty) return '?';
    return cleaned.characters.first;
  }
}
