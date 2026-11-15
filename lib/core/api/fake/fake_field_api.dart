import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../time/clock.dart';
import '../api_models.dart';
import 'seed.dart';

/// In-process mock of field-api v1 (`openapi.yaml`) for the demo flavour,
/// widget tests and journeys without a backend. Mirrors the contract's
/// shapes and the sync rules that matter to the app:
///
/// * `/sync/push` is idempotent by `mutationId` (second time → `replayed`).
/// * A collection for customer `c-1008` returns `conflict` ALREADY_PAID_OFFICE
///   so the Problems flow can be demonstrated.
/// * `/sync/pull` returns changes after the cursor; `410` if [expireCursor].
///
/// It is NOT a substitute for contract tests against field-api's Prism mock.
class FakeFieldApi implements HttpClientAdapter {
  FakeFieldApi({required this.clock, this.latency = const Duration(milliseconds: 250)}) {
    final seed = DemoSeed(clock.businessDate());
    for (final c in seed.customers()) {
      _log.add(_Change('customer', c['id'] as String, 'upsert', c));
    }
  }

  final Clock clock;
  Duration latency;

  /// Test hooks.
  bool offline = false;
  bool expireCursor = false;
  bool upgradeRequired = false;
  String trackingProvider = 'free'; // admin setting location.trackingProvider
  int pushCalls = 0;

  final _log = <_Change>[];
  final _applied = <String, Json>{}; // mutationId → result
  final appliedPayloads = <String, Json>{}; // mutationId → payload (tests)
  final _tokens = <String>{};
  var _receiptSeq = 0;
  var _mediaSeq = 0;
  final _mediaBySha = <String, String>{};
  final uploadedMedia = <String>[]; // tests
  final locationPoints = <Json>[]; // tests
  final heartbeats = <Json>[]; // tests
  var _password = 'demo1234';
  var _mustChange = true;
  var _cashOnHand = 820000; // ৳8,200 from yesterday
  final _limit = 5000000; // ৳50,000

  static const user = {
    'id': 'u-fs-014',
    'name': {'bn': 'রাকিব হাসান', 'en': 'Rakib Hasan'},
    'phone': '01712345678',
    'role': 'field_staff',
    'branchIds': ['br-01'],
    'employeeCode': 'FS014',
    'shiftId': 'sh-day',
    'cashLimitPoisha': 5000000,
    'active': true,
    'locale': 'bn',
  };

  static const permissions = [
    'branch.view', 'customer.view', 'customer.location.propose', 'tag.view', 'tag.set', //
    'collection.record', 'collection.view', 'cash.view', 'cash.deposit.record', 'assignment.view',
    'visit.record', 'visit.view', 'note.create', 'note.view', 'promise.create', 'promise.view',
    'attendance.record', 'leave.request',
  ];

  static const flags = {
    'module.customers': true, 'module.tags': true, 'module.collections': true, 'module.cash': true, //
    'module.visits': true, 'module.notes': true, 'module.promises': true, 'module.attendance': true,
    'module.handovers': true, 'module.location': true, 'module.notifications': true, 'module.sync': true,
    'module.reports': false, 'module.microfinance': false,
  };

  Json get _settings => {
        'dutyStart': '09:00',
        'dutyEnd': '18:00',
        'lateGraceMin': 15,
        'maxBreakMin': 60,
        'cashWarnPct': 80,
        'cashBlockOverLimit': false,
        'geofenceRadiusM': 150,
        'dailyTargetPoisha': 4000000,
        'dailyVisitTarget': 20,
        'hotline': '০১৭০০-০০০০০০',
        'location.trackingProvider': trackingProvider,
        'location.sampling': {'fastSec': 15, 'slowSec': 45, 'stillSec': 180, 'distanceFilterM': 25, 'maxAccuracyM': 50},
      };

  /// Simulates an office-side change (e.g. a new handover) for demos/tests.
  void serverChange(String entity, String id, Json data, {String op = 'upsert'}) =>
      _log.add(_Change(entity, id, op, data));

  void addPendingHandover() => serverChange('handover', 'ho-77', {
        'id': 'ho-77',
        'fromUserId': 'u-fs-020',
        'fromUserName': 'সজীব আহমেদ',
        'toUserId': user['id'],
        'reason': 'সজীব ছুটিতে (৩ দিন)',
        'status': 'pending_acceptance',
        'expiresAt': clock.nowUtc().add(const Duration(hours: 20)).toIso8601String(),
        'summary': {'customers': 18, 'outstandingPoisha': 61250000, 'overdue': 7, 'openPromises': 3, 'openConflicts': 0},
      });

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    await Future<void>.delayed(latency);
    if (offline) {
      throw DioException.connectionError(requestOptions: o, reason: 'offline (fake)');
    }
    final body = o.uri.path.contains('/upload/') ? null : await _readBody(o, requestStream);
    final path = o.uri.path.replaceFirst(RegExp(r'^.*/api/v1'), '');
    if (upgradeRequired && path != '/meta/app-config') {
      return _json(426, _problem(426, 'UPGRADE_REQUIRED', 'Update required'));
    }
    final auth = o.headers['Authorization'] as String?;
    final authed = auth != null && _tokens.contains(auth.replaceFirst('Bearer ', ''));
    final public = {'/meta/app-config', '/auth/login', '/auth/refresh', '/system/health'};
    if (!public.contains(path) && !path.startsWith('/upload/') && !authed) {
      return _json(401, _problem(401, 'TOKEN_EXPIRED', 'Unauthorized'));
    }

    switch ((o.method, path)) {
      case ('GET', '/meta/app-config'):
        return _json(200, {
          'minAppVersion': '0.1.0',
          'latestAppVersion': '0.1.0',
          'killSwitch': false,
          'privacyNoticeVersion': '2026-11-v1',
          'serverTime': clock.nowUtc().toIso8601String(),
          'tileProvider': {
            'id': 'osm-dev',
            'urlTemplate': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            'attribution': '© OpenStreetMap contributors',
            'maxZoom': 19,
          },
        });
      case ('POST', '/auth/login'):
        final b = body as Json;
        if (b['password'] != _password || (b['phone'] as String?)?.replaceAll(RegExp(r'\D'), '') != '01712345678') {
          return _json(401, _problem(401, 'INVALID_CREDENTIALS', 'Phone or password is wrong'));
        }
        return _json(200, _loginBody());
      case ('POST', '/auth/refresh'):
        return _json(200, _loginBody());
      case ('POST', '/auth/password/change'):
        final b = body as Json;
        if (b['currentPassword'] != _password) {
          return _json(400, _problem(400, 'WRONG_PASSWORD', 'Current password is wrong'));
        }
        _password = b['newPassword'] as String;
        _mustChange = false;
        return _json(204, null);
      case ('POST', '/auth/logout'):
        _tokens.remove(auth?.replaceFirst('Bearer ', ''));
        return _json(204, null);
      case ('GET', '/sync/bootstrap'):
        return _json(200, _page(0, bootstrap: true));
      case ('GET', '/sync/pull'):
        if (expireCursor) {
          expireCursor = false;
          return _json(410, _problem(410, 'CURSOR_EXPIRED', 'Cursor expired'));
        }
        final cursor = int.tryParse(o.queryParameters['cursor'].toString()) ?? 0;
        return _json(200, _page(cursor));
      case ('POST', '/sync/push'):
        pushCalls++;
        return _json(200, _push(body as Json));
      case ('POST', '/receipts/blocks'):
        final b = body as Json;
        final from = _receiptSeq + 1;
        _receiptSeq += (b['size'] as int?) ?? 200;
        return _json(201, {'prefix': 'BRL01-FS014', 'businessDate': b['businessDate'], 'from': from, 'to': _receiptSeq});
      case ('POST', '/devices/push-token'):
        return _json(204, null);
      case ('POST', '/location/points'):
        final pts = ((body as Json)['points'] as List).cast<Json>();
        locationPoints.addAll(pts);
        return _json(200, {'accepted': pts.length, 'rejected': const <Json>[]});
      case ('POST', '/location/heartbeat'):
        heartbeats.add(body as Json);
        return _json(204, null);
      case ('POST', '/media/upload-url'):
        final b = body as Json;
        final id = 'm-${++_mediaSeq}';
        final exists = _mediaBySha.containsKey(b['sha256']);
        if (!exists) _mediaBySha[b['sha256'] as String] = id;
        return _json(200, {
          'mediaId': _mediaBySha[b['sha256']],
          'alreadyExists': exists,
          if (!exists) 'uploadUrl': 'https://demo.invalid/upload/$id',
          'headers': const {},
        });
      default:
        if (o.method == 'PUT' && path.startsWith('/upload/')) {
          uploadedMedia.add(path.substring('/upload/'.length));
          return _json(200, null);
        }
        final mc = RegExp(r'^/media/([^/]+)/confirm$').firstMatch(path);
        if (mc != null && o.method == 'POST') {
          return _json(200, {'mediaId': mc.group(1), 'status': 'confirmed'});
        }
        final ho = RegExp(r'^/handovers/([^/]+)/(accept|reject)$').firstMatch(path);
        if (ho != null && o.method == 'POST') {
          final id = ho.group(1)!;
          final accepted = ho.group(2) == 'accept';
          serverChange('handover', id, {
            'id': id,
            'fromUserName': 'সজীব আহমেদ',
            'toUserId': user['id'],
            'status': accepted ? 'accepted' : 'rejected',
            'summary': {'customers': 18, 'outstandingPoisha': 61250000, 'overdue': 7, 'openPromises': 3, 'openConflicts': 0},
          });
          return _json(200, {'id': id, 'status': accepted ? 'accepted' : 'rejected'});
        }
        final cr = RegExp(r'^/customers/([^/]+)/refresh$').firstMatch(path);
        if (cr != null) {
          final last = _log.lastWhere((c) => c.entity == 'customer' && c.id == cr.group(1));
          return _json(200, {...last.data!, 'erpFetchedAt': clock.nowUtc().toIso8601String()});
        }
        return _json(404, _problem(404, 'NOT_FOUND', 'No route ${o.method} $path in fake'));
    }
  }

  Json _loginBody() {
    final token = 'demo-at-${_tokens.length + 1}';
    _tokens.add(token);
    return {
      'accessToken': token,
      'accessTokenExpiresAt': clock.nowUtc().add(const Duration(minutes: 15)).toIso8601String(),
      'refreshToken': 'demo-rt',
      'refreshTokenExpiresAt': clock.nowUtc().add(const Duration(days: 30)).toIso8601String(),
      'user': {...user, 'mustChangePassword': _mustChange},
      'permissions': permissions,
      'flags': flags,
      'serverTime': clock.nowUtc().toIso8601String(),
    };
  }

  Json _page(int cursor, {bool bootstrap = false}) {
    const pageSize = 500;
    final start = bootstrap ? 0 : cursor;
    final end = (start + pageSize).clamp(0, _log.length);
    final changes = [
      for (var i = start; i < end; i++)
        {'seq': i + 1, 'entity': _log[i].entity, 'op': _log[i].op, 'id': _log[i].id, 'data': _log[i].data},
    ];
    return {
      'changes': changes,
      'nextCursor': '$end',
      'hasMore': end < _log.length,
      'permissions': {'version': 1, 'keys': permissions},
      'flags': flags,
      'settings': _settings,
      'cash': {
        'userId': user['id'],
        'onHandPoisha': _cashOnHand,
        'limitPoisha': _limit,
        'state': _cashOnHand >= _limit ? 'exceeded' : (_cashOnHand >= _limit * 0.8 ? 'warning' : 'ok'),
        'pendingDepositsPoisha': 0,
      },
      'serverTime': clock.nowUtc().toIso8601String(),
    };
  }

  Json _push(Json req) {
    final results = <Json>[];
    for (final raw in (req['mutations'] as List)) {
      final m = raw as Json;
      final id = m['mutationId'] as String;
      if (_applied.containsKey(id)) {
        results.add({..._applied[id]!, 'result': 'replayed'});
        continue;
      }
      final entity = m['entity'] as String;
      final payload = (m['payload'] as Json?) ?? const {};
      appliedPayloads[id] = payload;
      Json r;
      if (entity == 'collection' && payload['customerId'] == 'c-1008') {
        r = {
          'mutationId': id,
          'result': 'conflict',
          'entityId': 'col-$id',
          'status': 'conflict',
          'conflict': {
            'code': 'ALREADY_PAID_OFFICE',
            'message': {'bn': 'এই কিস্তি অফিসে আগেই জমা হয়েছে', 'en': 'This installment was already paid at the office'},
          },
        };
      } else if (entity == 'collection' && (payload['amountPoisha'] as int? ?? 0) <= 0) {
        r = {
          'mutationId': id,
          'result': 'rejected',
          'error': _problem(400, 'VALIDATION_FAILED', 'amountPoisha must be ≥ 1'),
        };
      } else {
        r = {'mutationId': id, 'result': 'applied', 'entityId': '$entity-$id', 'status': entity == 'collection' ? 'received' : 'ok'};
        if (entity == 'collection' && payload['method'] == 'cash') _cashOnHand += payload['amountPoisha'] as int;
        if (entity == 'deposit') _cashOnHand -= payload['amountPoisha'] as int;
      }
      _applied[id] = r;
      results.add(r);
    }
    return {'serverTime': clock.nowUtc().toIso8601String(), 'results': results};
  }

  Json _problem(int status, String code, String title) =>
      {'type': 'about:blank', 'status': status, 'code': code, 'title': title};

  Future<Object?> _readBody(RequestOptions o, Stream<Uint8List>? s) async {
    if (o.data is Map) return Map<String, dynamic>.from(o.data as Map);
    if (s == null) return null;
    final bytes = await s.fold<List<int>>(<int>[], (a, b) => a..addAll(b));
    if (bytes.isEmpty) return null;
    return jsonDecode(utf8.decode(bytes));
  }

  ResponseBody _json(int status, Object? body) => ResponseBody.fromString(
        body == null ? '' : jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [status >= 400 ? 'application/problem+json' : 'application/json'],
        },
      );

  @override
  void close({bool force = false}) {}
}

class _Change {
  _Change(this.entity, this.id, this.op, this.data);
  final String entity;
  final String id;
  final String op;
  final Json? data;
}
