import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/api/field_api.dart';
import 'package:staff_app/core/network/dio_client.dart';

/// Answers like field-api's strict JSON parser: a request that says it carries JSON must carry a JSON
/// document, else 400 VALIDATION_FAILED. Records every request it sees.
class _StrictServer implements HttpClientAdapter {
  final seen = <({String method, String path, String? contentType, String body})>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final bytes = requestStream == null ? <int>[] : (await requestStream.toList()).expand((b) => b).toList();
    final body = utf8.decode(bytes);
    final ct = o.headers[Headers.contentTypeHeader] as String?;
    seen.add((method: o.method, path: o.uri.path, contentType: ct, body: body));
    final json = {Headers.contentTypeHeader: [Headers.jsonContentType]};
    if ((ct ?? '').contains('json') && body.trim().isEmpty) {
      return ResponseBody.fromString(jsonEncode({'type': 'about:blank', 'title': 'Body cannot be empty', 'status': 400, 'code': 'VALIDATION_FAILED'}), 400, headers: json);
    }
    return ResponseBody.fromString(jsonEncode({'id': 'c-1'}), 200, headers: json);
  }

  @override
  void close({bool force = false}) {}
}

class _Tokens implements TokenProvider {
  @override
  String? get accessToken => 'token';
  @override
  Future<String?> refreshAccessToken() async => null;
}

void main() {
  late _StrictServer server;
  late FieldApi api;
  setUp(() {
    server = _StrictServer();
    api = FieldApi(buildDio(
      baseUrl: 'https://field.test/api/v1',
      client: ClientInfo(appVersion: '1', deviceId: 'dev', deviceLabel: 'test', language: () => 'bn'),
      tokens: _Tokens(),
      onUpgradeRequired: (_) {},
      adapter: server,
    ));
  });

  // Owner report 2026-11-23: the customer page's reload said "Code: VALIDATION_FAILED". The POST has no body
  // in the contract, but went out as `Content-Type: application/json` with an empty body.
  test('customer reload: POST /customers/{id}/refresh with no body and no JSON content type', () async {
    final detail = await api.refreshCustomer('c-1');
    expect(detail['id'], 'c-1');
    final r = server.seen.single;
    expect(r.method, 'POST');
    expect(r.path, '/api/v1/customers/c-1/refresh');
    expect(r.body, isEmpty);
    expect(r.contentType, isNull);
  });

  test('other body-less POSTs are sent the same way', () async {
    await api.acceptHandover('h-1');
    await api.leaveCowork('s-1');
    await api.logout();
    expect(server.seen.map((r) => r.contentType), everyElement(isNull));
  });

  test('a POST with a body still says JSON', () async {
    await api.rejectHandover('h-1', 'wrong customer');
    final r = server.seen.single;
    expect(r.contentType, contains('application/json'));
    expect(jsonDecode(r.body), {'reason': 'wrong customer'});
  });
}
