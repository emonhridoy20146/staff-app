import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/theme/tag_colors.dart';
import 'package:staff_app/features/customers/src/domain/bad_tag.dart';

/// FR-M-081: which customers are marked bad, and how. Pure rule; the rows, the Home filter and the tag sheet
/// all read it.
void main() {
  final t0 = DateTime.utc(2026, 11, 10, 6);

  group('tagKindOf (a set tag)', () {
    test('only a set tag counts: none and pending are not marked', () {
      expect(tagKindOf(state: 'none', severity: 'bad', reasonCode: 'absconded'), isNull);
      expect(tagKindOf(state: 'pending', severity: 'bad', reasonCode: 'absconded'), isNull);
      expect(tagKindOf(state: null, severity: 'bad', reasonCode: 'absconded'), isNull);
    });

    test('severity watch is not a bad tag', () {
      for (final code in ['absconded', 'refused_to_pay', 'other', null]) {
        expect(tagKindOf(state: 'tagged', severity: 'watch', reasonCode: code), isNull, reason: '$code');
      }
    });

    test('each reason of the contract has its own kind', () {
      const kinds = {
        'absconded': TagKind.absconded,
        'refused_to_pay': TagKind.refusedToPay,
        'fraud_suspected': TagKind.fraudSuspected,
        'repeated_broken_promise': TagKind.brokenPromise,
        'plan_ended_unpaid': TagKind.planEndedUnpaid,
        'other': TagKind.other,
      };
      for (final e in kinds.entries) {
        expect(tagKindOf(state: 'tagged', severity: 'bad', reasonCode: e.key), e.value, reason: e.key);
      }
      expect(kinds.values.toSet().length, kinds.length);
    });

    test('a reason code this app does not know, or none, is the generic bad kind', () {
      expect(tagKindOf(state: 'tagged', severity: 'bad', reasonCode: 'long_overdue'), TagKind.other);
      expect(tagKindOf(state: 'tagged', severity: 'bad', reasonCode: 'something_new_in_1_60'), TagKind.other);
      expect(tagKindOf(state: 'tagged', severity: 'bad', reasonCode: null), TagKind.other);
      expect(tagKindOf(state: 'tagged', severity: 'bad', reasonCode: ''), TagKind.other);
    });

    test('legal severity has its own kind whatever the reason, except absconded, which is the strongest', () {
      for (final code in ['refused_to_pay', 'fraud_suspected', 'repeated_broken_promise', 'plan_ended_unpaid', 'other', null, 'unknown_code']) {
        expect(tagKindOf(state: 'tagged', severity: 'legal', reasonCode: code), TagKind.legal, reason: '$code');
      }
      expect(tagKindOf(state: 'tagged', severity: 'legal', reasonCode: 'absconded'), TagKind.absconded);
    });

    test('a set tag without a severity, or with one this app does not know, counts as bad', () {
      expect(tagKindOf(state: 'tagged', severity: null, reasonCode: 'refused_to_pay'), TagKind.refusedToPay);
      expect(tagKindOf(state: 'tagged', severity: 'severe', reasonCode: null), TagKind.other);
    });
  });

  group('runawayStands (the latest visit says runaway)', () {
    test('a runaway visit that is the latest contact stands', () {
      expect(runawayStands(lastVisitOutcome: 'runaway', lastVisitAt: t0, lastContactAt: t0), isTrue);
      expect(runawayStands(lastVisitOutcome: 'runaway', lastVisitAt: t0, lastContactAt: null), isTrue);
      // The customer row's time may be a little off the visit's (seconds, another clock).
      expect(runawayStands(lastVisitOutcome: 'runaway', lastVisitAt: t0, lastContactAt: t0.add(const Duration(seconds: 59))), isTrue);
      // An older contact than the visit changes nothing.
      expect(runawayStands(lastVisitOutcome: 'runaway', lastVisitAt: t0, lastContactAt: t0.subtract(const Duration(days: 3))), isTrue);
    });

    test('any other latest outcome, or no visit, does not', () {
      for (final o in ['paid', 'not_home', 'refused', 'other', 'something_new', null]) {
        expect(runawayStands(lastVisitOutcome: o, lastVisitAt: t0, lastContactAt: t0), isFalse, reason: '$o');
      }
      expect(runawayStands(lastVisitOutcome: 'runaway', lastVisitAt: null, lastContactAt: null), isFalse);
    });

    test('a later contact (a visit the phone does not hold, or a collection) clears it', () {
      expect(runawayStands(lastVisitOutcome: 'runaway', lastVisitAt: t0, lastContactAt: t0.add(const Duration(minutes: 2))), isFalse);
      expect(runawayStands(lastVisitOutcome: 'runaway', lastVisitAt: t0, lastContactAt: t0.add(const Duration(days: 1))), isFalse);
    });
  });

  group('badTagOf (what the row shows)', () {
    BadTag? of({String? state = 'none', String? severity, String? code, String? visit, DateTime? visitAt, DateTime? contactAt}) =>
        badTagOf(tagState: state, tagSeverity: severity, tagReasonCode: code, lastVisitOutcome: visit, lastVisitAt: visitAt, lastContactAt: contactAt);

    test('nothing for an ordinary customer', () {
      expect(of(), isNull);
      expect(of(visit: 'paid', visitAt: t0, contactAt: t0), isNull);
    });

    test('a bad tag shows its kind and says it is a tag', () {
      final b = of(state: 'tagged', severity: 'bad', code: 'fraud_suspected')!;
      expect(b.kind, TagKind.fraudSuspected);
      expect(b.source, BadTagSource.tag);
    });

    test('a customer whose latest visit says runaway shows as absconded, tagged or not', () {
      final untagged = of(visit: 'runaway', visitAt: t0, contactAt: t0)!;
      expect(untagged.kind, TagKind.absconded);
      expect(untagged.source, BadTagSource.visit);
      // On a watch tag too: the visit is what marks it.
      expect(of(state: 'tagged', severity: 'watch', code: 'other', visit: 'runaway', visitAt: t0, contactAt: t0)!.source, BadTagSource.visit);
    });

    test('runaway from a visit is stronger than any reason and than legal; an absconded tag stays a tag', () {
      expect(of(state: 'tagged', severity: 'bad', code: 'refused_to_pay', visit: 'runaway', visitAt: t0, contactAt: t0)!.kind, TagKind.absconded);
      expect(of(state: 'tagged', severity: 'legal', code: 'other', visit: 'runaway', visitAt: t0, contactAt: t0)!.kind, TagKind.absconded);
      final tagged = of(state: 'tagged', severity: 'bad', code: 'absconded', visit: 'runaway', visitAt: t0, contactAt: t0)!;
      expect(tagged.kind, TagKind.absconded);
      expect(tagged.source, BadTagSource.tag);
    });

    test('once a later contact clears the runaway visit, the tag shows again (or nothing)', () {
      final later = t0.add(const Duration(hours: 5));
      expect(of(state: 'tagged', severity: 'bad', code: 'refused_to_pay', visit: 'runaway', visitAt: t0, contactAt: later)!.kind, TagKind.refusedToPay);
      expect(of(visit: 'runaway', visitAt: t0, contactAt: later), isNull);
    });
  });

  group('tagKindForChoice (the tag sheet preview)', () {
    test('what the row will show for a severity and a reason', () {
      expect(tagKindForChoice(severity: 'bad', reasonCode: 'plan_ended_unpaid'), TagKind.planEndedUnpaid);
      expect(tagKindForChoice(severity: 'legal', reasonCode: 'plan_ended_unpaid'), TagKind.legal);
      expect(tagKindForChoice(severity: 'legal', reasonCode: 'absconded'), TagKind.absconded);
      expect(tagKindForChoice(severity: 'watch', reasonCode: 'absconded'), isNull);
    });

    test('every reason option has its own swatch', () {
      const reasons = ['plan_ended_unpaid', 'repeated_broken_promise', 'absconded', 'refused_to_pay', 'fraud_suspected', 'other'];
      expect({for (final r in reasons) tagKindForReason(r)}.length, reasons.length);
      expect(tagKindForReason('other'), TagKind.other);
      expect(tagKindForReason('never_heard_of_it'), TagKind.other);
    });
  });
}
