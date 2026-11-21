import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_riverpod/misc.dart' show Override, ProviderListenable;
import 'package:staff_app/app/bootstrap.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/core/api/fake/fake_field_api.dart';
import 'package:staff_app/core/notifications/reminders.dart';
import 'package:staff_app/core/settings/ui_prefs.dart';
import 'package:staff_app/core/time/clock.dart';
import 'package:staff_app/features/auth/auth.dart';
import 'package:staff_app/features/auth/src/session_controller.dart'
    show pinHasherProvider;
import 'package:staff_app/core/auth/pin.dart';
import 'package:staff_app/core/location/gps_status.dart';
import 'package:staff_app/features/onboarding/onboarding.dart';

/// A small camera-like JPEG for selfie / photo tests.
Uint8List testJpeg() =>
    Uint8List.fromList(img.encodeJpg(img.Image(width: 64, height: 48)));

/// 10:00 Dhaka on 15 Nov 2026.
DateTime get testNow => DateTime.utc(2026, 11, 15, 4);

const _geolocatorChannel = MethodChannel('flutter.baseflow.com/geolocator');

void _installGeolocatorMock() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        _geolocatorChannel,
        (call) async => switch (call.method) {
          'isLocationServiceEnabled' => true,
          'checkPermission' || 'requestPermission' => 2,
          _ => throw UnsupportedError(
            'Unexpected Geolocator method in tests: ${call.method}',
          ),
        },
      );
}

class Harness {
  Harness({List<Override> extra = const []})
    : clock = FixedClock(testNow),
      reminders = MemoryReminderScheduler() {
    _installGeolocatorMock();
    api = FakeFieldApi(clock: clock, latency: Duration.zero);
    container = buildTestContainer(
      clock: clock,
      api: api,
      extra: [
        reminderSchedulerProvider.overrideWithValue(reminders),
        gpsStatusStreamProvider.overrideWithValue(const Stream<bool>.empty()),
        permissionRequesterProvider.overrideWithValue(AlwaysGrantRequester()),
        // Fewer PBKDF2 rounds keep tests fast; production uses 60 000.
        pinHasherProvider.overrideWithValue(const PinHasher(iterations: 1000)),
        ...extra,
      ],
    );
  }

  final FixedClock clock;
  final MemoryReminderScheduler reminders;
  late final FakeFieldApi api;
  late final ProviderContainer container;

  T read<T>(ProviderListenable<T> p) => container.read(p);

  /// Full first-run: login → new password → PIN → consent → primer → bootstrap.
  Future<void> signIn() async {
    await container
        .read(uiPrefsProvider.notifier)
        .update(const UiPrefs(language: 'bn'));
    final s = container.read(sessionProvider.notifier);
    await s.restore();
    await s.login('01712345678', 'demo1234');
    await s.changePassword('demo1234', 'newpass123');
    await s.setPin('2580');
    await s.acceptConsent();
    await s.finishPrimer();
    await s.runBootstrap();
  }

  Future<void> dispose() async {
    await container.read(databaseProvider).close();
    container.dispose();
  }
}
