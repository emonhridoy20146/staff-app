import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Asks "close the app?" before the system back gesture leaves the app from
/// its root screen. Wrap the root of the signed-in app in it; screens opened
/// above the root still go back one step as usual, because they sit above
/// this widget's route.
///
/// Additive: it only intercepts the back that would otherwise close the app.
/// Nothing is deleted: work that is not sent yet stays on the phone.
class ExitConfirmScope extends StatelessWidget {
  const ExitConfirmScope({super.key, required this.child, this.onExit});
  final Widget child;

  /// Closes the app. Defaults to the platform's "pop" (tests pass their own).
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await confirmExit(context);
        if (leave) (onExit ?? SystemNavigator.pop).call();
      },
      child: child,
    );
  }
}

/// The "close the app?" dialog. True when the person chose to close.
Future<bool> confirmExit(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final leave = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(l.exitAppTitle),
      content: Text(l.exitAppBody),
      actions: [
        // "Stay" is the safe, focused default.
        FilledButton(autofocus: true, onPressed: () => Navigator.of(d).pop(false), child: Text(l.exitAppStay)),
        TextButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l.exitAppConfirm)),
      ],
    ),
  );
  return leave == true;
}
