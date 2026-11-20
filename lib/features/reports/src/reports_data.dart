import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_models.dart';
import '../../../core/api/field_api.dart';
import '../../../core/providers.dart';

int _i(Object? v) => ((v as num?) ?? 0).toInt();
double _d(Object? v) => ((v as num?) ?? 0).toDouble();

/// One day of my month (contract 1.10.0).
class PerfDay {
  const PerfDay({required this.date, this.collectedPoisha = 0, this.soloVisits = 0, this.coWorkVisits = 0, this.visitCredit = 0, this.targetPoisha = 0, this.visitTarget = 0, this.workingDay = true});
  factory PerfDay.fromJson(Json j) => PerfDay(
        date: j['date'] as String,
        collectedPoisha: _i(j['collectedPoisha']),
        soloVisits: _i(j['soloVisits']),
        coWorkVisits: _i(j['coWorkVisits']),
        visitCredit: _d(j['visitCredit']),
        targetPoisha: _i(j['targetPoisha']),
        visitTarget: _d(j['visitTarget']),
        workingDay: (j['workingDay'] as bool?) ?? true,
      );
  final String date;
  final int collectedPoisha;
  final int soloVisits;
  final int coWorkVisits;
  final double visitCredit;
  final int targetPoisha;
  final double visitTarget;
  final bool workingDay;
}

/// GET /reports/me/performance (FR-REP-005, FR-M-021).
class MyPerformance {
  const MyPerformance({
    required this.month,
    required this.collectedPoisha,
    required this.postedPoisha,
    required this.pendingPoisha,
    required this.targetPoisha,
    required this.targetToDatePoisha,
    required this.visitTarget,
    required this.visitTargetToDate,
    required this.soloVisits,
    required this.coWorkVisits,
    required this.visitCredit,
    required this.promisesKept,
    required this.promisesDue,
    required this.presentDays,
    required this.lateDays,
    required this.days,
    this.rank,
    this.rankOf,
    this.fetchedAt,
  });

  factory MyPerformance.fromJson(Json j, {DateTime? fetchedAt}) {
    final row = (j['row'] as Json?) ?? const {};
    final rank = j['rank'] as Json?;
    return MyPerformance(
      month: j['month'] as String,
      collectedPoisha: _i(j['collectedTotalPoisha']),
      postedPoisha: _i(j['postedPoisha']),
      pendingPoisha: _i(j['pendingPoisha']),
      targetPoisha: _i(row['targetPoisha']),
      targetToDatePoisha: _i(row['targetToDatePoisha']),
      visitTarget: _d(row['visitTarget']),
      visitTargetToDate: _d(row['visitTargetToDate']),
      soloVisits: _i(row['soloVisits']),
      coWorkVisits: _i(row['coWorkVisits']),
      visitCredit: _d(row['visitCredit']),
      promisesKept: _i(row['promisesKept']),
      promisesDue: _i(row['promisesDue']),
      presentDays: _i(row['presentDays']),
      lateDays: _i(row['lateDays']),
      days: [for (final d in (j['days'] as List?) ?? const []) PerfDay.fromJson(d as Json)],
      rank: (rank?['rank'] as num?)?.toInt(),
      rankOf: (rank?['of'] as num?)?.toInt(),
      fetchedAt: fetchedAt,
    );
  }

  final String month;

  /// Field-recorded this month (posted + pending in ERP).
  final int collectedPoisha;
  final int postedPoisha;
  final int pendingPoisha;
  final int targetPoisha;
  final int targetToDatePoisha;
  final double visitTarget;
  final double visitTargetToDate;
  final int soloVisits;
  final int coWorkVisits;
  final double visitCredit;
  final int promisesKept;
  final int promisesDue;
  final int presentDays;
  final int lateDays;
  final List<PerfDay> days;

  /// My place on the leaderboard (null unless it is visible to staff).
  final int? rank;
  final int? rankOf;

  /// When the phone got this answer (offline view shows "as of").
  final DateTime? fetchedAt;

  /// Against the target up to today (not the whole month).
  double get amountAchievement => targetToDatePoisha <= 0 ? 0 : collectedPoisha / targetToDatePoisha;
  double get visitAchievement => visitTargetToDate <= 0 ? 0 : visitCredit / visitTargetToDate;
}

/// Leaderboard metrics (contract 1.10.0). Default: collected.
enum LeaderMetric { collected, visitCredit, promisesKept, targetAchievement }

extension LeaderMetricWire on LeaderMetric {
  String get wire => switch (this) {
        LeaderMetric.collected => 'collected',
        LeaderMetric.visitCredit => 'visit_credit',
        LeaderMetric.promisesKept => 'promises_kept',
        LeaderMetric.targetAchievement => 'target_achievement',
      };
}

class LeaderRow {
  const LeaderRow({required this.userId, required this.name, required this.employeeCode, required this.value, this.rank, this.eligible = true, this.me = false});
  factory LeaderRow.fromJson(Json j) => LeaderRow(
        userId: j['userId'] as String,
        name: I18nText.fromJson(j['name'] ?? '—').bn,
        employeeCode: (j['employeeCode'] as String?) ?? '',
        value: _d(j['value']),
        rank: (j['rank'] as num?)?.toInt(),
        eligible: (j['eligible'] as bool?) ?? true,
        me: (j['me'] as bool?) ?? false,
      );
  final String userId;
  final String name;
  final String employeeCode;

  /// Unit per metric: poisha, visit credit, count, or achievement fraction.
  final double value;

  /// null = not ranked (too few present days); ties share a rank.
  final int? rank;
  final bool eligible;
  final bool me;
}

class Leaderboard {
  const Leaderboard({required this.rows, this.myRank, this.of});
  factory Leaderboard.fromJson(Json j) {
    final me = j['me'] as Json?;
    return Leaderboard(
      rows: [for (final r in (j['items'] as List?) ?? const []) LeaderRow.fromJson(r as Json)],
      myRank: (me?['rank'] as num?)?.toInt(),
      of: (me?['of'] as num?)?.toInt(),
    );
  }
  final List<LeaderRow> rows;
  final int? myRank;
  final int? of;

  List<LeaderRow> get ranked => [for (final r in rows) if (r.rank != null) r]..sort((a, b) => a.rank!.compareTo(b.rank!));
  List<LeaderRow> get unranked => [for (final r in rows) if (r.rank == null) r];
}

/// One person on the collection board (contract 1.26.0, FR-M-048).
class BoardRow {
  const BoardRow({required this.userId, required this.name, required this.employeeCode, required this.role, required this.postedPoisha, required this.count, this.rank, this.me = false});
  factory BoardRow.fromJson(Json j) => BoardRow(
        userId: j['userId'] as String,
        name: I18nText.fromJson(j['name'] ?? '—'),
        employeeCode: (j['employeeCode'] as String?) ?? '',
        role: (j['role'] as String?) ?? 'field_staff',
        postedPoisha: (j['postedPoisha'] as num?)?.toInt() ?? 0,
        count: (j['count'] as num?)?.toInt() ?? 0,
        rank: (j['rank'] as num?)?.toInt(),
        me: (j['me'] as bool?) ?? false,
      );
  final String userId;
  final I18nText name;
  final String employeeCode;

  /// `field_staff`, `branch_manager`, `super_admin`, …: a manager or an
  /// admin who collects is ranked by collections alone.
  final String role;

  /// Field collections of the person that the ERP has accepted in the
  /// period. Money still pending in the ERP is not in it.
  final int postedPoisha;
  final int count;

  /// null = nothing posted in the period; equal amounts share a rank.
  final int? rank;
  final bool me;

  /// The crown goes to rank 1 (several people when they are level).
  bool get crowned => rank == 1;
  bool get isFieldStaff => role == 'field_staff';
  String nameOf(String lang) => lang == 'en' && (name.en?.isNotEmpty ?? false) ? name.en! : name.bn;
}

/// The collection board: verified money per collector, for a month or for
/// all time, across every branch unless the office narrowed it.
class CollectionBoard {
  const CollectionBoard({required this.rows, required this.allBranches, this.month, this.myRank, this.of, this.myPostedPoisha});
  factory CollectionBoard.fromJson(Json j) {
    final me = j['me'] as Json?;
    return CollectionBoard(
      rows: [for (final r in (j['items'] as List?) ?? const []) BoardRow.fromJson(r as Json)],
      allBranches: j['scope'] != 'branch',
      month: j['month'] as String?,
      myRank: (me?['rank'] as num?)?.toInt(),
      of: (me?['of'] as num?)?.toInt(),
      myPostedPoisha: (me?['postedPoisha'] as num?)?.toInt(),
    );
  }
  final List<BoardRow> rows;
  final bool allBranches;

  /// `YYYY-MM`; null for all time.
  final String? month;
  final int? myRank;
  final int? of;
  final int? myPostedPoisha;

  List<BoardRow> get ranked => [for (final r in rows) if (r.rank != null) r]..sort((a, b) => a.rank!.compareTo(b.rank!));
  List<BoardRow> get unranked => [for (final r in rows) if (r.rank == null) r];
}

enum ReportError { offline, hidden, failed }

ReportError _err(ApiException e) => e.isNetwork ? ReportError.offline : (e.statusCode == 403 ? ReportError.hidden : ReportError.failed);

/// Whether staff may see the leaderboard (setting, exposed to the app).
final leaderboardVisibleProvider = Provider<bool>((ref) => (ref.watch(serverSettingsProvider)['reports.leaderboardVisibleToStaff'] as bool?) ?? false);

/// Reports are read online (ADR-M08 exception: server-computed figures).
/// My month is cached on the phone so it can still be read offline.
class ReportsService {
  ReportsService(this._ref);
  final Ref _ref;

  static String _key(String month) => 'perf_$month';

  Future<(MyPerformance?, ReportError?)> myMonth(String month) async {
    final db = _ref.read(databaseProvider);
    try {
      final j = await _ref.read(fieldApiProvider).myPerformance(month);
      final at = _ref.read(clockProvider).nowUtc();
      await db.kvSet(_key(month), jsonEncode({'at': at.toIso8601String(), 'body': j}));
      return (MyPerformance.fromJson(j), null);
    } on ApiException catch (e) {
      final cached = await db.kvGet(_key(month));
      if (cached != null) {
        final c = jsonDecode(cached) as Json;
        return (MyPerformance.fromJson(c['body'] as Json, fetchedAt: DateTime.parse(c['at'] as String)), _err(e));
      }
      return (null, _err(e));
    }
  }

  Future<(Leaderboard?, ReportError?)> leaderboard({required String period, LeaderMetric metric = LeaderMetric.collected}) async {
    try {
      return (Leaderboard.fromJson(await _ref.read(fieldApiProvider).leaderboard(period: period, metric: metric.wire)), null);
    } on ApiException catch (e) {
      return (null, _err(e));
    }
  }

  /// [allTime] false = the current month. Online only: a board from
  /// yesterday would be misleading.
  Future<(CollectionBoard?, ReportError?)> collectionBoard({required bool allTime}) async {
    try {
      return (CollectionBoard.fromJson(await _ref.read(fieldApiProvider).collectionBoard(period: allTime ? 'all' : 'month')), null);
    } on ApiException catch (e) {
      // an older server has no such board yet
      return (null, e.statusCode == 404 ? ReportError.failed : _err(e));
    }
  }
}

final reportsServiceProvider = Provider<ReportsService>(ReportsService.new);

/// "2026-11" for a business date "2026-11-17", shifted by [delta] months.
String monthOf(String ymd, {int delta = 0}) {
  final p = ymd.split('-').map(int.parse).toList();
  final total = p[0] * 12 + (p[1] - 1) + delta;
  final y = total ~/ 12, m = total % 12 + 1;
  return '$y-${m.toString().padLeft(2, '0')}';
}
