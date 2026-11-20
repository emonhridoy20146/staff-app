import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Asks the user to confirm work that is being recorded far from the
/// customer's pin (FR-M-043). It never blocks: "record anyway" saves it, and
/// the office sees the distance. Returns true to go on.
Future<bool> confirmFarFromPin(BuildContext context, {required String distance}) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      icon: const Icon(Icons.wrong_location_rounded),
      title: Text(l.farTitle),
      content: Text(l.farBody(distance)),
      actions: [
        TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l.actionBack)),
        FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l.farConfirm)),
      ],
    ),
  );
  return ok == true;
}
