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

  /// Bootstrap page (same shape as pull; the final page carries the cursor).
  Future<SyncPullResponse> syncBootstrap({String? cursor}) => _call(
        () => _dio.get<dynamic>('/sync/bootstrap', queryParameters: {'cursor': ?cursor}),
        (d) => SyncPullResponse.fromJson(d as Json),
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

  /// Online-only: on-demand balance refresh from ERP.
  Future<Json> refreshCustomer(String id) =>
      _call(() => _dio.post<dynamic>('/customers/$id/refresh'), (d) => d as Json);
}
