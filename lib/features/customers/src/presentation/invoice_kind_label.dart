import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/settings/ui_prefs.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/customer.dart';

/// The text of an invoice-type label (FR-M-066). With one open invoice just its kind ("কিস্তি" / "বাকি");
/// with more, or when [counted], the count of each kind ("১ কিস্তি", "২ বাকি"). Kinds with none are left out.
List<(InvoiceKind, String)> invoiceKindTexts(AppLocalizations l, Fmt f, InvoiceKinds k, {bool counted = false}) {
  final withCounts = counted || k.total > 1;
  return [
    if (k.installment > 0) (InvoiceKind.installment, withCounts ? l.kindInstallmentCount(f.num(k.installment)) : l.kindInstallment),
    if (k.credit > 0) (InvoiceKind.credit, withCounts ? l.kindCreditCount(f.num(k.credit)) : l.kindCredit),
  ];
}

/// Small token-coloured chips that say what kind of invoices a customer has: installment on the secondary
/// container, credit on the tertiary container (design guide §5.2). Read as one phrase by TalkBack.
class InvoiceKindLabel extends ConsumerWidget {
  const InvoiceKindLabel({super.key, required this.kinds, this.counted = false});
  final InvoiceKinds kinds;

  /// Always show counts (the customer page header), even for a single invoice.
  final bool counted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kinds.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelMedium!;
    final parts = invoiceKindTexts(l, ref.watch(fmtProvider), kinds, counted: counted);
    return Semantics(
      label: l.kindLabelA11y(parts.map((p) => p.$2).join(' · ')),
      excludeSemantics: true,
      child: Wrap(
        spacing: Space.s4,
        runSpacing: Space.s4,
        children: [
          for (final (kind, text) in parts)
            DecoratedBox(
              key: ValueKey('kind-${kind.name}'),
              decoration: BoxDecoration(
                color: kind == InvoiceKind.credit ? cs.tertiaryContainer : cs.secondaryContainer,
                borderRadius: Radii.brSm,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s2),
                child: Text(
                  text,
                  style: style.copyWith(color: kind == InvoiceKind.credit ? cs.onTertiaryContainer : cs.onSecondaryContainer, height: 1.2),
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
