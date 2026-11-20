import '../time/clock.dart';
import 'digits.dart';

const _bnMonths = [
  'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', //
  'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
];
const _enMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];

String _two(int v) => v.toString().padLeft(2, '0');

/// `১৫ নভেম্বর` / `15 Nov` for a business date.
String formatBusinessDate(String ymd, String lang, {bool withYear = false}) {
  final d = parseBusinessDate(ymd);
  return _formatDay(d, lang, withYear: withYear);
}

String _formatDay(DateTime d, String lang, {bool withYear = false}) {
  if (lang == 'bn') {
    final s = '${d.day} ${_bnMonths[d.month - 1]}${withYear ? ' ${d.year}' : ''}';
    return toBanglaDigits(s);
  }
  return '${d.day} ${_enMonths[d.month - 1]}${withYear ? ' ${d.year}' : ''}';
}

/// `নভেম্বর ২০২৬` / `Nov 2026` for a month `2026-11`.
String formatMonth(String ym, String lang) {
  final p = ym.split('-').map(int.parse).toList();
  return lang == 'bn' ? toBanglaDigits('${_bnMonths[p[1] - 1]} ${p[0]}') : '${_enMonths[p[1] - 1]} ${p[0]}';
}

/// `9:08 AM` (12 h, Dhaka) from a UTC instant.
String formatTimeDhaka(DateTime utc, DigitStyle digits) {
  final d = toDhaka(utc);
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${localizeDigits('$h:${_two(d.minute)}', digits)} ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// `১৫ নভেম্বর, ১০:৪২` from a UTC instant.
String formatDateTimeDhaka(DateTime utc, String lang, DigitStyle digits) {
  final d = toDhaka(utc);
  final day = _formatDay(d, lang);
  return '$day, ${formatTimeDhaka(utc, digits)}';
}

/// Duration like `১ ঘ ২০ মি` / `1h 20m`.
String formatDurationShort(Duration d, String lang, DigitStyle digits) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = lang == 'bn'
      ? (h > 0 ? '$h ঘ $m মি' : '$m মি')
      : (h > 0 ? '${h}h ${m}m' : '${m}m');
  return localizeDigits(s, digits);
}

/// A count of days as a span people can read (FR-M-039): its two largest
/// units of years, months and days. 20 → `২০ দিন` / `20 days`; 45 →
/// `১ মাস ১৫ দিন`; 584 → `১ বছর ৭ মাস`. A month is 30 days and a year 365
/// here (the count has no start date): it says how long, it is never used to
/// work out a date.
String formatDaySpan(int days, String lang, DigitStyle digits) {
  final total = days < 0 ? 0 : days;
  final y = total ~/ 365;
  final m = (total % 365) ~/ 30;
  final d = (total % 365) % 30;
  final bn = lang == 'bn';
  String unit(int n, String one, String many, String bnWord) => '$n ${bn ? bnWord : (n == 1 ? one : many)}';
  final parts = [
    if (y > 0) unit(y, 'year', 'years', 'বছর'),
    if (m > 0) unit(m, 'month', 'months', 'মাস'),
    if (d > 0) unit(d, 'day', 'days', 'দিন'),
  ];
  return localizeDigits(parts.isEmpty ? unit(0, 'day', 'days', 'দিন') : parts.take(2).join(' '), digits);
}

/// Distance like `৪৮০ মি` / `1.2 কিমি`.
String formatDistance(int meters, String lang, DigitStyle digits) {
  final s = meters < 1000
      ? '$meters ${lang == 'bn' ? 'মি' : 'm'}'
      : '${(meters / 1000).toStringAsFixed(1)} ${lang == 'bn' ? 'কিমি' : 'km'}';
  return localizeDigits(s, digits);
}
