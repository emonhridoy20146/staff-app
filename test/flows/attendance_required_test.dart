import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/api/api_models.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/attendance/attendance.dart';

import 'helpers.dart';

/// FR-M-070: a super admin (contract 1.45.0 `attendanceRequired: false`) never sees or is asked for attendance.
void main() {
  test('attendanceRequired is read wherever the server puts it; absent means not said', () {
    expect(attendanceRequiredIn({'attendanceRequired': false}), isFalse);
    expect(attendanceRequiredIn({'user': {'attendanceRequired': false}}), isFalse);
    expect(attendanceRequiredIn({'me': {'attendanceRequired': true}}), isTrue);
    expect(attendanceRequiredIn({'permissions': {'keys': <String>[], 'attendanceRequired': false}}), isFalse);
    expect(attendanceRequiredIn({'user': {'id': 'u'}}), isNull);
  });

  group('session', () {
    late Harness h;
    setUp(() => h = Harness());
    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await h.dispose();
    });

    test('an older server (no field): attendance is required as before', () async {
      await h.signIn();
      expect(h.read(attendanceRequiredProvider), isTrue);
      expect(h.read(attendanceShownProvider), isTrue);
    });

    test('super admin: not shown, kept for the next start, and today is never asked from the server', () async {
      h.api.attendanceRequired = false;
      await h.signIn();
      expect(h.read(attendanceRequiredProvider), isFalse);
      expect(h.read(attendanceShownProvider), isFalse);
      expect(await h.read(databaseProvider).kvGet('attendance_required'), 'false');
      final calls = h.api.meTodayCalls;
      expect(await h.read(attendanceServiceProvider).restoreTodayIfMissing(), 0);
      expect(h.api.meTodayCalls, calls);
    });

    test('the sync snapshot can change it', () async {
      await h.signIn();
      expect(h.read(attendanceShownProvider), isTrue);
      h.api.attendanceRequired = false;
      await h.read(syncEngineProvider).kick(reason: 'test');
      expect(h.read(attendanceShownProvider), isFalse);
    });
  });

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 8; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<Harness> start(WidgetTester t, {bool? required}) async {
    final h = Harness();
    h.api.attendanceRequired = required;
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle(t);
    return h;
  }

  testWidgets('super admin: no duty card or attendance tile on Home, no attendance card in Me, no work-in button', (t) async {
    final h = await start(t, required: false);
    expect(find.byType(DutyCard), findsNothing);
    expect(find.text('উপস্থিতি'), findsNothing); // the Home attendance tile
    h.read(routerProvider).go('/me');
    await settle(t);
    expect(find.byType(AttendanceCard), findsNothing);
    unawaited(h.read(routerProvider).push('/attendance'));
    await settle(t);
    expect(find.text('আপনার অ্যাকাউন্টে হাজিরা দিতে হয় না। এখানে কিছু করার নেই।'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('field staff: the duty card is there as before', (t) async {
    await start(t);
    expect(find.byType(DutyCard), findsOneWidget);
    expect(find.text('উপস্থিতি'), findsWidgets);
  });
}
