import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/status_colors.dart';
import '../../../../core/ui/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/customer.dart';

/// The "ফেরত পণ্যের customer" marker (FR-M-085, contract 1.53.0): status colour `status.returned` (tokens v1.4),
/// its icon and the label, never colour alone. Every list shows it when the customer has a returned invoice.
class ReturnedCustomerMark extends StatelessWidget {
  const ReturnedCustomerMark({super.key, this.dense = true});
  final bool dense;

  @override
  Widget build(BuildContext context) => StatusBadge(
        AppStatus.returned,
        key: const Key('returned-customer-mark'),
        dense: dense,
        label: AppLocalizations.of(context).returnedCustomerMark,
      );
}

/// A customer row that must not open (FR-M-085): every invoice was returned (`onlyReturned`). The row stays in the
/// list with the marker; TalkBack says why nothing happens on a tap. Any other row is returned as is.
Widget returnedRowSemantics(BuildContext context, Customer customer, Widget row) {
  if (!customer.onlyReturned) return row;
  return Semantics(
    container: true,
    button: false,
    enabled: false,
    label: AppLocalizations.of(context).returnedCustomerOnlyA11y,
    child: row,
  );
}
