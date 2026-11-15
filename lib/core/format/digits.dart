/// Bangla / Latin digit conversion. All number formatting goes through
/// `core/format` (CLAUDE.md §2.4, design guide §9).
library;

const _bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

/// Converts ASCII digits in [s] to Bangla digits.
String toBanglaDigits(String s) {
  final b = StringBuffer();
  for (final c in s.codeUnits) {
    if (c >= 0x30 && c <= 0x39) {
      b.write(_bn[c - 0x30]);
    } else {
      b.writeCharCode(c);
    }
  }
  return b.toString();
}

/// Converts Bangla digits in [s] to ASCII digits (for parsing input).
String toLatinDigits(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    final i = r - 0x09E6;
    if (i >= 0 && i <= 9) {
      b.writeCharCode(0x30 + i);
    } else {
      b.writeCharCode(r);
    }
  }
  return b.toString();
}

/// Digit style chosen in settings.
enum DigitStyle { bangla, latin }

String localizeDigits(String s, DigitStyle style) =>
    style == DigitStyle.bangla ? toBanglaDigits(s) : s;
