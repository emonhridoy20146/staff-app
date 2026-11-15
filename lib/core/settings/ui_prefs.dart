import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../format/amount_in_words.dart';
import '../format/dates.dart';
import '../format/digits.dart';
import '../format/money.dart';
import '../providers.dart';

/// Per-device UI preferences (Settings screen). Persisted in `kv_settings`.
@immutable
class UiPrefs {
  const UiPrefs({this.language = 'bn', this.digits = DigitStyle.bangla, this.themeMode = ThemeMode.light, this.highContrast = false});

  final String language;
  final DigitStyle digits;
  final ThemeMode themeMode;
  final bool highContrast;

  UiPrefs copyWith({String? language, DigitStyle? digits, ThemeMode? themeMode, bool? highContrast}) => UiPrefs(
        language: language ?? this.language,
        digits: digits ?? this.digits,
        themeMode: themeMode ?? this.themeMode,
        highContrast: highContrast ?? this.highContrast,
      );

  Map<String, dynamic> toJson() => {'language': language, 'digits': digits.name, 'themeMode': themeMode.name, 'highContrast': highContrast};

  factory UiPrefs.fromJson(Map<String, dynamic> j) => UiPrefs(
        language: (j['language'] as String?) ?? 'bn',
        digits: DigitStyle.values.firstWhere((d) => d.name == j['digits'], orElse: () => DigitStyle.bangla),
        themeMode: ThemeMode.values.firstWhere((d) => d.name == j['themeMode'], orElse: () => ThemeMode.light),
        highContrast: (j['highContrast'] as bool?) ?? false,
      );
}

class UiPrefsController extends Notifier<UiPrefs> {
  @override
  UiPrefs build() => const UiPrefs();

  Future<void> load() async {
    final raw = await ref.read(databaseProvider).kvGet('ui_prefs');
    if (raw != null) state = UiPrefs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    ref.read(languageCodeProvider.notifier).state = state.language;
  }

  Future<void> update(UiPrefs p) async {
    state = p;
    ref.read(languageCodeProvider.notifier).state = p.language;
    await ref.read(databaseProvider).kvSet('ui_prefs', jsonEncode(p.toJson()));
  }
}

final uiPrefsProvider = NotifierProvider<UiPrefsController, UiPrefs>(UiPrefsController.new);

/// Formatting bound to the user's language and digit style. The only way
/// presentation code formats money, digits, dates and distances.
class Fmt {
  const Fmt(this.lang, this.digits);
  final String lang;
  final DigitStyle digits;

  String money(int poisha) => formatMoney(poisha, digits: digits);
  String num(Object n) => localizeDigits('$n', digits);
  String words(int poisha) => amountInWords(poisha, lang);
  String date(String ymd, {bool withYear = false}) {
    final s = formatBusinessDate(ymd, lang, withYear: withYear);
    return digits == DigitStyle.latin ? toLatinDigits(s) : s;
  }

  String time(DateTime utc) => formatTimeDhaka(utc, digits);
  String dateTime(DateTime utc) {
    final s = formatDateTimeDhaka(utc, lang, digits);
    return digits == DigitStyle.latin ? toLatinDigits(s) : s;
  }

  String duration(Duration d) => formatDurationShort(d, lang, digits);
  String distance(int m) => formatDistance(m, lang, digits);
}

final fmtProvider = Provider<Fmt>((ref) {
  final p = ref.watch(uiPrefsProvider);
  return Fmt(p.language, p.digits);
});
