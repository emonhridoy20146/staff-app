import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/core/api/api_models.dart';
import 'package:staff_app/core/api/field_api.dart';
import 'package:staff_app/core/format/digits.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/core/settings/ui_prefs.dart';
import 'package:staff_app/core/sync/outbox.dart';
import 'package:staff_app/core/time/clock.dart';
import 'package:staff_app/core/ui/common.dart';
import 'package:staff_app/features/auth/src/auth_screens.dart' show loginFailureText;
import 'package:staff_app/features/auth/src/session_controller.dart';
import 'package:staff_app/l10n/app_localizations.dart';

import '../flows/helpers.dart';

/// Owner report 2026-11-24: three different refusals at login used to read "Account locked".
void main() {
  ApiException problem(int status, String code, [Json? details]) => ApiException(
        statusCode: status,
        problem: Problem(status: status, code: code, title: code, details: details),
      );

  group('LoginFailure.fromApi reads the problem code', () {
    test('403 DEVICE_NOT_APPROVED → a new phone waiting for the office', () {
      expect(LoginFailure.fromApi(problem(403, 'DEVICE_NOT_APPROVED')).error, LoginError.deviceNotApproved);
    });

    test('423 ACCOUNT_LOCKED → locked, with details.until as UTC', () {
      final f = LoginFailure.fromApi(problem(423, 'ACCOUNT_LOCKED', {'until': '2026-11-15T10:30:00+06:00'}));
      expect(f.error, LoginError.locked);
      expect(f.until, DateTime.utc(2026, 11, 15, 4, 30));
    });

    test('contract 1.47.0: scope ip is a network lock; retryAfterSec gives the time when until is missing', () {
      final ip = LoginFailure.fromApi(problem(423, 'ACCOUNT_LOCKED', {'until': '2026-11-15T04:30:00Z', 'retryAfterSec': 1800, 'scope': 'ip'}));
      expect(ip.networkLock, isTrue);
      expect(ip.until, DateTime.utc(2026, 11, 15, 4, 30));
      expect(LoginFailure.fromApi(problem(423, 'ACCOUNT_LOCKED', {'until': '2026-11-15T04:30:00Z', 'scope': 'account'})).networkLock, isFalse);
      final byRetry = LoginFailure.fromApi(problem(423, 'ACCOUNT_LOCKED', {'retryAfterSec': 900}), now: testNow);
      expect(byRetry.until, testNow.add(const Duration(minutes: 15)));
    });

    test('contract 1.47.0: DEVICE_NOT_APPROVED carries the pending request id', () {
      final f = LoginFailure.fromApi(
        problem(403, 'DEVICE_NOT_APPROVED', {'pendingDeviceId': 'dev_123', 'deviceId': 'x', 'status': 'pending_approval', 'maxActiveDevices': 2}),
      );
      expect(f.requestId, 'dev_123');
      expect(LoginFailure.fromApi(problem(403, 'DEVICE_NOT_APPROVED')).requestId, isNull);
    });

    test('a lock without (or with a broken) until has no time', () {
      expect(LoginFailure.fromApi(problem(423, 'ACCOUNT_LOCKED')).until, isNull);
      expect(LoginFailure.fromApi(problem(423, 'ACCOUNT_LOCKED', {'until': 'soon'})).until, isNull);
      expect(LoginFailure.fromApi(ApiException(statusCode: 423)).error, LoginError.locked);
    });

    test('any other 403 keeps its code', () {
      final f = LoginFailure.fromApi(problem(403, 'USER_INACTIVE'));
      expect(f.error, LoginError.forbidden);
      expect(f.code, 'USER_INACTIVE');
      expect(LoginFailure.fromApi(ApiException(statusCode: 403)).code, 'HTTP_403');
    });

    test('401, network and the rest are unchanged', () {
      expect(LoginFailure.fromApi(problem(401, 'INVALID_CREDENTIALS')).error, LoginError.invalid);
      expect(LoginFailure.fromApi(ApiException(isNetwork: true)).error, LoginError.network);
      expect(LoginFailure.fromApi(problem(400, 'VALIDATION_FAILED')).error, LoginError.other);
    });
  });

  group('words, bn and en', () {
    final clock = FixedClock(testNow); // 10:00 Dhaka, 15 Nov 2026
    final bn = lookupAppLocalizations(const Locale('bn'));
    final en = lookupAppLocalizations(const Locale('en'));
    const bnFmt = Fmt('bn', DigitStyle.bangla);
    const enFmt = Fmt('en', DigitStyle.latin);
    String text(LoginFailure f, AppLocalizations l, Fmt fmt) => loginFailureText(f, l, fmt, clock);

    test('device not approved', () {
      const f = LoginFailure(LoginError.deviceNotApproved);
      expect(text(f, bn, bnFmt), 'এই ফোনটি নতুন। অনুমোদনের অনুরোধ অফিসে পাঠানো হয়েছে। ম্যানেজার অনুমোদন দিলে আবার লগইন করুন।');
      expect(text(f, en, enFmt), startsWith('This phone is new.'));
      expect(bn.loginRetry, 'আবার চেষ্টা');
      expect(en.loginRetry, 'Try again');
    });

    test('locked: the unlock time in Dhaka time; a date when it is not today', () {
      final today = LoginFailure(LoginError.locked, until: DateTime.utc(2026, 11, 15, 4, 30));
      expect(text(today, bn, bnFmt), 'অনেকবার ভুল পাসওয়ার্ড। ১০:৩০ AM এর পর আবার চেষ্টা করুন।');
      expect(text(today, en, enFmt), 'Too many wrong passwords. Try again after 10:30 AM.');
      // 19:00 UTC on the 15th is 01:00 on the 16th in Dhaka (midnight boundary).
      final tomorrow = LoginFailure(LoginError.locked, until: DateTime.utc(2026, 11, 15, 19));
      expect(text(tomorrow, en, enFmt), 'Too many wrong passwords. Try again after 16 Nov, 1:00 AM.');
      expect(text(tomorrow, bn, bnFmt), contains('১৬ নভেম্বর, ১:০০ AM'));
      expect(text(const LoginFailure(LoginError.locked), bn, bnFmt), 'অনেকবার ভুল পাসওয়ার্ড। কিছুক্ষণ পর আবার চেষ্টা করুন।');
      expect(text(const LoginFailure(LoginError.locked), en, enFmt), 'Too many wrong passwords. Try again a little later.');
    });

    test('network lock (scope ip) names the network, not the account', () {
      final f = LoginFailure(LoginError.locked, until: DateTime.utc(2026, 11, 15, 4, 30), networkLock: true);
      expect(text(f, bn, bnFmt), 'এই নেটওয়ার্ক থেকে অনেকবার ভুল চেষ্টা হয়েছে। ১০:৩০ AM এর পর আবার চেষ্টা করুন।');
      expect(text(f, en, enFmt), 'Too many wrong attempts from this network. Try again after 10:30 AM.');
      const noTime = LoginFailure(LoginError.locked, networkLock: true);
      expect(text(noTime, bn, bnFmt), contains('এই নেটওয়ার্ক থেকে'));
      expect(text(noTime, en, enFmt), 'Too many wrong attempts from this network. Try again a little later.');
    });

    test('another user\'s unsynced data says what to do', () {
      const f = LoginFailure(LoginError.otherUserUnsynced);
      expect(text(f, bn, bnFmt), contains('আগের ব্যবহারকারীকে'));
      expect(text(f, en, enFmt), contains('Ask that user to sign in on this phone'));
    });

    test('other 403 shows the code', () {
      const f = LoginFailure(LoginError.forbidden, code: 'USER_INACTIVE');
      expect(text(f, bn, bnFmt), contains('USER_INACTIVE'));
      expect(text(f, en, enFmt), "Can't sign in (code: USER_INACTIVE). Tell your branch manager this code.");
    });

    test('nothing reads "Account locked" any more', () {
      for (final e in LoginError.values) {
        expect(text(LoginFailure(e), en, enFmt), isNot(contains('Account locked')));
      }
    });
  });

  test('another user with unsynced data on the phone: its own error, nothing deleted', () async {
    final h = Harness(extra: [outboxReaderProvider.overrideWith((ref) => _Unsynced(ref.watch(databaseProvider)))]);
    await h.read(sessionProvider.notifier).restore();
    await h.read(secureStoreProvider).write('locked_user_id', 'someone-else');
    await expectLater(
      h.read(sessionProvider.notifier).login('01712345678', 'demo1234'),
      throwsA(isA<LoginFailure>().having((f) => f.error, 'error', LoginError.otherUserUnsynced)),
    );
    expect(await h.read(secureStoreProvider).read('locked_user_id'), 'someone-else');
    await h.dispose();
  });

  for (final lang in ['bn', 'en']) {
    testWidgets(timeout: const Timeout(Duration(seconds: 60)), 'login screen ($lang): a new phone is an info state; "try again" signs in once approved', (t) async {
      final h = Harness();
      t.view.physicalSize = const Size(412, 2400) * 2;
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      await t.runAsync(() async {
        await h.read(uiPrefsProvider.notifier).update(UiPrefs(language: lang));
        await h.read(sessionProvider.notifier).restore();
      });
      h.api.loginRefusal = (
        status: 403,
        body: {
          'status': 403,
          'code': 'DEVICE_NOT_APPROVED',
          'title': 'Device not approved',
          'details': {'pendingDeviceId': 'dev_77', 'deviceId': 'x', 'status': 'pending_approval'},
        },
      );
      Future<void> settle() async {
        for (var i = 0; i < 6; i++) {
          await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
          await t.pump(const Duration(milliseconds: 100));
        }
      }

      await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
      await settle();
      await t.enterText(find.byType(TextField).at(0), '01712345678');
      await t.enterText(find.byType(TextField).at(1), 'demo1234');
      await t.tap(find.text(lang == 'bn' ? 'লগইন করুন' : 'Sign in').last);
      await settle();
      final l = lookupAppLocalizations(Locale(lang));
      final banner = t.widget<InfoBanner>(find.byKey(const ValueKey('login-failure')));
      expect(banner.text, l.loginDeviceNotApproved);
      expect(banner.tone, BannerTone.info);
      expect(find.text(l.loginDeviceRequestId('dev_77')), findsOneWidget);
      final retry = find.text(l.loginRetry);
      expect(retry, findsOneWidget);
      expect(t.getSize(find.ancestor(of: retry, matching: find.byType(OutlinedButton))).height, greaterThanOrEqualTo(48));

      // The office approved: "try again" signs in.
      h.api.loginRefusal = null;
      await t.tap(retry);
      await settle();
      expect(find.byKey(const ValueKey('login-failure')), findsNothing);
      expect(h.read(sessionProvider).user, isNotNull);

      await _close(t, h);
    });
  }

  testWidgets(timeout: const Timeout(Duration(seconds: 60)), 'login screen: a lock shows the time as a danger banner', (t) async {
    final h = Harness();
    t.view.physicalSize = const Size(412, 2400) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.runAsync(() async {
      await h.read(uiPrefsProvider.notifier).update(const UiPrefs(language: 'en'));
      await h.read(sessionProvider.notifier).restore();
    });
    h.api.loginRefusal = (
      status: 423,
      body: {'status': 423, 'code': 'ACCOUNT_LOCKED', 'title': 'Locked', 'details': {'until': '2026-11-15T04:30:00Z'}},
    );
    Future<void> settle() async {
      for (var i = 0; i < 6; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle();
    await t.enterText(find.byType(TextField).at(0), '01712345678');
    await t.enterText(find.byType(TextField).at(1), 'demo1234');
    await t.tap(find.text('Sign in').last);
    await settle();
    final banner = t.widget<InfoBanner>(find.byKey(const ValueKey('login-failure')));
    expect(banner.text, 'Too many wrong passwords. Try again after 10:30 AM.');
    expect(banner.tone, BannerTone.danger);
    expect(find.text('Try again'), findsNothing);
    await _close(t, h);
  });
}

/// Unmount first and dispose the container, so no drift stream query started by a widget (in the fake-async zone)
/// is still waiting on a fake timer; only then close the database for real. Closing it while widgets still watch
/// it waited forever on those queries (the hang seen while writing this test).
Future<void> _close(WidgetTester t, Harness h) async {
  final db = h.read(databaseProvider);
  await t.pumpWidget(const SizedBox.shrink());
  h.container.dispose();
  await t.pump(const Duration(milliseconds: 50));
  await t.runAsync(db.close);
}

class _Unsynced extends OutboxReader {
  _Unsynced(super.db);
  @override
  Future<int> unsyncedCount() async => 3;
}
