/// Build-time configuration from `--dart-define-from-file` (.env.example
/// lists the names). No secrets are compiled into the repo; the committed
/// `config/live.env` holds public values only (ADR-M16).
enum AppEnvironment { dev, staging, prod, demo }

enum ApiMode { live, demo }

class Env {
  const Env({required this.environment, required this.apiBaseUrl, required this.apiMode, this.devTools = false});

  factory Env.fromDefines() {
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'demo');
    const base = String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);
    const mode = String.fromEnvironment('API_MODE', defaultValue: '');
    const tools = bool.fromEnvironment('FEATURE_DEV_TOOLS');
    return Env.fromValues({'APP_ENV': env, 'API_BASE_URL': base, 'API_MODE': mode, 'FEATURE_DEV_TOOLS': '$tools'});
  }

  /// Same rules as [Env.fromDefines] for a map of define names to values
  /// (for example a parsed `config/*.env` file in tests).
  factory Env.fromValues(Map<String, String> values) {
    final env = values['APP_ENV'] ?? 'demo';
    final base = values['API_BASE_URL'] ?? _defaultBaseUrl;
    final mode = values['API_MODE'] ?? '';
    final tools = values['FEATURE_DEV_TOOLS'] == 'true';
    final e = AppEnvironment.values.firstWhere((v) => v.name == env, orElse: () => AppEnvironment.demo);
    final m = mode == 'live'
        ? ApiMode.live
        : mode == 'demo' || e == AppEnvironment.demo
            ? ApiMode.demo
            : ApiMode.live;
    if (e == AppEnvironment.prod && m == ApiMode.demo) {
      throw StateError('Prod build cannot run in demo API mode');
    }
    return Env(environment: e, apiBaseUrl: base, apiMode: m, devTools: tools && e != AppEnvironment.prod);
  }

  static const _defaultBaseUrl = 'http://10.0.2.2:4000/api/v1';

  final AppEnvironment environment;
  final String apiBaseUrl;
  final ApiMode apiMode;
  final bool devTools;

  bool get isDemo => apiMode == ApiMode.demo;
}
