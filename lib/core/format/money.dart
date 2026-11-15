import 'digits.dart';

/// Money is always integer poisha (1 taka = 100 poisha). Never use doubles.
typedef Poisha = int;

/// South-Asian grouping: 12,50,500 (last 3 digits, then groups of 2).
String groupSouthAsian(int value) {
  final neg = value < 0;
  final s = value.abs().toString();
  if (s.length <= 3) return neg ? '-$s' : s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  final out = '${parts.join(',')},$last3';
  return neg ? '-$out' : out;
}

/// Formats poisha as `৳12,500` (or `৳12,500.50` when poisha part is non-zero).
String formatMoney(
  Poisha poisha, {
  DigitStyle digits = DigitStyle.bangla,
  bool symbol = true,
  bool alwaysShowPoisha = false,
}) {
  final neg = poisha < 0;
  final abs = poisha.abs();
  final taka = abs ~/ 100;
  final p = abs % 100;
  var s = groupSouthAsian(taka);
  if (p != 0 || alwaysShowPoisha) s = '$s.${p.toString().padLeft(2, '0')}';
  s = localizeDigits(s, digits);
  return '${neg ? '-' : ''}${symbol ? '৳' : ''}$s';
}

/// Parses keypad input (Bangla or Latin digits, optional decimal) to poisha.
/// Returns null for invalid input.
Poisha? parseMoneyInput(String input) {
  final s = toLatinDigits(input.trim()).replaceAll(',', '');
  if (s.isEmpty) return null;
  final m = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(s);
  if (m == null) return null;
  final taka = int.parse(m.group(1)!);
  final frac = (m.group(2) ?? '').padRight(2, '0');
  return taka * 100 + int.parse(frac);
}
