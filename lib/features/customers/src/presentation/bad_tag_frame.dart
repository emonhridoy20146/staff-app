import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/tag_mark.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/bad_tag.dart';
import '../domain/customer.dart';

/// What TalkBack says for a customer's mark: "খারাপ ট্যাগ: পলাতক", or "শেষ ভিজিটে পলাতক" when it comes from a visit.
String badTagSemantics(AppLocalizations l, BadTag b) {
  final kind = tagKindLabel(l, b.kind);
  return b.source == BadTagSource.visit ? l.tagVisitA11y(kind) : l.tagA11y(kind);
}

/// The body of a customer row (FR-M-081): with a bad mark it sits in the mark's frame with its chip on the
/// top edge; without one it is the plain padded body. Either way the content starts 16 dp from the row's
/// edges, so names and amounts stay in one column down a list.
class BadTagRowBody extends StatelessWidget {
  const BadTagRowBody({super.key, required this.customer, required this.child, this.vertical = Space.s12});
  final Customer customer;
  final Widget child;

  /// Padding above and below the plain body.
  final double vertical;

  @override
  Widget build(BuildContext context) {
    final bad = customer.badTag;
    if (bad == null) return Padding(padding: EdgeInsets.symmetric(horizontal: Space.s16, vertical: vertical), child: child);
    return TagFrame(
      kind: bad.kind,
      semanticsLabel: badTagSemantics(AppLocalizations.of(context), bad),
      child: Padding(padding: const EdgeInsets.fromLTRB(Space.s8, Space.s4 + 2, Space.s8, Space.s12), child: child),
    );
  }
}
