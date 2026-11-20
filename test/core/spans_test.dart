import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/format/dates.dart';
import 'package:staff_app/core/format/digits.dart';
import 'package:staff_app/core/settings/ui_prefs.dart';

/// FR-M-039: lengths of time people can read: hours and minutes, and
/// years / months / days for a count of days.
void main() {
  test('a count of days shows its two largest units', () {
    String en(int d) => formatDaySpan(d, 'en', DigitStyle.latin);
    String bn(int d) => formatDaySpan(d, 'bn', DigitStyle.bangla);
    expect(en(0), '0 days');
    expect(en(1), '1 day');
    expect(bn(20), '২০ দিন');
    expect(en(30), '1 month');
    expect(bn(45), '১ মাস ১৫ দিন');
    expect(en(364), '12 months 4 days');
    expect(bn(365), '১ বছর');
    expect(bn(584), '১ বছর ৭ মাস');
    expect(en(584), '1 year 7 months');
    expect(en(370), '1 year 5 days');
    expect(en(-3), '0 days');
  });

  test('minutes show as hours and minutes', () {
    const en = Fmt('en', DigitStyle.latin);
    const bn = Fmt('bn', DigitStyle.bangla);
    expect(en.minutes(15), '15m');
    expect(en.minutes(80), '1h 20m');
    expect(bn.minutes(80), '১ ঘ ২০ মি');
    expect(bn.minutes(45), '৪৫ মি');
    expect(en.minutes(-5), '0m');
    expect(bn.daySpan(584), '১ বছর ৭ মাস');
  });
}
