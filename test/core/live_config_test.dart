import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/config/env.dart';

/// Guards the committed build configs (ADR-M16): `config/*.env` holds public,
/// non-secret values only, points at field-api over HTTPS (never at the ERP),
/// and every Android Studio run configuration in `.run/` uses a file that
/// exists.
/// Same reading as `flutter --dart-define-from-file` for these simple files:
/// blank and `#` lines are skipped, everything else must be KEY=value.
({Map<String, String> values, List<String> invalid}) _parseEnvFile(File f) {
  final values = <String, String>{};
  final invalid = <String>[];
  for (final raw in f.readAsLinesSync()) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final i = line.indexOf('=');
    if (i <= 0) {
      invalid.add(line);
      continue;
    }
    values[line.substring(0, i).trim()] = line.substring(i + 1).trim();
  }
  return (values: values, invalid: invalid);
}

void main() {
  final configs = Directory('config').listSync().whereType<File>().where((f) => f.path.endsWith('.env')).toList();

  test('there is a committed live config', () {
    expect(configs.map((f) => f.uri.pathSegments.last), contains('live.env'));
  });

  for (final f in configs) {
    group(f.path, () {
      final parsed = _parseEnvFile(f);
      final values = parsed.values;

      test('every line is KEY=value', () {
        expect(parsed.invalid, isEmpty);
      });

      test('only public keys, nothing that looks like a secret', () {
        const allowed = {'APP_ENV', 'API_BASE_URL', 'API_MODE'};
        expect(values.keys.toSet().difference(allowed), isEmpty, reason: 'secrets belong in git-ignored .env.* files or CI secrets');
        final text = f.readAsStringSync().split('\n').where((l) => !l.trimLeft().startsWith('#')).join('\n');
        expect(RegExp(r'token|secret|password|passwd|bearer|dsn|license|licence|key=', caseSensitive: false).hasMatch(text), isFalse);
      });

      test('talks to field-api over HTTPS, never to the ERP', () {
        final url = Uri.parse(values['API_BASE_URL'] ?? '');
        expect(url.scheme, 'https');
        expect(url.host, isNotEmpty);
        expect(url.path, endsWith('/api/v1'));
        expect(url.userInfo, isEmpty);
        expect(url.hasQuery, isFalse);
        // The ERP (Laravel) has its own prototype API under /api/field/v1 on
        // howladerelectronics.com; the app must never call it.
        expect(url.path, isNot(contains('/api/field/')));
        expect(url.host, isNot(anyOf('howladerelectronics.com', 'www.howladerelectronics.com')));
      });

      test('builds a live Env', () {
        final env = Env.fromValues(values);
        expect(env.apiMode, ApiMode.live);
        expect(env.isDemo, isFalse);
        expect(env.devTools, isFalse);
        expect(env.apiBaseUrl, values['API_BASE_URL']);
      });
    });
  }

  test('every .run configuration points at an existing config file and lib/main.dart', () {
    final runs = Directory('.run').listSync().whereType<File>().where((f) => f.path.endsWith('.run.xml')).toList();
    expect(runs, isNotEmpty);
    for (final r in runs) {
      final xml = r.readAsStringSync();
      expect(xml, contains(r'value="$PROJECT_DIR$/lib/main.dart"'), reason: r.path);
      for (final m in RegExp(r'--dart-define-from-file=(\S+?)["\s]').allMatches(xml)) {
        expect(File(m.group(1)!).existsSync(), isTrue, reason: '${r.path} uses missing ${m.group(1)}');
      }
    }
  });

  test('Android does not allow cleartext HTTP', () {
    for (final path in ['android/app/src/main/AndroidManifest.xml', 'android/app/src/debug/AndroidManifest.xml', 'android/app/src/profile/AndroidManifest.xml']) {
      final f = File(path);
      if (!f.existsSync()) continue;
      expect(f.readAsStringSync(), isNot(contains('usesCleartextTraffic="true"')), reason: path);
    }
  });

  test('Env.fromValues keeps the fromDefines rules', () {
    expect(Env.fromValues(const {}).isDemo, isTrue);
    expect(Env.fromValues(const {'APP_ENV': 'staging'}).apiMode, ApiMode.live);
    expect(Env.fromValues(const {'APP_ENV': 'dev', 'API_MODE': 'demo'}).isDemo, isTrue);
    expect(Env.fromValues(const {'APP_ENV': 'prod', 'FEATURE_DEV_TOOLS': 'true'}).devTools, isFalse);
    expect(Env.fromValues(const {'APP_ENV': 'staging', 'FEATURE_DEV_TOOLS': 'true'}).devTools, isTrue);
    expect(() => Env.fromValues(const {'APP_ENV': 'prod', 'API_MODE': 'demo'}), throwsStateError);
  });
}
