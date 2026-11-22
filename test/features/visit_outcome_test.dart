import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/visits/visits.dart';
import 'package:staff_app/features/visits/src/visits.dart' show visitOutcomes;
import 'package:staff_app/l10n/app_localizations.dart';

/// FR-M-064: visit outcomes follow the contract's `VisitOutcome` enum,
/// including `runaway` (পলাতক, field-api contract 1.41.0).
void main() {
  final bn = lookupAppLocalizations(const Locale('bn'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('runaway is offered in the picker, before the catch-all', () {
    expect(visitOutcomes, contains('runaway'));
    expect(visitOutcomes.last, 'other');
    expect(visitOutcomes.toSet().length, visitOutcomes.length);
  });

  test('runaway has its own label in bn and en', () {
    expect(outcomeLabel(bn, 'runaway'), 'পলাতক');
    expect(outcomeLabel(en, 'runaway'), 'Runaway');
  });

  test('runaway has its own icon', () {
    expect(outcomeIcon('runaway'), Icons.directions_run_rounded);
    expect(outcomeIcon('runaway'), isNot(outcomeIcon('other')));
  });

  test('every picker outcome except other has its own label and icon', () {
    for (final o in visitOutcomes.where((o) => o != 'other')) {
      expect(outcomeLabel(en, o), isNot(en.visitOutcomeOther), reason: o);
      expect(outcomeLabel(bn, o), isNot(bn.visitOutcomeOther), reason: o);
      expect(outcomeIcon(o), isNot(outcomeIcon('other')), reason: o);
    }
  });
}
