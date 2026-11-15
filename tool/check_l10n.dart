// Fails when app_bn.arb and app_en.arb do not have the same keys
// (CLAUDE.md §2.11). Run: dart run tool/check_l10n.dart
import 'dart:convert';
import 'dart:io';

void main() {
  Set<String> keys(String f) =>
      (jsonDecode(File(f).readAsStringSync()) as Map<String, dynamic>).keys.where((k) => !k.startsWith('@')).toSet();
  final en = keys('lib/l10n/app_en.arb');
  final bn = keys('lib/l10n/app_bn.arb');
  final missingBn = en.difference(bn);
  final missingEn = bn.difference(en);
  if (missingBn.isEmpty && missingEn.isEmpty) {
    stdout.writeln('l10n OK: ${en.length} keys in bn and en');
    return;
  }
  if (missingBn.isNotEmpty) stderr.writeln('Missing in app_bn.arb: ${missingBn.join(', ')}');
  if (missingEn.isNotEmpty) stderr.writeln('Missing in app_en.arb: ${missingEn.join(', ')}');
  exitCode = 1;
}
