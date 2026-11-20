import 'package:dio/dio.dart';

import 'api_models.dart';

/// Thrown for any API failure. [isNetwork] means "try again later" (offline,
/// timeout, 5xx); otherwise [problem] carries the server's RFC 9457 body.
class ApiException implements Exception {
  ApiException({this.problem, this.statusCode, this.isNetwork = false, this.cause});
  final Problem? problem;
  final int? statusCode;
  final bool isNetwork;
  final Object? cause;

  String get code => problem?.code ?? (isNetwork ? 'NETWORK' : 'HTTP_$statusCode');

  bool get isRetryable => isNetwork || (statusCode != null && statusCode! >= 500) || statusCode == 429;

  static ApiException from(DioException e) {
    final res = e.response;
    if (res == null) return ApiException(isNetwork: true, cause: e);
    final data = res.data;
    final problem = data is Map<String, dynamic> && data['code'] != null ? Problem.fromJson(data) : null;
    final code = res.statusCode ?? 0;
    return ApiException(problem: problem, statusCode: code, isNetwork: code >= 500, cause: e);
  }

  @override
  String toString() => 'ApiException($code, ${problem?.title ?? cause})';
}

/// Typed facade over the field-api v1 endpoints the app uses.
///
/// Only the sync engine, auth/session and explicitly online-only use cases
/// (ADR-M08) may depend on this class — never widgets (fos_lints rule
/// `no_network_in_presentation`).
class FieldApi {
  FieldApi(this._dio);
  final Dio _dio;

  Future<T> _call<T>(Future<Response<dynamic>> Function() f, T Function(dynamic data) map) async {
    try {
      final r = await f();
      return map(r.data);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<AppConfig> appConfig() =>
      _call(() => _dio.get<dynamic>('/meta/app-config'), (d) => AppConfig.fromJson(d as Json));

  Future<LoginResponse> login({required String phone, required String password}) => _call(
        () => _dio.post<dynamic>('/auth/login', data: {'phone': phone, 'password': password, 'client': 'app'}),
        (d) => LoginResponse.fromJson(d as Json),
      );

  Future<LoginResponse> refresh(String refreshToken) => _call(
        () => _dio.post<dynamic>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
          options: Options(extra: {'skipAuth': true}),
        ),
        (d) => LoginResponse.fromJson(d as Json),
      );

  Future<void> changePassword({required String current, required String next}) => _call(
        () => _dio.post<dynamic>('/auth/password/change', data: {'currentPassword': current, 'newPassword': next}),
        (_) {},
      );

  Future<void> logout() => _call(() => _dio.post<dynamic>('/auth/logout'), (_) {});

  Future<void> registerPushToken(String token) =>
      _call(() => _dio.post<dynamic>('/devices/push-token', data: {'token': token}), (_) {});

  /// Bootstrap page: `items` + a snapshot `nextCursor`; the final page carries `pullCursor`.
  Future<SyncPullResponse> syncBootstrap({String? cursor}) => _call(
        () => _dio.get<dynamic>('/sync/bootstrap', queryParameters: {'cursor': ?cursor}),
        (d) => SyncPullResponse.fromBootstrapJson(d as Json),
      );

  Future<SyncPullResponse> syncPull(String cursor, {int limit = 500}) => _call(
        () => _dio.get<dynamic>('/sync/pull', queryParameters: {'cursor': cursor, 'limit': limit}),
        (d) => SyncPullResponse.fromJson(d as Json),
      );

  Future<SyncPushResponse> syncPush({required String deviceId, required List<SyncMutation> mutations, String? lastPullCursor}) =>
      _call(
        () => _dio.post<dynamic>('/sync/push', data: {
          'deviceId': deviceId,
          'lastPullCursor': ?lastPullCursor,
          'mutations': mutations.map((m) => m.toJson()).toList(),
        }),
        (d) => SyncPushResponse.fromJson(d as Json),
      );

  Future<ReceiptBlockDto> allocateReceiptBlock({required String deviceId, required String businessDate, int size = 200}) =>
      _call(
        () => _dio.post<dynamic>('/receipts/blocks', data: {'deviceId': deviceId, 'businessDate': businessDate, 'size': size}),
        (d) => ReceiptBlockDto.fromJson(d as Json),
      );

  /// Online-only (ADR-M08): handover decision changes scope.
  Future<void> acceptHandover(String id) => _call(() => _dio.post<dynamic>('/handovers/$id/accept'), (_) {});

  Future<void> rejectHandover(String id, String reason) =>
      _call(() => _dio.post<dynamic>('/handovers/$id/reject', data: {'reason': reason}), (_) {});

  /// Location batch upload (phase 2). Returns accepted count and the
  /// server's next sampling config (may be null).
  Future<({int accepted, Json? nextSampling})> ingestPoints({required String deviceId, required List<Json> points}) => _call(
        () => _dio.post<dynamic>('/location/points', data: {'deviceId': deviceId, 'points': points}),
        (d) => (accepted: ((d as Json)['accepted'] as num?)?.toInt() ?? 0, nextSampling: d['nextSampling'] as Json?),
      );

  Future<void> heartbeat(Json body) => _call(() => _dio.post<dynamic>('/location/heartbeat', data: body), (_) {});

  // ── co-work (1.9.0) — online-only (ADR-M08): partners must see answers at once.

  Future<List<Json>> coworkColleagues() =>
      _call(() => _dio.get<dynamic>('/cowork/colleagues'), (d) => (d as List).cast<Json>());

  Future<List<Json>> myCoworkSessions() =>
      _call(() => _dio.get<dynamic>('/cowork/sessions/mine'), (d) => (d as List).cast<Json>());

  Future<Json> requestCowork({required String clientId, required List<String> toUserIds, String? note}) => _call(
        () => _dio.post<dynamic>('/cowork/requests', data: {'clientId': clientId, 'toUserIds': toUserIds, 'note': ?note}),
        (d) => d as Json,
      );

  Future<Json> respondCowork(String id, {required bool accept}) => _call(
        () => _dio.post<dynamic>('/cowork/sessions/$id/respond', data: {'decision': accept ? 'accept' : 'reject'}),
        (d) => d as Json,
      );

  Future<Json> leaveCowork(String id) => _call(() => _dio.post<dynamic>('/cowork/sessions/$id/leave'), (d) => d as Json);

  // ── reports (1.10.0) — online; the app keeps the last answer for offline viewing.

  /// My month: totals, per-day rows, rank (null unless the leaderboard is visible to staff).
  Future<Json> myPerformance(String month) =>
      _call(() => _dio.get<dynamic>('/reports/me/performance', queryParameters: {'month': month}), (d) => d as Json);

  /// My branch's leaderboard; 403 unless setting reports.leaderboardVisibleToStaff.
  Future<Json> leaderboard({required String period, String? date, String? metric}) => _call(
        () => _dio.get<dynamic>('/reports/leaderboard', queryParameters: {'period': period, 'date': ?date, 'metric': ?metric}),
        (d) => d as Json,
      );

  /// The collection board (1.26.0, FR-REP-007): everyone who collected,
  /// ranked by money the ERP has accepted, for a month or all time; 403
  /// unless the leaderboard is visible to staff.
  Future<Json> collectionBoard({required String period, String? month}) => _call(
        () => _dio.get<dynamic>('/reports/collection-board', queryParameters: {'period': period, 'month': ?month}),
        (d) => d as Json,
      );

  // ── leave, holidays, my shift (1.12.0) — online (ADR-M08 exception):
  // the server checks overlaps and tells the manager; answers are cached.

  /// My leave requests, newest first.
  Future<List<Json>> myLeaveRequests() =>
      _call(() => _dio.get<dynamic>('/leave-requests'), (d) => ((d as Json)['items'] as List).cast<Json>());

  Future<Json> requestLeave({required String type, required String from, required String to, String? reason}) => _call(
        () => _dio.post<dynamic>('/leave-requests', data: {'type': type, 'from': from, 'to': to, 'reason': ?reason}),
        (d) => d as Json,
      );

  /// Withdraw my own request while nobody has decided it.
  Future<Json> cancelLeave(String id) => _call(() => _dio.post<dynamic>('/leave-requests/$id/cancel'), (d) => d as Json);

  /// National holidays and my branch's own.
  Future<List<Json>> holidays({required int year, String? branchId}) => _call(
        () => _dio.get<dynamic>('/calendar/holidays', queryParameters: {'year': year, 'branchId': ?branchId}),
        (d) => (d as List).cast<Json>(),
      );

  /// My shift, or the branch default (`id: default`).
  Future<Json> myShift() => _call(() => _dio.get<dynamic>('/attendance/me/shift'), (d) => d as Json);

  /// Online-only: on-demand balance refresh from ERP.
  Future<Json> refreshCustomer(String id) =>
      _call(() => _dio.post<dynamic>('/customers/$id/refresh'), (d) => d as Json);
}
