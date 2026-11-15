/// Build-time configuration from `--dart-define-from-file` (.env.example
/// lists the names). No secrets are compiled into the repo.
enum AppEnvironment { dev, staging, prod, demo }

enum ApiMode { live, demo }

class Env {
  const Env({required this.environment, required this.apiBaseUrl, required this.apiMode, this.devTools = false});

  factory Env.fromDefines() {
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'demo');
    const base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:4000/api/v1');
    const mode = String.fromEnvironment('API_MODE', defaultValue: '');
    const tools = bool.fromEnvironment('FEATURE_DEV_TOOLS');
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

  final AppEnvironment environment;
  final String apiBaseUrl;
  final ApiMode apiMode;
  final bool devTools;

  bool get isDemo => apiMode == ApiMode.demo;
}
