import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/core/ui/exit_confirm.dart';
import 'package:staff_app/l10n/app_localizations.dart';

/// Back from the root of the signed-in app asks "close the app?" first (owner request 2026-11-18).
void main() {
  var exits = 0;
  setUp(() => exits = 0);

  Widget app({Locale locale = const Locale('bn')}) => MaterialApp(
        locale: locale,
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => ExitConfirmScope(
            onExit: () => exits++,
            child: Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('detail screen')))),
                  child: const Text('open detail'),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('back at the root shows the question in Bangla; "থাকুন" keeps the app open', (tester) async {
    await tester.pumpWidget(app());
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('অ্যাপ বন্ধ করবেন?'), findsOneWidget);
    expect(find.textContaining('নিরাপদে থাকবে'), findsOneWidget);
    await tester.tap(find.text('থাকুন'));
    await tester.pumpAndSettle();
    expect(find.text('অ্যাপ বন্ধ করবেন?'), findsNothing);
    expect(exits, 0);
    expect(find.text('open detail'), findsOneWidget);
  });

  testWidgets('"অ্যাপ বন্ধ করুন" closes the app, once', (tester) async {
    await tester.pumpWidget(app());
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('অ্যাপ বন্ধ করুন'));
    await tester.pumpAndSettle();
    expect(exits, 1);
  });

  testWidgets('English text, and a second back while the question is open does not close the app', (tester) async {
    await tester.pumpWidget(app(locale: const Locale('en')));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Close the app?'), findsOneWidget);
    // Back on the dialog closes the dialog only.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Close the app?'), findsNothing);
    expect(exits, 0);
  });

  testWidgets('a screen opened above the root goes back one step as usual, with no question', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('open detail'));
    await tester.pumpAndSettle();
    expect(find.text('detail screen'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('detail screen'), findsNothing);
    expect(find.text('অ্যাপ বন্ধ করবেন?'), findsNothing);
    expect(exits, 0);
    // Now at the root: the next back asks.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('অ্যাপ বন্ধ করবেন?'), findsOneWidget);
  });
}
