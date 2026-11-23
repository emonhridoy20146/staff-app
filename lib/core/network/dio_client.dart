import 'dart:async';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Supplies and refreshes tokens for [AuthInterceptor].
abstract class TokenProvider {
  String? get accessToken;

  /// Refreshes tokens; returns the new access token or null if the session
  /// is no longer valid (user must log in again).
  Future<String?> refreshAccessToken();
}

class ClientInfo {
  const ClientInfo({required this.appVersion, required this.deviceId, required this.deviceLabel, required this.language});
  final String appVersion;
  final String deviceId;
  final String deviceLabel;
  final String Function() language;
}

/// Builds the app's dio with the contract's interceptors (05-api-contract):
/// client headers → auth (single-flight refresh) → 426 version gate.
Dio buildDio({
  required String baseUrl,
  required ClientInfo client,
  required TokenProvider tokens,
  required void Function(Map<String, dynamic>? problem) onUpgradeRequired,
  HttpClientAdapter? adapter,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  );
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.addAll([
    ClientHeadersInterceptor(client),
    AuthInterceptor(dio, tokens),
    VersionGateInterceptor(onUpgradeRequired),
  ]);
  return dio;
}

class ClientHeadersInterceptor extends Interceptor {
  ClientHeadersInterceptor(this.info);
  final ClientInfo info;
  static const _uuid = Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Client'] = 'staff-app/${info.appVersion} (${info.deviceLabel})';
    options.headers['X-Device-Id'] = info.deviceId;
    options.headers['Accept-Language'] = info.language();
    options.headers['X-Request-Id'] = _uuid.v7();
    options.headers['Accept-Encoding'] = 'gzip';
    // A request with no body must not say it carries JSON. With the base `application/json` content type dio
    // sent `Content-Type: application/json` and `Content-Length: 0` on body-less POSTs (`/customers/{id}/refresh`,
    // `/auth/logout`, `/handovers/{id}/accept`, …), and field-api's strict JSON parser answered 400
    // VALIDATION_FAILED: an empty string is not a JSON document (customer reload, owner report 2026-11-23).
    if (options.data == null) options.contentType = null;
    handler.next(options);
  }
}

/// Attaches the bearer token; on 401 refreshes **once** for all concurrent
/// requests (single-flight) and retries each original request once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._tokens);
  final Dio _dio;
  final TokenProvider _tokens;
  Future<String?>? _inflight;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skip = options.extra['skipAuth'] == true;
    final t = _tokens.accessToken;
    if (!skip && t != null) options.headers['Authorization'] = 'Bearer $t';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    if (!is401 || req.extra['skipAuth'] == true || req.extra['retried'] == true) {
      return handler.next(err);
    }
    final fresh = await (_inflight ??= _tokens.refreshAccessToken().whenComplete(() => _inflight = null));
    if (fresh == null) return handler.next(err);
    try {
      req.headers['Authorization'] = 'Bearer $fresh';
      req.extra['retried'] = true;
      final r = await _dio.fetch<dynamic>(req);
      handler.resolve(r);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

/// 426 UPGRADE_REQUIRED → app shows the update screen; queue stays intact
/// (FR-M-017, journey M-E8).
class VersionGateInterceptor extends Interceptor {
  VersionGateInterceptor(this.onUpgrade);
  final void Function(Map<String, dynamic>? problem) onUpgrade;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 426) {
      final d = err.response?.data;
      onUpgrade(d is Map<String, dynamic> ? d : null);
    }
    handler.next(err);
  }
}
