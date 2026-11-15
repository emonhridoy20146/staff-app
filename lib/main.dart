import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'core/config/env.dart';
import 'core/settings/ui_prefs.dart';
import 'features/auth/auth.dart';

/// Entry point. Flavour comes from `--dart-define-from-file=.env.<flavour>`
/// (`APP_ENV`, `API_BASE_URL`, `API_MODE`); default is the offline demo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = await bootstrap(Env.fromDefines());
  await container.read(uiPrefsProvider.notifier).load();
  await container.read(sessionProvider.notifier).restore();
  unawaited(loadAppConfig(container));
  runApp(UncontrolledProviderScope(container: container, child: const FieldApp()));
}
