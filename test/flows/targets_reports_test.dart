import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/reports/src/reports_data.dart';
import 'package:staff_app/features/visits/src/visits.dart';

import 'helpers.dart';

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await h.dispose();
  });

  test('my daily target comes with the pull and is kept on the phone for offline use', () async {
    await h.signIn();
    final t = h.read(myTargetProvider)!;
    expect(t.businessDate, h.clock.businessDate());
    expect(t.amountPoisha, 4000000);
    expect(t.visits, 20);
    expect(t.source, 'personal');
    final db = h.read(databaseProvider);
    expect(jsonDecode((await db.kvGet('my_target'))!)['amountPoisha'], 4000000);

    // A day off: the server says so and the targets are 0.
    h.api.workingDay = false;
    await h.read(syncEngineProvider).syncNow();
    expect(h.read(myTargetProvider)!.workingDay, isFalse);
    expect(h.read(myTargetProvider)!.amountPoisha, 0);
  });

  test('visit credit: single visits count 1, co-work visits count the admin weight', () {
    const s = (solo: 2, coWork: 2);
    expect(visitCredit(s, null), 4);
    expect(visitCredit(s, 0.5), 3);
    expect(visitCredit(s, 2), 4, reason: 'weight is clamped to 0–1');
  });

  test('my month: online, then the last answer is shown offline with its time', () async {
    await h.signIn();
    final svc = h.read(reportsServiceProvider);
    final month = monthOf(h.clock.businessDate());
    expect(month, '2026-11');
    var (perf, err) = await svc.myMonth(month);
    expect(err, isNull);
    expect(perf!.days, hasLength(15));
    expect(perf.days.where((d) => !d.workingDay), isNotEmpty, reason: 'Fridays off in the demo');
    expect(perf.collectedPoisha, perf.postedPoisha + perf.pendingPoisha);
    expect(perf.amountAchievement, closeTo(perf.collectedPoisha / perf.targetToDatePoisha, 1e-9));
    expect(perf.rank, 2);

    h.api.offline = true;
    (perf, err) = await svc.myMonth(month);
    expect(err, ReportError.offline);
    expect(perf, isNotNull);
    expect(perf!.fetchedAt, h.clock.nowUtc());

    final (none, err2) = await svc.myMonth(monthOf(h.clock.businessDate(), delta: -1));
    expect(none, isNull);
    expect(err2, ReportError.offline);
  });

  test('leaderboard: ties share a rank, too few days present are not ranked, hidden unless the admin allows it', () async {
    await h.signIn();
    final svc = h.read(reportsServiceProvider);
    final (board, err) = await svc.leaderboard(period: 'month');
    expect(err, isNull);
    expect(board!.ranked.map((r) => r.rank), [1, 2, 2, 4]);
    expect(board.myRank, 2);
    expect(board.of, 4);
    expect(board.ranked.singleWhere((r) => r.me).employeeCode, 'FS014');
    expect(board.unranked.single.employeeCode, 'FS023');

    final (byVisits, _) = await svc.leaderboard(period: 'day', metric: LeaderMetric.visitCredit);
    expect(byVisits!.ranked.first.value, 23.5);

    h.api.leaderboardVisible = false;
    await h.read(syncEngineProvider).syncNow();
    expect(h.read(leaderboardVisibleProvider), isFalse);
    final (hidden, err3) = await svc.leaderboard(period: 'month');
    expect(hidden, isNull);
    expect(err3, ReportError.hidden);
    expect((await svc.myMonth(monthOf(h.clock.businessDate()))).$1!.rank, isNull);
  });

  test('month arithmetic crosses the year', () {
    expect(monthOf('2026-01-15', delta: -1), '2025-12');
    expect(monthOf('2026-12-31', delta: 1), '2027-01');
    expect(monthOf('2026-11-17', delta: -11), '2025-12');
  });
}
