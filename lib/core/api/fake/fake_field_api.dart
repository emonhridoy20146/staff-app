import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
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
    _seedNoticesAndLeave();
  }

  final Clock clock;
  Duration latency;

  /// Test hooks.
  bool offline = false;
  /// A refusal `POST /auth/login` answers with a right password (status + problem body), e.g. 403 DEVICE_NOT_APPROVED.
  ({int status, Json body})? loginRefusal;
  bool expireCursor = false;

  /// `POST /customers/{id}/refresh` calls (FR-M-063 tests).
  int customerRefreshCalls = 0;
  /// Every answered request as `METHOD /path` (pull-to-refresh tests count `GET /sync/pull`).
  final requestLog = <String>[];
  bool upgradeRequired = false;
  bool uploadsFail = false; // the storage host refuses photos (e.g. a misconfigured server)
  String trackingProvider = 'free'; // admin setting location.trackingProvider
  bool selfieRequired = true; // attendance.selfieRequired (master switch)
  /// Contract 1.45.0 `attendanceRequired` on login, `/auth/me` and the sync snapshot; null = not sent (older server).
  bool? attendanceRequired;
  /// Events the server already has for today (`GET /attendance/me/today`, 1.36.0).
  List<Json> todayAttendanceEvents = [];
  int meTodayCalls = 0;
  List<String>? selfieEvents = const ['work_in', 'work_out']; // attendance.selfieEvents (server default since 1.36.0); null = not sent
  int pushCalls = 0;
  int coworkMaxMembers = 5; // cowork.maxMembers, counts the requester
  String staffPinApproval = 'when_missing'; // customers.staffPinApproval (1.11.0)
  /// Signed-in user holds `customer.location.approve` (office user, 1.39.0).
  bool pinApprover = false;
  /// Signed-in user holds `place.manage` (super admin, branch manager): moves places at once.
  bool placeManager = false;
  List<String> get _permissions => [...permissions, if (pinApprover) 'customer.location.approve', if (placeManager) 'place.manage'];

  /// My daily target (1.10.0). The demo shows the leaderboard; the real
  /// default of reports.leaderboardVisibleToStaff is false.
  int targetPoisha = 4000000;
  int targetVisits = 20;
  bool workingDay = true;
  bool leaderboardVisible = true;
  var _collectedToday = 0;

  /// Branch colleagues for co-work (contract 1.9.0). `onDutyToday` is a
  /// test hook; `inSession` is worked out from [_cowork].
  final colleagues = <Json>[
    {'id': 'u-fs-020', 'name': 'সজীব আহমেদ', 'employeeCode': 'FS020', 'onDutyToday': true},
    {'id': 'u-fs-021', 'name': 'তানভীর ইসলাম', 'employeeCode': 'FS021', 'onDutyToday': true},
    {'id': 'u-fs-022', 'name': 'মাহমুদা আক্তার', 'employeeCode': 'FS022', 'onDutyToday': true},
    {'id': 'u-fs-023', 'name': 'রুবেল মিয়া', 'employeeCode': 'FS023', 'onDutyToday': false},
  ];
  final _cowork = <String, Json>{}; // session id → CoworkSession
  final _coworkClientIds = <String, String>{}; // request clientId → session id
  var _coworkSeq = 0;

  /// Next N pushed mutations get `rejected` + `retryable: true` (1.5.0).
  int transientRejects = 0;

  final _log = <_Change>[];
  final _applied = <String, Json>{}; // mutationId → result
  final appliedPayloads = <String, Json>{}; // mutationId → payload (tests)
  final _tokens = <String>{};
  var _receiptSeq = 0;
  var _mediaSeq = 0;
  final _mediaBySha = <String, String>{};
  final uploadedMedia = <String>[]; // tests
  /// Signed upload grants (`/storage/o?t=`): token → media id, size, sha256 (field-api ADR-039/053).
  final _grants = <String, ({String mediaId, int size, String sha256, String contentType})>{};
  final _storedMedia = <String>{};
  /// field-api answers `uploadUrl` relative to its own origin (`/api/v1/storage/o?t=…`) when set (tests).
  bool relativeUploadUrl = false;
  /// Every `POST /media/upload-url` body and every storage PUT as the server saw it (tests).
  final presignBodies = <Json>[];
  final storagePuts = <({String? contentType, String? contentLength, bool hadAuth, int bodyLength})>[];
  final locationPoints = <Json>[]; // tests
  final heartbeats = <Json>[]; // tests

  /// Tokens issued by `POST /location/tracking-token` (1.49.0), oldest first; only the last one is live (each call
  /// rotates). Tests read them.
  final trackingTokenRequests = <String>[];
  var _password = 'demo1234';
  var _mustChange = true;
  var _cashOnHand = 820000; // ৳8,200 from yesterday

  /// Every collection the server has taken from me, oldest first (1.27.0, 1.35.0). The newest cash
  /// ones not handed in by a deposit add up to [_cashOnHand]; `depositId` is set by a deposit.
  late final List<Json> _srvCollections = [
    {'collectionId': 'col-y1', 'customerId': 'c-1002', 'erpPlanId': 'INV-2291', 'amountPoisha': 500000, 'method': 'cash', 'status': 'received', 'receiptNo': 'BRL01-FS014-000118', 'recordedAt': clock.nowUtc().subtract(const Duration(hours: 22)).toIso8601String()},
    {'collectionId': 'col-y2', 'customerId': 'c-1005', 'erpPlanId': 'INV-2317', 'amountPoisha': 450000, 'method': 'cash', 'status': 'received', 'receiptNo': 'BRL01-FS014-000119', 'recordedAt': clock.nowUtc().subtract(const Duration(hours: 20)).toIso8601String()},
  ];

  /// Cash collections still in hand on the server (not voided, not handed in by a 1.35.0 deposit).
  Iterable<Json> get _cashRows => _srvCollections.where((c) => c['method'] == 'cash' && c['status'] == 'received' && c['depositId'] == null);
  var _depositSeq = 0;
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
    'branch.view', 'customer.view', 'customer.location.propose', 'customer.phone.manage', 'tag.view', 'tag.set', //
    'collection.record', 'collection.view', 'cash.view', 'cash.deposit.record', 'assignment.view',
    'visit.record', 'visit.view', 'note.create', 'note.view', 'promise.create', 'promise.view',
    'attendance.record', 'leave.request', 'cowork.use', 'task.work', 'place.view', 'place.create', 'prospect.create', 'request.create',
  ];

  static const flags = {
    'module.customers': true, 'module.tags': true, 'module.collections': true, 'module.cash': true, //
    'module.visits': true, 'module.notes': true, 'module.promises': true, 'module.attendance': true,
    'module.handovers': true, 'module.location': true, 'module.notifications': true, 'module.sync': true,
    'module.cowork': true, 'module.targets': true, 'module.reports': true, 'module.tasks': true, 'module.places': true, 'module.prospects': true, 'module.requests': true, 'module.microfinance': false,
  };

  Json get _settings => {
        'dutyStart': '09:00',
        'dutyEnd': '21:00',
        'lateGraceMin': 15,
        'maxBreakMin': 60,
        'cashWarnPct': 80,
        'cashBlockOverLimit': false,
        'geofenceRadiusM': 150,
        'reports.leaderboardVisibleToStaff': leaderboardVisible,
        'reports.leaderboardMinPresentDays': 1,
        'hotline': '০১৭০০-০০০০০০',
        'location.trackingProvider': trackingProvider,
        'attendance.selfieRequired': selfieRequired,
        if (selfieEvents != null) 'attendance.selfieEvents': selfieEvents,
        'cowork.maxMembers': coworkMaxMembers,
        'customers.staffPinApproval': staffPinApproval,
        'cowork.visitCredit': 1.0,
        'location.sampling': {'fastSec': 15, 'slowSec': 45, 'stillSec': 180, 'distanceFilterM': 25, 'maxAccuracyM': 50},
      };

  // ── notices, leave, holidays, my shift (contract 1.12.0) ────────────────

  /// broadcast id → acked by me at (tests read it).
  final noticeAcks = <String, String>{};
  final _notices = <String, Json>{};
  final _leave = <Json>[];
  var _leaveSeq = 0;

  /// The office's holiday calendar (national + branch `br-01` / `br-02`).
  final holidays = <Json>[
    {'id': 'h-1', 'date': '2026-12-16', 'name': {'bn': 'বিজয় দিবস', 'en': 'Victory Day'}, 'branchIds': <String>[], 'type': 'national'},
    {'id': 'h-2', 'date': '2026-12-25', 'name': {'bn': 'বড়দিন', 'en': 'Christmas Day'}, 'branchIds': <String>[], 'type': 'national'},
    {'id': 'h-3', 'date': '2026-11-26', 'name': {'bn': 'শাখার বার্ষিক সভা', 'en': 'Branch annual meeting'}, 'branchIds': ['br-01'], 'type': 'branch'},
    {'id': 'h-4', 'date': '2026-11-28', 'name': {'bn': 'অন্য শাখার ছুটি', 'en': 'Another branch holiday'}, 'branchIds': ['br-02'], 'type': 'branch'},
    {'id': 'h-5', 'date': '2026-03-26', 'name': {'bn': 'স্বাধীনতা দিবস', 'en': 'Independence Day'}, 'branchIds': <String>[], 'type': 'national'},
    {'id': 'h-6', 'date': '2027-02-21', 'name': {'bn': 'শহীদ দিবস', 'en': 'Language Martyrs Day'}, 'branchIds': <String>[], 'type': 'national'},
  ];

  Json myShift = const {'id': 'sh-day', 'name': 'দিনের শিফট', 'start': '09:00', 'end': '18:00', 'weeklyOff': [5], 'lateGraceMin': 15, 'maxBreakMin': 60};

  String _ymdPlus(int days) {
    final d = parseBusinessDate(clock.businessDate()).add(Duration(days: days));
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _seedNoticesAndLeave() {
    final now = clock.nowUtc();
    addNotice(
      'bc-1',
      title: {'bn': 'নতুন নিয়ম: রসিদ ছাড়া টাকা নয়', 'en': 'New rule: no money without a receipt'},
      body: {
        'bn': 'আজ থেকে কোনো কিস্তির টাকা নিলে সাথে সাথে অ্যাপে রসিদ দিন। রসিদ ছাড়া টাকা নিলে তা গ্রহণযোগ্য হবে না। প্রশ্ন থাকলে শাখা ম্যানেজারকে ফোন করুন।',
        'en': 'From today, record a receipt in the app as soon as you take any installment. Money taken without a receipt will not be accepted. Call your branch manager with questions.',
      },
      requireAck: true,
      at: now.subtract(const Duration(hours: 1)),
    );
    addNotice(
      'bc-2',
      title: {'bn': 'বৃহস্পতিবার শাখা মিটিং', 'en': 'Branch meeting on Thursday'},
      body: {'bn': 'বৃহস্পতিবার বিকাল ৫টায় শাখা অফিসে মাসিক মিটিং হবে।', 'en': 'The monthly meeting is at the branch office on Thursday at 5 pm.'},
      at: now.subtract(const Duration(days: 1, hours: 3)),
    );
    _leave.add({
      'id': 'lv-${++_leaveSeq}', 'userId': user['id'], 'branchId': 'br-01', 'type': 'casual', 'from': _ymdPlus(12), 'to': _ymdPlus(13), 'days': 2,
      'reason': 'ভাইয়ের বিয়ে', 'status': 'approved', 'decidedBy': 'u-bm-001', 'decidedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
      'createdAt': now.subtract(const Duration(days: 4)).toIso8601String(),
    });
  }

  /// Tests / demo: the office sends a notice.
  void addNotice(String id, {required Json title, required Json body, bool requireAck = false, DateTime? at}) {
    final b = {
      'id': id, 'title': title, 'body': body, 'branchIds': ['br-01'], 'roles': ['field_staff'], 'requireAck': requireAck,
      'createdBy': {'id': 'u-bm-001', 'name': 'মোস্তফা কামাল'}, 'createdAt': (at ?? clock.nowUtc()).toIso8601String(),
      'recipientCount': 12, 'ackCount': 0, 'acked': false,
    };
    _notices[id] = b;
    serverChange('broadcast', id, b);
  }

  // ── map places (contract 1.38.0) ───────────────────────────────────────────

  final _places = <String, Json>{};
  static const _office = {'id': 'u-bm-001', 'name': 'মোস্তফা কামাল'};
  Json get _me => {'id': user['id'], 'name': _nameOf(user['id']! as String)};

  /// Tests / demo: a place someone else (by default the office) put on the map.
  void addPlace(String id, {required String name, String icon = 'shop', String? note, double lat = 22.7012, double lng = 90.3711, Json? by}) {
    final at = clock.nowUtc().toIso8601String();
    final who = by ?? _office;
    final p = {
      'id': id, 'clientId': null, 'branchId': 'br-01', 'name': name, 'icon': icon, 'note': note, 'location': {'lat': lat, 'lng': lng},
      'status': 'active', 'version': 1, 'pendingMove': null, 'lastMoveDecision': null, 'createdBy': who, 'updatedBy': who,
      'createdAt': at, 'updatedAt': at, 'deletedAt': null, 'deleteReason': null,
      'events': [{'type': 'created', 'by': who, 'at': at, 'note': null, 'from': null, 'to': {'lat': lat, 'lng': lng}}],
    };
    _places[id] = p;
    serverChange('place', id, p);
  }

  /// Tests / demo: the office approves or rejects the open move request of a place.
  void decidePlaceMove(String id, {required bool approve, String? reason}) {
    final p = _places[id]!;
    final pm = p['pendingMove'] as Json;
    final at = clock.nowUtc().toIso8601String();
    final next = {
      ...p,
      if (approve) 'location': pm['location'],
      'pendingMove': null,
      'lastMoveDecision': {'decision': approve ? 'approve' : 'reject', 'by': _office, 'at': at, 'reason': reason, 'requestedBy': pm['requestedBy']},
      'version': (p['version'] as int) + 1,
      'updatedAt': at,
    };
    _places[id] = next;
    serverChange('place', id, next);
  }

  /// Tests: another office user moves a place directly (its version goes up; this phone does not know yet).
  void officeMovesPlace(String id, {required double lat, required double lng}) {
    final p = _places[id]!;
    final next = {...p, 'location': {'lat': lat, 'lng': lng}, 'pendingMove': null, 'version': (p['version'] as int) + 1, 'updatedAt': clock.nowUtc().toIso8601String()};
    _places[id] = next;
    serverChange('place', id, next);
  }

  /// Tests / demo: the office removes a place.
  void deletePlace(String id) {
    _places[id] = {..._places[id]!, 'status': 'deleted'};
    serverChange('place', id, const {}, op: 'delete');
  }

  /// The server's rules for the three place mutations (FR-PLC-002..004).
  // ── staff requests (contract 1.48.0, FR-M-075, field-api ADR-066) ──────────

  /// Requests on the server by id: mine (`rq-<clientId>`) and those the office gave me.
  final requests = <String, Json>{};

  /// Comments by clientId (replays answer once).
  final _requestComments = <String>{};

  /// Tests: the server refuses every new request with this problem code (e.g. `FORBIDDEN`).
  String? refuseRequests;
  int _requestEventSeq = 0;

  Json _queueTarget(String queue) => {'queue': queue, 'user': null};
  Json _personTarget(Json p) => {'queue': 'assignee', 'user': {'id': p['id'], 'name': p['name']}};
  Json _targetOf(Json r) => r['assignee'] == null ? _queueTarget(r['currentQueue'] as String) : _personTarget(r['assignee'] as Json);

  void _requestStep(String id, String kind, {required Json actor, String? note, Json? to, String? status, Json? patch}) {
    final r = requests[id]!;
    final from = _targetOf(r);
    final before = r['status'];
    r.addAll(patch ?? const {});
    if (status != null) r['status'] = status;
    final at = clock.nowUtc().toIso8601String();
    r['timeline'] = [
      ...(r['timeline'] as List),
      {
        'id': 'rte-${++_requestEventSeq}', 'kind': kind, 'at': at, 'actor': actor, 'note': note,
        'from': kind == 'forwarded' || kind == 'assigned' ? from : null, 'to': to,
        'status': status == null || status == before ? null : {'from': before, 'to': status},
      },
    ];
    r['updatedAt'] = at;
    r['version'] = (r['version'] as int) + 1;
    serverChange('request', id, Map<String, dynamic>.of(r));
  }

  /// Tests / demo: the office forwards a request to a person ([to]) or, without one, to the super admin queue.
  void forwardRequest(String id, {Json? to, Json? by, String note = 'দেখুন'}) => _requestStep(id, 'forwarded',
      actor: by ?? _office,
      note: note,
      to: to == null ? _queueTarget('super_admin') : _personTarget(to),
      status: 'forwarded',
      patch: to == null ? {'currentQueue': 'super_admin', 'level': 'super_admin', 'assignee': null} : {'currentQueue': 'assignee', 'assignee': to});

  /// Tests / demo: the office assigns a request to someone.
  void assignRequest(String id, {required Json to, Json? by, String? note}) =>
      _requestStep(id, 'assigned', actor: by ?? _office, note: note, to: _personTarget(to), status: 'in_progress', patch: {'currentQueue': 'assignee', 'assignee': to});

  /// Tests / demo: the office comments.
  void commentOnRequest(String id, String text, {Json? by}) => _requestStep(id, 'comment', actor: by ?? _office, note: text);

  /// Tests / demo: the office resolves it with a note.
  void resolveRequest(String id, {String note = 'সমাধান হয়েছে', Json? by}) {
    final who = by ?? _office;
    _requestStep(id, 'resolved', actor: who, note: note, status: 'resolved', patch: {'resolvedAt': clock.nowUtc().toIso8601String(), 'resolvedBy': who, 'resolutionNote': note});
  }

  /// Tests / demo: the office closes it.
  void closeRequest(String id, {String? note, Json? by}) =>
      _requestStep(id, 'closed', actor: by ?? _office, note: note, status: 'closed', patch: {'closedAt': clock.nowUtc().toIso8601String()});

  /// Tests / demo: a colleague's request the office gave to me.
  void addRequestForMe(String id, {required String title, String body = '', String type = 'report', String priority = 'normal', Json? from}) {
    final at = clock.nowUtc().toIso8601String();
    final maker = from ?? {'id': 'u-fs-020', 'name': 'সজীব আহমেদ'};
    final queue = priority == 'important' ? 'super_admin' : 'area_manager';
    requests[id] = {
      'id': id, 'clientId': 'cl-$id', 'type': type, 'priority': priority, 'title': title, 'body': body, 'customerId': null,
      'photoMediaIds': <String>[], 'branchId': 'br-01', 'createdBy': maker, 'createdAt': at, 'createdDate': clock.businessDate(),
      'status': 'open', 'currentQueue': queue, 'level': queue, 'assignee': null, 'dueAt': null, 'resolvedAt': null, 'resolvedBy': null,
      'resolutionNote': null, 'closedAt': null, 'updatedAt': at, 'version': 1,
      'timeline': [
        {'id': 'rte-${++_requestEventSeq}', 'kind': 'created', 'at': at, 'actor': maker, 'note': null, 'from': null, 'to': _queueTarget(queue), 'status': {'from': null, 'to': 'open'}},
      ],
    };
    assignRequest(id, to: _me);
  }

  /// `request` (1.48.0 `RequestCreate`): idempotent by clientId; unknown fields refused like the strict schema.
  Json _requestMutation(String mutationId, Json payload) {
    Json invalid(String what) => {'mutationId': mutationId, 'result': 'rejected', 'error': _problem(400, 'VALIDATION_FAILED', what)};
    if (refuseRequests != null) return {'mutationId': mutationId, 'result': 'rejected', 'error': _problem(403, refuseRequests!, 'refused')};
    const allowed = {'clientId', 'type', 'priority', 'title', 'body', 'customerId', 'photoMediaIds', 'dueAt', 'branchId'};
    if (payload.keys.any((k) => !allowed.contains(k))) return invalid('unknown field');
    if (!['request', 'report', 'inform', 'complaint'].contains(payload['type'])) return invalid('type');
    if (!['normal', 'important'].contains(payload['priority'])) return invalid('priority');
    final title = (payload['title'] as String?)?.trim() ?? '';
    final body = (payload['body'] as String?)?.trim() ?? '';
    if (title.isEmpty || title.length > 160 || body.isEmpty || body.length > 4000) return invalid('title or body');
    final photos = (payload['photoMediaIds'] as List?) ?? const [];
    if (photos.length > 5 || photos.any((m) => !uploadedMedia.contains(m))) return invalid('photoMediaIds');
    final id = 'rq-${payload['clientId']}';
    if (requests.containsKey(id)) return {'mutationId': mutationId, 'result': 'applied', 'entityId': id}; // replay
    final at = clock.nowUtc().toIso8601String();
    final queue = payload['priority'] == 'important' ? 'super_admin' : 'area_manager';
    requests[id] = {
      'id': id, 'clientId': payload['clientId'], 'type': payload['type'], 'priority': payload['priority'], 'title': title, 'body': body,
      'customerId': payload['customerId'], 'photoMediaIds': photos, 'branchId': 'br-01', 'createdBy': _me, 'createdAt': at,
      'createdDate': clock.businessDate(), 'status': 'open', 'currentQueue': queue, 'level': queue, 'assignee': null, 'dueAt': null,
      'resolvedAt': null, 'resolvedBy': null, 'resolutionNote': null, 'closedAt': null, 'updatedAt': at, 'version': 1,
      'timeline': [
        {'id': 'rte-${++_requestEventSeq}', 'kind': 'created', 'at': at, 'actor': _me, 'note': null, 'from': null, 'to': _queueTarget(queue), 'status': {'from': null, 'to': 'open'}},
      ],
    };
    serverChange('request', id, Map<String, dynamic>.of(requests[id]!));
    return {'mutationId': mutationId, 'result': 'applied', 'entityId': id};
  }

  String? _requestIdOf(Json payload) {
    final rid = payload['requestId'] as String?;
    if (rid != null) return rid;
    final cid = payload['requestClientId'] as String?;
    return requests.values.where((r) => r['clientId'] == cid).firstOrNull?['id'] as String?;
  }

  /// `request_comment` (1.48.0): `RequestComment` plus `requestId` or `requestClientId`; idempotent by the comment clientId.
  Json _requestCommentMutation(String mutationId, Json payload) {
    final id = _requestIdOf(payload);
    final r = id == null ? null : requests[id];
    if (r == null) return {'mutationId': mutationId, 'result': 'rejected', 'error': _problem(404, 'NOT_FOUND', 'No such request')};
    if (r['status'] == 'closed') return {'mutationId': mutationId, 'result': 'rejected', 'error': {..._problem(409, 'INVALID_STATE', 'closed'), 'details': {'reason': 'REQUEST_CLOSED'}}};
    final text = (payload['text'] as String?)?.trim() ?? '';
    if (text.isEmpty || text.length > 2000) return {'mutationId': mutationId, 'result': 'rejected', 'error': _problem(400, 'VALIDATION_FAILED', 'text')};
    if (_requestComments.add(payload['clientId'] as String)) {
      _requestStep(id!, 'comment', actor: _me, note: text);
      // The server keeps the comment's clientId so the phone can match its own copy.
      ((r['timeline'] as List).last as Json)['clientId'] = payload['clientId'];
      serverChange('request', id, Map<String, dynamic>.of(r));
    }
    return {'mutationId': mutationId, 'result': 'applied', 'entityId': id};
  }

  /// POST /requests/{id}/reopen (1.48.0): the creator, a resolved or closed request, a note.
  (int, Json) _reopenRequest(String id, Json body) {
    final r = requests[id];
    if (r == null) return (404, _problem(404, 'NOT_FOUND', 'No such request'));
    if (!['resolved', 'closed'].contains(r['status'])) return (409, {..._problem(409, 'INVALID_STATE', 'open'), 'details': {'reason': 'REQUEST_OPEN'}});
    final note = (body['note'] as String?)?.trim() ?? '';
    if (note.isEmpty) return (400, _problem(400, 'VALIDATION_FAILED', 'note'));
    _requestStep(id, 'reopened', actor: _me, note: note, to: _targetOf(r), status: 'reopened', patch: {'resolvedAt': null, 'resolvedBy': null, 'resolutionNote': null, 'closedAt': null});
    return (200, Map<String, dynamic>.of(r));
  }

  /// Possible customers (provisional contract 1.45.0): `prospect` create / update. Server id `pr-<clientId>`.
  final prospects = <String, Json>{};

  /// Tests / demo: the office changes a prospect's status (it then can no longer be changed by staff).
  void setProspectStatus(String clientId, String status) {
    final p = prospects['pr-$clientId']!;
    p['status'] = status;
    serverChange('prospect', 'pr-$clientId', Map<String, dynamic>.of(p));
  }

  /// `prospect` (contract 1.45.0): `ProspectCreate` only, idempotent by clientId; numbers stored as +8801XXXXXXXXX.
  /// Unknown fields are refused like field-api's strict schema.
  Json _prospectMutation(String mutationId, String op, Json payload) {
    Json invalid(String what) => {'mutationId': mutationId, 'result': 'rejected', 'error': _problem(400, 'VALIDATION_FAILED', what)};
    const allowed = {'clientId', 'name', 'phones', 'address', 'note', 'location', 'branchId', 'fromProspectId'};
    if (op != 'create' || payload.keys.any((k) => !allowed.contains(k))) return invalid('unknown field');
    final name = (payload['name'] as String?)?.trim() ?? '';
    final phones = (payload['phones'] as List?) ?? const [];
    if (name.isEmpty || name.length > 120 || phones.length > 5) return invalid('name or phones');
    final numbers = <String>[];
    for (final p in phones) {
      final n = p is Map ? p['number'] as String? : null;
      if (n == null || !RegExp(r'^01[3-9]\d{8}$').hasMatch(n)) return invalid('phones');
      numbers.add('+88$n');
    }
    final id = 'pr-${payload['clientId']}';
    if (prospects.containsKey(id)) return {'mutationId': mutationId, 'result': 'applied', 'entityId': id}; // replay
    prospects[id] = {
      'id': id,
      'clientId': payload['clientId'],
      'name': name,
      'phones': [for (final n in numbers) {'number': n, 'label': null}],
      'address': payload['address'],
      'note': payload['note'],
      'location': payload['location'],
      'branchId': 'b-1',
      'status': 'new',
      'history': [{'status': 'new', 'at': clock.nowUtc().toIso8601String(), 'by': {'id': user['id'], 'name': 'রহিম উদ্দিন'}}],
      'version': 1,
      'createdBy': {'id': user['id'], 'name': 'রহিম উদ্দিন'},
      'createdAt': clock.nowUtc().toIso8601String(),
    };
    serverChange('prospect', id, Map<String, dynamic>.of(prospects[id]!));
    return {'mutationId': mutationId, 'result': 'applied', 'entityId': id};
  }

  Json _placeMutation(String mutationId, String entity, Json payload) {
    Json? find() {
      final pid = payload['placeId'] as String?;
      if (pid != null) return _places[pid];
      final cid = payload['placeClientId'] as String?;
      return _places.values.where((p) => p['clientId'] == cid && (p['createdBy'] as Json)['id'] == user['id']).firstOrNull;
    }

    Json reject(int status, String code, String detail, {String? rule}) =>
        {'mutationId': mutationId, 'result': 'rejected', 'error': {..._problem(status, code, detail), if (rule != null) 'details': {'rule': rule, 'reason': rule}}};
    final at = clock.nowUtc().toIso8601String();
    if (entity == 'place') {
      final prior = _places.values.where((p) => p['clientId'] == payload['clientId']).firstOrNull;
      if (prior != null) return {'mutationId': mutationId, 'result': 'replayed', 'entityId': prior['id']};
      final loc = payload['location'] as Json;
      final lat = (loc['lat'] as num).toDouble(), lng = (loc['lng'] as num).toDouble();
      if (lat < 20.3 || lat > 26.8 || lng < 87.9 || lng > 92.8) return reject(422, 'BUSINESS_RULE', 'outside Bangladesh', rule: 'OUTSIDE_BANGLADESH');
      final id = 'pl-${_places.length + 1}';
      final p = {
        'id': id, 'clientId': payload['clientId'], 'branchId': 'br-01', 'name': payload['name'], 'icon': payload['icon'], 'note': payload['note'],
        'location': {'lat': lat, 'lng': lng}, 'status': 'active', 'version': 1, 'pendingMove': null, 'lastMoveDecision': null,
        'createdBy': _me, 'updatedBy': _me, 'createdAt': at, 'updatedAt': at, 'deletedAt': null, 'deleteReason': null,
        'events': [{'type': 'created', 'by': _me, 'at': at, 'note': null, 'from': null, 'to': {'lat': lat, 'lng': lng}}],
      };
      _places[id] = p;
      serverChange('place', id, p);
      return {'mutationId': mutationId, 'result': 'applied', 'entityId': id, 'version': 1};
    }
    final p = find();
    final moveTo = payload['location'] as Json?;
    // 1.43.0: a direct move (place_edit with location) on a removed place is 409 PLACE_DELETED.
    if (p != null && p['status'] == 'deleted' && entity == 'place_edit' && moveTo != null) {
      return reject(409, 'INVALID_STATE', 'Place deleted', rule: 'PLACE_DELETED');
    }
    if (p == null || p['status'] == 'deleted') return reject(404, 'NOT_FOUND', 'No such place');
    final id = p['id'] as String;
    if (entity == 'place_edit') {
      // place.manage edits and moves any place (1.42.0/1.43.0); field staff only change the words of their own.
      const allowed = {'placeId', 'placeClientId', 'name', 'icon', 'note', 'location'};
      if (payload.keys.any((k) => !allowed.contains(k))) return reject(400, 'VALIDATION_FAILED', 'Unknown field');
      if (moveTo != null && !placeManager) return reject(403, 'FORBIDDEN', 'place.manage needed', rule: 'MOVE_NEEDS_MANAGE');
      if (!placeManager && (p['createdBy'] as Json)['id'] != user['id']) return reject(403, 'FORBIDDEN', 'not your place', rule: 'NOT_OWNER');
      if (moveTo != null) {
        final lat = (moveTo['lat'] as num).toDouble(), lng = (moveTo['lng'] as num).toDouble();
        if (lat < 20.5 || lat > 26.7 || lng < 88.0 || lng > 92.7) return reject(422, 'BUSINESS_RULE', 'Outside Bangladesh', rule: 'OUTSIDE_BANGLADESH');
      }
      final pm = p['pendingMove'] as Json?;
      final loc = p['location'] as Json;
      final samePoint = moveTo != null && moveTo['lat'] == loc['lat'] && moveTo['lng'] == loc['lng'];
      final words = payload.keys.any((k) => const {'name', 'icon', 'note'}.contains(k));
      // 1.43.0: the same point again changes nothing (no version bump).
      if (samePoint && !words) return {'mutationId': mutationId, 'result': 'applied', 'entityId': id, 'version': p['version']};
      final next = {
        ...p,
        if (payload.containsKey('name')) 'name': payload['name'],
        if (payload.containsKey('icon')) 'icon': payload['icon'],
        if (payload.containsKey('note')) 'note': payload['note'],
        // A direct move closes an open request as rejected ("moved by the office").
        if (moveTo != null) ...{
          'location': {'lat': moveTo['lat'], 'lng': moveTo['lng']},
          'pendingMove': null,
          if (pm != null) 'lastMoveDecision': {'decision': 'reject', 'by': _me, 'at': at, 'reason': 'Moved by the office', 'requestedBy': pm['requestedBy']},
        },
        'version': (p['version'] as int) + 1,
        'updatedAt': at,
        'updatedBy': _me,
      };
      _places[id] = next;
      serverChange('place', id, next);
      return {'mutationId': mutationId, 'result': 'applied', 'entityId': id, 'version': next['version']};
    }
    // place_move_request
    final pm = p['pendingMove'] as Json?;
    if (pm != null) {
      if ((pm['requestedBy'] as Json)['id'] == user['id']) return {'mutationId': mutationId, 'result': 'replayed', 'entityId': id, 'status': 'pending'};
      return reject(409, 'INVALID_STATE', 'Another move request is open', rule: 'MOVE_PENDING');
    }
    final to = payload['location'] as Json;
    final next = {
      ...p,
      'pendingMove': {'location': to, 'requestedBy': _me, 'requestedAt': at, 'reason': payload['reason'], 'distanceM': 100},
      'version': (p['version'] as int) + 1,
      'updatedAt': at,
    };
    _places[id] = next;
    serverChange('place', id, next);
    return {'mutationId': mutationId, 'result': 'applied', 'entityId': id, 'status': 'pending'};
  }

  // ── tasks from the office (contract 1.20.0) ─────────────────────────────

  final _tasks = <String, Json>{};

  /// Tests / demo: the office gives me a task (free-form, not tied to a customer).
  void addTask(String id, {required String title, String? note, String? dueDate, DateTime? at}) {
    final when = (at ?? clock.nowUtc()).toIso8601String();
    final by = {'id': 'u-bm-001', 'name': 'মোস্তফা কামাল'};
    final t = {
      'id': id, 'branchId': 'br-01', 'assignee': {'id': user['id'], 'name': user['name'], 'employeeCode': 'FS-001'}, 'createdBy': by,
      'title': title, 'note': note, 'dueDate': dueDate, 'status': 'open', 'overdue': false, 'resolveNote': null, 'resolveRequestedAt': null,
      'decisionNote': null, 'decidedBy': null, 'decidedAt': null,
      'events': [{'type': 'created', 'by': by, 'at': when, 'note': null}],
      'createdAt': when, 'updatedAt': when,
    };
    _tasks[id] = t;
    serverChange('task', id, t);
  }

  /// Tests / demo: the office decides on a task: `verified`, `rejected` (with a reason) or `cancelled`.
  void decideTask(String id, {required String decision, String? note}) {
    final t = _tasks[id]!;
    final at = clock.nowUtc().toIso8601String();
    final by = {'id': 'u-bm-001', 'name': 'মোস্তফা কামাল'};
    final status = switch (decision) {
      'verified' => 'resolved',
      'cancelled' => 'cancelled',
      _ => 'open',
    };
    final next = {
      ...t,
      'status': status,
      'decisionNote': note,
      'decidedBy': by,
      'decidedAt': at,
      'updatedAt': at,
      'events': [...(t['events'] as List), {'type': decision, 'by': by, 'at': at, 'note': note}],
    };
    _tasks[id] = next;
    serverChange('task', id, next);
  }

  /// The staff member says the task is done: open → resolve_requested (a repeat is a replay).
  Json? _taskResolveRequest(Json payload) {
    final id = payload['taskId'] as String?;
    final t = id == null ? null : _tasks[id];
    if (t == null) return null;
    if (t['status'] != 'open') return t;
    final at = (payload['requestedAt'] as String?) ?? clock.nowUtc().toIso8601String();
    final next = {
      ...t,
      'status': 'resolve_requested',
      'resolveNote': payload['note'],
      'resolveRequestedAt': at,
      'updatedAt': clock.nowUtc().toIso8601String(),
      'events': [...(t['events'] as List), {'type': 'resolve_requested', 'by': {'id': user['id'], 'name': user['name']}, 'at': at, 'note': payload['note']}],
    };
    _tasks[id!] = next;
    serverChange('task', id, next);
    return next;
  }

  /// Tests / demo: the manager decides a leave request.
  void decideLeave(String id, {required bool approve, String? reason}) {
    final i = _leave.indexWhere((l) => l['id'] == id);
    _leave[i] = {..._leave[i], 'status': approve ? 'approved' : 'rejected', 'decidedBy': 'u-bm-001', 'decidedAt': clock.nowUtc().toIso8601String(), 'decisionReason': ?reason};
  }

  Object _leaveRoute(String method, String path, Object? body) {
    if (method == 'GET') return {'items': _leave.reversed.toList()};
    if (method == 'POST' && path == '/leave-requests') {
      final b = body! as Json;
      final from = b['from'] as String, to = b['to'] as String;
      if (to.compareTo(from) < 0) return (400, _problem(400, 'VALIDATION_FAILED', 'to before from'));
      final days = daysBetween(from, to) + 1;
      if (days > 31) return (422, {..._problem(422, 'BUSINESS_RULE', 'Too long'), 'details': {'rule': 'LEAVE_TOO_LONG', 'maxDays': 31}});
      final clash = _leave.any((l) => (l['status'] == 'pending' || l['status'] == 'approved') && (l['from'] as String).compareTo(to) <= 0 && (l['to'] as String).compareTo(from) >= 0);
      if (clash) return (409, {..._problem(409, 'INVALID_STATE', 'Overlaps'), 'details': {'reason': 'LEAVE_OVERLAPS'}});
      final r = <String, dynamic>{
        'id': 'lv-${++_leaveSeq}', 'userId': user['id'], 'branchId': 'br-01', 'type': b['type'], 'from': from, 'to': to, 'days': days,
        'reason': b['reason'] ?? '', 'status': 'pending', 'createdAt': clock.nowUtc().toIso8601String(),
      };
      _leave.add(r);
      return (201, r);
    }
    final m = RegExp(r'^/leave-requests/([^/]+)/cancel$').firstMatch(path);
    if (m != null && method == 'POST') {
      final i = _leave.indexWhere((l) => l['id'] == m.group(1));
      if (i < 0) return (404, _problem(404, 'NOT_FOUND', 'No such request'));
      final l = _leave[i];
      if (l['status'] == 'cancelled') return l;
      if (l['status'] != 'pending') return (409, {..._problem(409, 'INVALID_STATE', 'Decided'), 'details': {'reason': 'ALREADY_DECIDED'}});
      _leave[i] = {...l, 'status': 'cancelled', 'cancelledAt': clock.nowUtc().toIso8601String()};
      return _leave[i];
    }
    return (404, _problem(404, 'NOT_FOUND', 'No route'));
  }

  /// Tests / demo: the office voids one of my collections (by the phone's clientId), e.g. while a
  /// deposit is still on the phone; the cash leaves my hand.
  void officeVoid(String clientId) {
    final c = _srvCollections.firstWhere((x) => x['clientId'] == clientId);
    if (c['method'] == 'cash' && c['depositId'] == null) _cashOnHand -= _inHandOf(c);
    c['status'] = 'voided';
    c['voided'] = {'by': 'u-bm-001', 'byName': 'মোস্তফা কামাল', 'at': clock.nowUtc().toIso8601String(), 'reason': 'ভুল এন্ট্রি', 'kind': 'admin'};
    _collectionChanged(c);
  }

  /// Simulates an office-side change (e.g. a new handover) for demos/tests.
  void serverChange(String entity, String id, Json data, {String op = 'upsert'}) =>
      _log.add(_Change(entity, id, op, data));

  /// Tests / demo: the server marks a promise broken (FR-PRM-003) and sends it on the change feed with the
  /// follow-up fields of contract 1.45.0.
  /// [followUpId]: somebody (e.g. a colleague) already followed it up on the server.
  void breakPromise(String mutationId, {String? followUpId}) {
    final p = appliedPayloads[mutationId]!;
    serverChange('promise', 'promise-$mutationId', {
      ...p,
      'id': 'promise-$mutationId',
      'status': 'broken',
      'attempt': _promiseAttempt(p),
      'followUpId': followUpId,
      'chainRootId': 'promise-$mutationId',
      'createdAt': clock.nowUtc().toIso8601String(),
    });
  }

  /// 1.45.0: a follow-up is one attempt after the promise it names; a promise without `followUpOf` is attempt 1.
  int _promiseAttempt(Json p) {
    final of = p['followUpOf'] as String?;
    if (of == null) return 1;
    final prev = appliedPayloads[of.replaceFirst('promise-', '')];
    return prev == null ? 2 : _promiseAttempt(prev) + 1;
  }

  /// Tests / demo: a manager decides a pin proposal (contract 1.7.0).
  void decideProposal(String clientId, String status, {String? reason}) {
    final last = _log.lastWhere((c) => c.entity == 'location_proposal' && c.data?['clientId'] == clientId);
    serverChange('location_proposal', last.id, {...last.data!, 'status': status, 'decisionReason': reason, 'decidedAt': clock.nowUtc().toIso8601String()});
    if (status == 'approved') _applyPin(last.data!['customerId'] as String, (last.data!['lat'] as num).toDouble(), (last.data!['lng'] as num).toDouble());
  }

  /// The customer as the server has it now (latest change).
  Json? _customer(String id) => _log.lastWhere((c) => c.entity == 'customer' && c.id == id, orElse: () => _Change('customer', id, 'upsert', null)).data;

  /// An applied pin reaches the phone as a customer change (1.11.0).
  void _applyPin(String customerId, double lat, double lng) {
    final c = _customer(customerId);
    if (c == null) return;
    serverChange('customer', customerId, {...c, 'location': {'lat': lat, 'lng': lng, 'status': 'overridden', 'source': 'overlay'}});
  }

  String _nameOf(String userId) => userId == user['id']
      ? (user['name'] as Map)['bn'] as String
      : (colleagues.firstWhere((c) => c['id'] == userId, orElse: () => {'name': userId})['name'] as String);

  Json _member(String userId, String status, String invitedBy) => {
        'userId': userId,
        'name': _nameOf(userId),
        'status': status,
        'invitedBy': invitedBy,
        'invitedAt': clock.nowUtc().toIso8601String(),
        'respondedAt': status == 'invited' ? null : clock.nowUtc().toIso8601String(),
        'leftAt': null,
      };

  List<Json> _members(Json s) => (s['members'] as List).cast<Json>();

  /// Stores a session and sends it on pull to every invited/member user.
  Json _saveCowork(Json s) {
    final members = _members(s);
    final accepted = members.where((m) => m['status'] == 'accepted').length;
    final invited = members.where((m) => m['status'] == 'invited').length;
    if (s['status'] == 'open' && (accepted == 0 || (accepted < 2 && invited == 0))) {
      s = {...s, 'status': 'ended', 'endedAt': clock.nowUtc().toIso8601String()};
    }
    _cowork[s['id'] as String] = s;
    serverChange('cowork_session', s['id'] as String, s);
    return s;
  }

  Json? _openSessionOf(String userId) => _cowork.values
      .where((s) => s['status'] == 'open' && _members(s).any((m) => m['userId'] == userId && m['status'] == 'accepted'))
      .firstOrNull;

  Json _newSession(String createdBy, String? note) => {
        'id': 'cw-${++_coworkSeq}',
        'businessDate': clock.businessDate(),
        'branchId': 'br-01',
        'status': 'open',
        'createdBy': createdBy,
        'note': note,
        'members': [_member(createdBy, 'accepted', createdBy)],
        'createdAt': clock.nowUtc().toIso8601String(),
        'endedAt': null,
      };

  /// Tests / demo: colleague [fromUserId] asks me to work together.
  String coworkInviteFrom(String fromUserId, {String? note}) {
    final s = _openSessionOf(fromUserId) ?? _newSession(fromUserId, note);
    final members = [..._members(s).where((m) => m['userId'] != user['id']), _member(user['id']! as String, 'invited', fromUserId)];
    return _saveCowork({...s, 'members': members})['id'] as String;
  }

  /// Tests / demo: a colleague answers or leaves.
  void coworkMemberSets(String sessionId, String userId, String status) {
    final s = _cowork[sessionId]!;
    _saveCowork({
      ...s,
      'members': [
        for (final m in _members(s))
          if (m['userId'] == userId)
            {...m, 'status': status, 'respondedAt': clock.nowUtc().toIso8601String(), if (status == 'left') 'leftAt': clock.nowUtc().toIso8601String()}
          else
            m,
      ],
    });
  }

  /// Tests / demo: a partner records a co-work visit I took part in.
  void coworkPartnerVisit(String sessionId, String recorderId, String customerId) {
    final id = 'v-cw-${++_coworkSeq}';
    final others = [for (final m in _members(_cowork[sessionId]!)) if (m['status'] == 'accepted' && m['userId'] != recorderId) m['userId']];
    serverChange('visit', id, {
      'id': id,
      'clientId': 'client-$id',
      'userId': recorderId,
      'customerId': customerId,
      'checkInAt': clock.nowUtc().toIso8601String(),
      'outcome': 'not_home',
      'geo': null,
      'flags': const <String>[],
      'coWorkSessionId': sessionId,
      'coWork': {'sessionId': sessionId, 'participantIds': others},
    });
  }

  Object _coworkRoute(String method, String path, Object? body) {
    final me = user['id']! as String;
    if (method == 'GET' && path == '/cowork/colleagues') {
      return [
        for (final c in colleagues) {...c, 'inSession': _openSessionOf(c['id'] as String) != null},
      ];
    }
    if (method == 'GET' && path == '/cowork/sessions/mine') {
      return [
        for (final s in _cowork.values.toList().reversed)
          if (s['businessDate'] == clock.businessDate() && _members(s).any((m) => m['userId'] == me && m['status'] != 'rejected')) s,
      ];
    }
    if (method == 'POST' && path == '/cowork/requests') {
      final b = body! as Json;
      final replay = _coworkClientIds[b['clientId']];
      if (replay != null) return (200, _cowork[replay]!);
      final to = (b['toUserIds'] as List).cast<String>();
      if (to.any((id) => id == me || !colleagues.any((c) => c['id'] == id))) {
        return (422, {..._problem(422, 'BUSINESS_RULE', 'Invalid invitee'), 'details': {'rule': 'COWORK_INVALID_INVITEE'}});
      }
      final s = _openSessionOf(me) ?? _newSession(me, b['note'] as String?);
      final members = _members(s).map((m) => {...m}).toList();
      for (final id in to) {
        final m = members.where((x) => x['userId'] == id).firstOrNull;
        if (m != null && (m['status'] == 'accepted' || m['status'] == 'invited')) continue;
        members.removeWhere((x) => x['userId'] == id);
        members.add(_member(id, 'invited', me));
      }
      if (members.where((m) => m['status'] == 'accepted' || m['status'] == 'invited').length > coworkMaxMembers) {
        return (422, {..._problem(422, 'BUSINESS_RULE', 'Too many'), 'details': {'rule': 'COWORK_TOO_MANY', 'max': coworkMaxMembers}});
      }
      final saved = _saveCowork({...s, 'members': members});
      _coworkClientIds[b['clientId'] as String] = saved['id'] as String;
      return (201, saved);
    }
    final m = RegExp(r'^/cowork/sessions/([^/]+)/(respond|leave)$').firstMatch(path);
    if (m != null && method == 'POST') {
      final s = _cowork[m.group(1)];
      if (s == null) return (404, _problem(404, 'NOT_FOUND', 'No session'));
      final mine = _members(s).where((x) => x['userId'] == me).firstOrNull;
      if (m.group(2) == 'leave') {
        if (mine == null || mine['status'] == 'left' || mine['status'] == 'rejected') return (200, s);
        coworkMemberSets(s['id'] as String, me, mine['status'] == 'invited' ? 'rejected' : 'left');
        return (200, _cowork[s['id']]!);
      }
      final accept = (body! as Json)['decision'] == 'accept';
      if (s['status'] != 'open') return (409, {..._problem(409, 'INVALID_STATE', 'Ended'), 'details': {'reason': 'SESSION_ENDED'}});
      if (mine == null) return (409, {..._problem(409, 'INVALID_STATE', 'Not invited'), 'details': {'reason': 'NOT_INVITED'}});
      if (mine['status'] == (accept ? 'accepted' : 'rejected')) return (200, s);
      if (mine['status'] != 'invited') return (409, {..._problem(409, 'INVALID_STATE', 'Not invited'), 'details': {'reason': 'NOT_INVITED'}});
      final other = _openSessionOf(me);
      if (accept && other != null && other['id'] != s['id']) {
        return (409, {..._problem(409, 'INVALID_STATE', 'Already in a session'), 'details': {'reason': 'ALREADY_IN_SESSION'}});
      }
      coworkMemberSets(s['id'] as String, me, accept ? 'accepted' : 'rejected');
      return (200, _cowork[s['id']]!);
    }
    return (404, _problem(404, 'NOT_FOUND', 'No route'));
  }

  /// Work-out leaves the open session (FR-CW-002).
  void _leaveCoworkOnWorkOut() {
    final me = user['id']! as String;
    final s = _openSessionOf(me);
    if (s != null) coworkMemberSets(s['id'] as String, me, 'left');
  }

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
    final isStorage = o.uri.path.endsWith('/storage/o');
    final body = isStorage ? null : await _readBody(o, requestStream);
    final path = o.uri.path.replaceFirst(RegExp(r'^.*/api/v1'), '');
    requestLog.add('${o.method} $path');
    if (upgradeRequired && path != '/meta/app-config') {
      return _json(426, _problem(426, 'UPGRADE_REQUIRED', 'Update required'));
    }
    final auth = o.headers['Authorization'] as String?;
    final authed = auth != null && _tokens.contains(auth.replaceFirst('Bearer ', ''));
    final public = {'/meta/app-config', '/auth/login', '/auth/refresh', '/system/health'};
    if (isStorage) return _storagePut(o, requestStream);
    if (!public.contains(path) && !authed) {
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
        if (loginRefusal case final r?) return _json(r.status, r.body);
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
        // The real shape (contract SyncBootstrapResponse): `items`, a paging `nextCursor` (null on the last page)
        // and `pullCursor` on the last page only. Before 0.12.4 the fake answered like /sync/pull and hid a bug.
        final from = int.tryParse((o.queryParameters['cursor'] ?? '').toString().replaceFirst('b', '')) ?? 0;
        final page = _page(from, bootstrap: true);
        final end = int.parse(page.remove('nextCursor') as String);
        final more = page.remove('hasMore') as bool;
        page['items'] = page.remove('changes');
        page['nextCursor'] = more ? 'b$end' : null;
        if (!more) page['pullCursor'] = '$end';
        return _json(200, page);
      case ('GET', '/sync/pull'):
        if (expireCursor) {
          expireCursor = false;
          return _json(410, _problem(410, 'CURSOR_EXPIRED', 'Cursor expired'));
        }
        final cursor = int.tryParse(o.queryParameters['cursor'].toString());
        // Like the server: a snapshot cursor (or anything else) is not a pull cursor.
        if (cursor == null) return _json(400, _problem(400, 'VALIDATION_FAILED', 'Bad cursor'));
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
      case ('POST', '/location/tracking-token'):
        // 1.49.0: no body; a points-only token bound to the session's device, valid about 24 h; rotates.
        final token = 'trk_fake${trackingTokenRequests.length + 1}';
        trackingTokenRequests.add(token);
        return _json(200, {'token': token, 'expiresAt': clock.nowUtc().add(const Duration(hours: 24)).toIso8601String()});
      case ('POST', '/location/heartbeat'):
        heartbeats.add(body as Json);
        return _json(204, null);
      case ('POST', '/media/upload-url'):
        // Validated like field-api: required fields, the enums, size ≤ 1 MiB and RFC 3339 times WITH an offset.
        final b = body as Json;
        presignBodies.add(b);
        final bad = <String>[
          if (!const {'visit_photo', 'deposit_slip', 'selfie', 'location_proof', 'refund_proof', 'voice_note'}.contains(b['kind'])) 'kind',
          if (!const {'image/jpeg', 'image/webp', 'audio/aac', 'audio/mp4'}.contains(b['contentType'])) 'contentType',
          if (b['sizeBytes'] is! int || (b['sizeBytes'] as int) <= 0 || (b['sizeBytes'] as int) > 1048576) 'sizeBytes',
          if (b['sha256'] is! String || !RegExp(r'^[0-9a-f]{64}$').hasMatch(b['sha256'] as String)) 'sha256',
          if (b.containsKey('capturedAt') && !isRfc3339(b['capturedAt'])) 'capturedAt',
        ];
        if (bad.isNotEmpty) {
          return _json(400, {..._problem(400, 'VALIDATION_FAILED', 'Invalid request'), 'errors': [for (final f in bad) {'path': f, 'message': 'invalid'}]});
        }
        final sha = b['sha256'] as String;
        final known = _mediaBySha[sha];
        final exists = known != null && _storedMedia.contains(known);
        final id = known ?? 'm-${++_mediaSeq}';
        _mediaBySha[sha] = id;
        if (exists) return _json(201, {'mediaId': id, 'alreadyExists': true});
        final t = 'g${_grants.length + 1}.${base64Url.encode(utf8.encode(id)).replaceAll('=', '')}';
        _grants[t] = (mediaId: id, size: b['sizeBytes'] as int, sha256: sha, contentType: b['contentType'] as String);
        final url = '/api/v1/storage/o?t=$t';
        return _json(201, {
          'mediaId': id,
          'alreadyExists': false,
          'uploadUrl': relativeUploadUrl ? url : 'https://demo.invalid$url',
          'headers': {'Content-Type': b['contentType']},
          'expiresAt': clock.nowUtc().add(const Duration(minutes: 5)).toIso8601String(),
        });
      default:
        final mc = RegExp(r'^/media/([^/]+)/confirm$').firstMatch(path);
        if (mc != null && o.method == 'POST') {
          // field-api: confirming a photo whose bytes never arrived is 409 INVALID_STATE.
          if (!_storedMedia.contains(mc.group(1))) return _json(409, {..._problem(409, 'INVALID_STATE', 'Upload not received'), 'details': {'reason': 'NOT_UPLOADED'}});
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
        final rp = RegExp(r'^/customers/([^/]+)/phones/([^/]+)$').firstMatch(path);
        if (rp != null && o.method == 'DELETE') {
          // Server rules (1.23.0): an added number goes; an ERP number answers 422 PHONE_FROM_ERP; unknown is 404.
          final c = _customer(rp.group(1)!);
          final number = rp.group(2)!.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^88'), '');
          if (c == null) return _json(404, _problem(404, 'NOT_FOUND', 'Customer not found'));
          final details = ((c['phoneDetails'] as List?)?.cast<Json>() ??
              [for (final n in <String>{if (c['phone'] != null) c['phone'] as String, ...((c['phones'] as List?) ?? const []).cast<String>()}) {'number': n, 'source': 'erp'}]);
          final hit = details.where((d) => d['number'] == number).firstOrNull;
          if (hit == null) return _json(200, {});
          if (hit['source'] == 'erp') return _json(422, {..._problem(422, 'BUSINESS_RULE', 'An ERP number cannot be removed'), 'details': {'rule': 'PHONE_FROM_ERP'}});
          final next = [for (final d in details) if (d['number'] != number) d];
          serverChange('customer', c['id'] as String, {...c, 'phones': [for (final d in next) d['number']], 'phoneDetails': next});
          return _json(200, {});
        }
        final rr = RegExp(r'^/requests/([^/]+)/reopen$').firstMatch(path);
        if (rr != null && o.method == 'POST') {
          final r = _reopenRequest(rr.group(1)!, (body as Json?) ?? const {});
          return _json(r.$1, r.$2);
        }
        final cw = RegExp(r'^/collections/([^/]+)(/withdraw)?$').firstMatch(path);
        if (cw != null && ((o.method == 'POST' && cw.group(2) != null) || (o.method == 'PATCH' && cw.group(2) == null))) {
          final r = _changeCollection(cw.group(1)!, withdraw: cw.group(2) != null, body: (body as Json?) ?? const {});
          return _json(r.$1, r.$2);
        }
        if (o.method == 'GET' && path == '/cash/me/collections') {
          return _json(200, _cashInHand());
        }
        if (o.method == 'GET' && path == '/reports/me/performance') {
          return _json(200, _performance(o.queryParameters['month'] as String));
        }
        if (o.method == 'GET' && path == '/reports/collection-board') {
          final r = _collectionBoard((o.queryParameters['period'] as String?) ?? 'month');
          if (r is (int, Json)) return _json(r.$1, r.$2);
          return _json(200, r);
        }
        if (o.method == 'GET' && path == '/reports/leaderboard') {
          final r = _leaderboard((o.queryParameters['period'] as String?) ?? 'month', (o.queryParameters['metric'] as String?) ?? 'collected');
          if (r is (int, Json)) return _json(r.$1, r.$2);
          return _json(200, r);
        }
        if (path.startsWith('/leave-requests')) {
          final r = _leaveRoute(o.method, path, body);
          if (r is (int, Json)) return _json(r.$1, r.$2);
          return _json(200, r);
        }
        if (o.method == 'GET' && path == '/calendar/holidays') {
          final year = '${o.queryParameters['year']}';
          final branch = o.queryParameters['branchId'] as String?;
          return _json(200, [
            for (final h in holidays)
              if ((h['date'] as String).startsWith('$year-') && (branch == null || (h['branchIds'] as List).isEmpty || (h['branchIds'] as List).contains(branch))) h,
          ]..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String)));
        }
        if (o.method == 'GET' && path == '/attendance/me/shift') return _json(200, myShift);
        if (o.method == 'GET' && path == '/attendance/me/today') {
          meTodayCalls++;
          return _json(200, {'status': todayAttendanceEvents.isEmpty ? 'not_started' : 'on_duty', 'events': todayAttendanceEvents});
        }
        if (path.startsWith('/cowork/')) {
          final r = _coworkRoute(o.method, path, body);
          if (r is (int, Json)) return _json(r.$1, r.$2);
          return _json(200, r);
        }
        final cr = RegExp(r'^/customers/([^/]+)/refresh$').firstMatch(path);
        if (cr != null) {
          customerRefreshCalls++;
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
      'permissions': _permissions,
      'flags': flags,
      'serverTime': clock.nowUtc().toIso8601String(),
      if (attendanceRequired != null) 'attendanceRequired': attendanceRequired,
    };
  }

  /// Page size of a fake bootstrap (tests make it small to page).
  int bootstrapPageSize = 500;

  Json _page(int cursor, {bool bootstrap = false}) {
    final pageSize = bootstrap ? bootstrapPageSize : 500;
    final start = cursor;
    final end = (start + pageSize).clamp(0, _log.length);
    final changes = [
      for (var i = start; i < end; i++)
        {'seq': i + 1, 'entity': _log[i].entity, 'op': _log[i].op, 'id': _log[i].id, 'data': _log[i].data},
    ];
    return {
      'changes': changes,
      'nextCursor': '$end',
      'hasMore': end < _log.length,
      'permissions': {'version': 1, 'keys': _permissions},
      if (attendanceRequired != null) 'attendanceRequired': attendanceRequired,
      'flags': flags,
      'settings': _settings,
      'cash': {
        'userId': user['id'],
        'onHandPoisha': _cashOnHand,
        'limitPoisha': _limit,
        'state': _cashOnHand >= _limit ? 'exceeded' : (_cashOnHand >= _limit * 0.8 ? 'warning' : 'ok'),
        'pendingDepositsPoisha': 0,
      },
      'target': {
        'businessDate': clock.businessDate(),
        'amountPoisha': workingDay ? targetPoisha : 0,
        'visits': workingDay ? targetVisits : 0,
        'source': 'personal',
        'workingDay': workingDay,
      },
      'serverTime': clock.nowUtc().toIso8601String(),
    };
  }

  // ── reports (1.10.0): deterministic demo figures ────────────────────────

  /// Friday is the weekly off in the demo branch.
  bool _working(DateTime d) => d.weekday != DateTime.friday;

  Json _performance(String month) {
    final p = month.split('-').map(int.parse).toList();
    final today = clock.businessDate();
    final t = today.split('-').map(int.parse).toList();
    final current = p[0] == t[0] && p[1] == t[1];
    final lastDay = current ? t[2] : DateTime.utc(p[0], p[1] + 1, 0).day;
    final monthDays = DateTime.utc(p[0], p[1] + 1, 0).day;
    final days = <Json>[];
    var total = 0, solo = 0, joint = 0, present = 0, targetToDate = 0, visitTargetToDate = 0;
    for (var day = 1; day <= lastDay; day++) {
      final date = DateTime.utc(p[0], p[1], day);
      final ymd = '${p[0]}-${p[1].toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final work = _working(date);
      final isToday = ymd == today;
      final collected = !work ? 0 : (isToday ? _collectedToday : (targetPoisha * (55 + (day * 37) % 60) / 100).round() ~/ 100 * 100);
      final s = !work ? 0 : (isToday ? 0 : 10 + (day * 7) % 9);
      final j = !work ? 0 : (isToday ? 0 : (day * 3) % 5);
      if (work) {
        present++;
        targetToDate += targetPoisha;
        visitTargetToDate += targetVisits;
      }
      total += collected;
      solo += s;
      joint += j;
      days.add({
        'date': ymd, 'collectedPoisha': collected, 'collectionsCount': collected ~/ 250000, 'visits': s + j, 'soloVisits': s, 'coWorkVisits': j,
        'visitCredit': s + j, 'targetPoisha': work ? targetPoisha : 0, 'visitTarget': work ? targetVisits : 0, 'workingDay': work,
      });
    }
    final workingInMonth = [for (var d = 1; d <= monthDays; d++) if (_working(DateTime.utc(p[0], p[1], d))) d].length;
    final pending = current ? _collectedToday + 1250000 : 0;
    return {
      'month': month,
      'row': {
        'userId': user['id'], 'collectedPoisha': {'cash': total},
        'targetPoisha': targetPoisha * workingInMonth, 'visitTarget': targetVisits * workingInMonth,
        'targetToDatePoisha': targetToDate, 'visitTargetToDate': visitTargetToDate,
        'amountAchievement': targetToDate == 0 ? null : (total / targetToDate * 100).round() / 100,
        'visitAchievement': visitTargetToDate == 0 ? null : ((solo + joint) / visitTargetToDate * 100).round() / 100,
        'soloVisits': solo, 'coWorkVisits': joint, 'visitCredit': solo + joint,
        'promisesKept': 14, 'promisesDue': 19, 'presentDays': present, 'lateDays': 2,
      },
      'collectedTotalPoisha': total,
      'postedPoisha': total - pending.clamp(0, total),
      'pendingPoisha': pending.clamp(0, total),
      'days': days,
      'rank': leaderboardVisible ? {'metric': 'collected', 'rank': 2, 'of': 4} : null,
    };
  }

  Object _leaderboard(String period, String metric) {
    if (!leaderboardVisible) return (403, _problem(403, 'FORBIDDEN', 'Leaderboard not visible to staff'));
    final scale = period == 'day' ? 1 : 12;
    final people = <Json>[
      {'userId': 'u-fs-020', 'name': 'সজীব আহমেদ', 'employeeCode': 'FS020', 'collected': 5150000, 'credit': 23.5, 'promises': 6, 'ach': 1.12, 'present': 1},
      {'userId': user['id'], 'name': (user['name'] as Map)['bn'], 'employeeCode': 'FS014', 'collected': 4380000, 'credit': 21.0, 'promises': 5, 'ach': 1.04, 'present': 1},
      {'userId': 'u-fs-021', 'name': 'তানভীর ইসলাম', 'employeeCode': 'FS021', 'collected': 4380000, 'credit': 18.0, 'promises': 3, 'ach': 0.95, 'present': 1},
      {'userId': 'u-fs-022', 'name': 'মাহমুদা আক্তার', 'employeeCode': 'FS022', 'collected': 3120000, 'credit': 19.5, 'promises': 4, 'ach': 0.78, 'present': 1},
      {'userId': 'u-fs-023', 'name': 'রুবেল মিয়া', 'employeeCode': 'FS023', 'collected': 0, 'credit': 0.0, 'promises': 0, 'ach': 0.0, 'present': 0},
    ];
    num value(Json r) => switch (metric) {
          'visit_credit' => (r['credit'] as num) * scale,
          'promises_kept' => (r['promises'] as num) * scale,
          'target_achievement' => r['ach'] as num,
          _ => (r['collected'] as num) * scale,
        };
    final eligible = [for (final r in people) if ((r['present'] as int) >= 1) r]..sort((a, b) => value(b).compareTo(value(a)));
    final rows = <Json>[];
    for (var i = 0; i < eligible.length; i++) {
      final r = eligible[i];
      final rank = i > 0 && value(eligible[i - 1]) == value(r) ? rows[i - 1]['rank'] as int : i + 1;
      rows.add(_leaderRow(r, value(r), rank, scale));
    }
    for (final r in people.where((r) => (r['present'] as int) < 1)) {
      rows.add(_leaderRow(r, value(r), null, scale));
    }
    final me = rows.firstWhere((r) => r['me'] == true);
    return {'period': period, 'metric': metric, 'minPresentDays': 1, 'items': rows, 'me': {'rank': me['rank'], 'of': eligible.length}};
  }

  /// Contract 1.27.0: deposits pay off the oldest cash first; the rest, newest first.
  Json _cashInHand() {
    var left = _cashOnHand;
    final items = <Json>[];
    for (final c in _cashRows.toList().reversed) {
      if (left <= 0) break;
      final amount = c['amountPoisha'] as int;
      final at = (c['recordedAt'] as String?) ?? clock.nowUtc().toIso8601String();
      final part = left < amount ? left : amount;
      left -= part;
      items.add({
        'collectionId': c['collectionId'], 'receiptNo': c['receiptNo'] ?? '', 'recordedAt': at, 'businessDate': at.substring(0, 10),
        'customer': {'id': c['customerId'], 'name': {'bn': 'গ্রাহক ${c['customerId']}', 'en': 'Customer ${c['customerId']}'}, 'code': '${c['customerId']}'.toUpperCase()},
        'erpPlanId': c['erpPlanId'] ?? '', 'amountPoisha': amount, 'inHandPoisha': part, 'status': 'received',
      });
    }
    return {'userId': user['id'], 'userName': 'FS014', 'onHandPoisha': _cashOnHand - left, 'pendingDepositsPoisha': 0, 'count': items.length, 'items': items, 'generatedAt': clock.nowUtc().toIso8601String()};
  }

  /// Contract 1.26.0: money the ERP has accepted, every branch, any role.
  Object _collectionBoard(String period) {
    if (!leaderboardVisible) return (403, _problem(403, 'FORBIDDEN', 'Leaderboard not visible to staff'));
    final scale = period == 'all' ? 9 : 1;
    final people = <Json>[
      {'userId': 'u-fs-020', 'name': {'bn': 'সজীব আহমেদ', 'en': 'Sajib Ahmed'}, 'employeeCode': 'FS020', 'role': 'field_staff', 'posted': 4980000, 'count': 61},
      {'userId': 'u-bm-002', 'name': {'bn': 'নাসরিন সুলতানা', 'en': 'Nasrin Sultana'}, 'employeeCode': 'BM002', 'role': 'branch_manager', 'posted': 4980000, 'count': 18},
      {'userId': user['id'], 'name': user['name'], 'employeeCode': 'FS014', 'role': 'field_staff', 'posted': 4150000, 'count': 54},
      {'userId': 'u-fs-101', 'name': {'bn': 'কামরুল হাসান', 'en': 'Kamrul Hasan'}, 'employeeCode': 'FS101', 'role': 'field_staff', 'posted': 3900000, 'count': 47},
      {'userId': 'u-fs-023', 'name': {'bn': 'রুবেল মিয়া', 'en': 'Rubel Mia'}, 'employeeCode': 'FS023', 'role': 'field_staff', 'posted': 0, 'count': 0},
    ]..sort((a, b) => (b['posted'] as int).compareTo(a['posted'] as int));
    final rows = <Json>[];
    for (var i = 0; i < people.length; i++) {
      final r = people[i];
      final posted = (r['posted'] as int) * scale;
      final int? rank = posted == 0 ? null : (i > 0 && people[i - 1]['posted'] == r['posted'] ? rows[i - 1]['rank'] as int? : i + 1);
      rows.add({
        'rank': rank, 'userId': r['userId'], 'name': r['name'], 'employeeCode': r['employeeCode'], 'role': r['role'], 'branchId': 'br-1',
        'postedPoisha': posted, 'count': (r['count'] as int) * scale, 'me': r['userId'] == user['id'],
      });
    }
    final me = rows.firstWhere((r) => r['me'] == true);
    return {
      'period': period, 'month': period == 'all' ? null : clock.businessDate().substring(0, 7), 'scope': 'all', 'branchId': null,
      'generatedAt': clock.nowUtc().toIso8601String(), 'items': rows,
      'me': {'rank': me['rank'], 'of': rows.where((r) => r['rank'] != null).length, 'postedPoisha': me['postedPoisha']},
    };
  }

  Json _leaderRow(Json r, num value, int? rank, int scale) => {
        'rank': rank, 'userId': r['userId'], 'name': r['name'], 'employeeCode': r['employeeCode'], 'value': value,
        'collectedPoisha': (r['collected'] as int) * scale, 'visitCredit': (r['credit'] as num) * scale, 'promisesKept': (r['promises'] as int) * scale,
        'amountAchievement': r['ach'], 'presentDays': r['present'], 'eligible': rank != null, 'me': r['userId'] == user['id'],
      };

  Json _rule(String rule, [Json extra = const {}]) => {..._problem(422, 'BUSINESS_RULE', 'Business rule'), 'details': {'rule': rule, ...extra}};

  /// The part of a cash collection still in hand (older cash is handed in first, 1.27.0).
  int _inHandOf(Json c) {
    var left = _cashOnHand;
    for (final r in _cashRows.toList().reversed) {
      final amount = r['amountPoisha'] as int;
      final part = left < amount ? left : amount;
      if (identical(r, c)) return part;
      left -= part;
    }
    return 0;
  }

  /// The collection as the change feed carries it (contract `Collection`, 1.35.0 deposit fields).
  void _collectionChanged(Json c) {
    if (c['clientId'] == null) return; // made before this phone (seed): not on the phone
    serverChange('collection', c['collectionId'] as String, {
      ...c,
      'id': c['collectionId'],
      'collector': {'id': user['id'], 'name': _nameOf(user['id']! as String)},
      'receivedAt': c['recordedAt'],
    });
  }

  /// 1.35.0: change (PATCH) or withdraw a collection of any method until a deposit hands it in.
  (int, Json) _changeCollection(String id, {required bool withdraw, required Json body}) {
    final c = _srvCollections.where((x) => x['collectionId'] == id).firstOrNull;
    if (c == null) return (404, _problem(404, 'NOT_FOUND', 'Collection not found'));
    Json state(String reason) => {..._problem(409, 'INVALID_STATE', 'Invalid state'), 'details': {'reason': reason, 'status': c['status']}};
    if (withdraw && c['status'] == 'voided') return (200, c);
    if (c['status'] != 'received') return (409, state(withdraw ? 'ALREADY_POSTED_OR_CLOSED' : 'NOT_EDITABLE'));
    final amount = c['amountPoisha'] as int;
    if (c['depositId'] != null || (c['method'] == 'cash' && _inHandOf(c) < amount)) return (409, state('COVERED_BY_DEPOSIT'));
    if (withdraw) {
      if (c['method'] == 'cash') _cashOnHand -= amount;
      c['status'] = 'voided';
      c['voided'] = {'by': user['id'], 'byName': _nameOf(user['id']! as String), 'at': clock.nowUtc().toIso8601String(), 'reason': body['reason'] ?? 'Withdrawn by the collector', 'kind': 'withdrawn'};
    } else {
      final next = (body['amountPoisha'] as int?) ?? amount;
      if (c['method'] == 'cash') _cashOnHand += next - amount;
      if (next != amount) c['edited'] = {'count': 1, 'at': clock.nowUtc().toIso8601String(), 'by': user['id'], 'previousAmountPoisha': (c['edited'] as Json?)?['previousAmountPoisha'] ?? amount};
      c['amountPoisha'] = next;
      if (body.containsKey('note')) c['note'] = body['note'];
      if (body.containsKey('payerName')) c['payerName'] = body['payerName'];
    }
    _collectionChanged(c);
    return (200, c);
  }

  /// 1.35.0 (FR-CASH-010): a deposit hands in all the cash and every other collection not handed in
  /// yet; it is `submitted` and final, and each collection then goes to the ERP.
  Json _deposit(String mutationId, Json payload) {
    final amount = payload['amountPoisha'] as int;
    if (payload['destination'] == 'bank' && payload['slipMediaId'] == null) {
      return {'mutationId': mutationId, 'result': 'rejected', 'error': _rule('SLIP_REQUIRED')};
    }
    if (amount > _cashOnHand) return {'mutationId': mutationId, 'result': 'rejected', 'error': _rule('DEPOSIT_EXCEEDS_ON_HAND', {'onHandPoisha': _cashOnHand})};
    if (amount < _cashOnHand) return {'mutationId': mutationId, 'result': 'rejected', 'error': _rule('DEPOSIT_MUST_BE_ALL', {'onHandPoisha': _cashOnHand})};
    final cash = _cashOnHand > 0 ? [for (final c in _cashRows.toList()) if (_inHandOf(c) > 0) c] : const <Json>[];
    final other = _srvCollections.where((c) => c['method'] != 'cash' && c['status'] == 'received' && c['depositId'] == null).toList();
    if (cash.isEmpty && other.isEmpty) return {'mutationId': mutationId, 'result': 'rejected', 'error': _rule('NOTHING_TO_DEPOSIT')};
    final id = 'dep-${++_depositSeq}';
    final at = clock.nowUtc().toIso8601String();
    for (final c in [...cash, ...other]) {
      c['depositId'] = id;
      c['depositedAt'] = at;
      // ERP posting is on in the demo: it goes at once.
      c['status'] = 'posted';
      c['erpReceiptNo'] = 'ERP-${c['receiptNo']}';
      _collectionChanged(c);
    }
    _cashOnHand = 0;
    final nonCash = other.fold<int>(0, (n, c) => n + (c['amountPoisha'] as int));
    serverChange('deposit', id, {
      ...payload, 'id': id, 'userId': user['id'], 'status': 'submitted',
      'collectionCount': cash.length + other.length, 'nonCashPoisha': nonCash, 'nonCashCount': other.length,
    });
    return {'mutationId': mutationId, 'result': 'applied', 'entityId': id, 'status': 'submitted'};
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
      if (transientRejects > 0) {
        transientRejects--;
        results.add({'mutationId': id, 'result': 'rejected', 'retryable': true, 'error': _problem(503, 'ERP_UNAVAILABLE', 'try later')});
        continue;
      }
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
      } else if (entity == 'broadcast_ack' && !_notices.containsKey(payload['broadcastId'])) {
        r = {'mutationId': id, 'result': 'rejected', 'error': _problem(404, 'NOT_FOUND', 'No such broadcast')};
      } else if (entity == 'task_resolve_request' && !_tasks.containsKey(payload['taskId'])) {
        r = {'mutationId': id, 'result': 'rejected', 'error': _problem(404, 'NOT_FOUND', 'No such task')};
      } else if (entity == 'task_resolve_request' && ['resolved', 'cancelled'].contains(_tasks[payload['taskId']]!['status'])) {
        r = {'mutationId': id, 'result': 'rejected', 'error': _problem(409, 'INVALID_STATE', 'TASK_${(_tasks[payload['taskId']]!['status'] as String).toUpperCase()}')};
      } else if (entity == 'collection' && (payload['amountPoisha'] as int? ?? 0) <= 0) {
        r = {
          'mutationId': id,
          'result': 'rejected',
          'error': _problem(400, 'VALIDATION_FAILED', 'amountPoisha must be ≥ 1'),
        };
      } else if (entity == 'deposit') {
        r = _deposit(id, payload);
      } else if (entity == 'place' || entity == 'place_edit' || entity == 'place_move_request') {
        r = _placeMutation(id, entity, payload);
      } else if (entity == 'prospect') {
        r = _prospectMutation(id, (m['op'] as String?) ?? 'create', payload);
      } else if (entity == 'request') {
        r = _requestMutation(id, payload);
      } else if (entity == 'request_comment') {
        r = _requestCommentMutation(id, payload);
      } else {
        r = {'mutationId': id, 'result': 'applied', 'entityId': '$entity-$id', 'status': entity == 'collection' ? 'received' : 'ok'};
        if (entity == 'collection' && payload['method'] == 'cash') _cashOnHand += payload['amountPoisha'] as int;
        // 1.35.0: recording sends nothing to the ERP; it stays in my hand until a deposit.
        if (entity == 'collection') _srvCollections.add({...payload, 'collectionId': '$entity-$id', 'status': 'received', 'depositId': null, 'depositedAt': null});
        if (entity == 'collection') _collectedToday += payload['amountPoisha'] as int;
        if (entity == 'attendance_event' && payload['type'] == 'work_out') _leaveCoworkOnWorkOut();
        if (entity == 'broadcast_ack') {
          final bid = payload['broadcastId'] as String;
          final at = noticeAcks[bid] ??= (payload['at'] as String?) ?? clock.nowUtc().toIso8601String();
          final b = {..._notices[bid]!, 'acked': true, 'ackedAt': at};
          _notices[bid] = b;
          serverChange('broadcast', bid, b);
          r = {...r, 'entityId': bid};
        }
        if (entity == 'task_resolve_request') {
          _taskResolveRequest(payload);
          r = {...r, 'entityId': payload['taskId']};
        }
        if (entity == 'visit' && m['op'] == 'create' && payload['coWorkSessionId'] != null) {
          // Server works out who took part (1.9.0): accepted members at check-in.
          final me = user['id']! as String;
          final sid = payload['coWorkSessionId'] as String;
          final s = _cowork[sid];
          final ok = s != null && _members(s).any((x) => x['userId'] == me && x['status'] == 'accepted');
          serverChange('visit', '$entity-$id', {
            ...payload,
            'id': '$entity-$id',
            'userId': me,
            'flags': ok ? const <String>[] : const ['cowork_invalid'],
            'coWork': ok
                ? {'sessionId': sid, 'participantIds': [for (final x in _members(s)) if (x['status'] == 'accepted' && x['userId'] != me) x['userId']]}
                : null,
          });
        }
        if (entity == 'customer_phone') {
          // Server rules (1.23.0): added numbers follow the ERP ones; a number already there is skipped.
          final cid = payload['customerId'] as String;
          final c = _customer(cid);
          if (c != null) {
            final details = <Json>[
              ...((c['phoneDetails'] as List?)?.cast<Json>() ??
                  [
                    for (final (i, n) in <String>{if (c['phone'] != null) c['phone'] as String, ...((c['phones'] as List?) ?? const []).cast<String>()}.indexed)
                      {'number': n, 'source': 'erp', 'primary': i == 0},
                  ]),
            ];
            for (final p in ((payload['phones'] as List?) ?? const []).cast<Json>()) {
              if (details.any((d) => d['number'] == p['number'])) continue;
              details.add({'number': p['number'], 'source': 'field', 'primary': false, 'label': ?p['label'], 'addedBy': {'id': user['id'], 'name': _nameOf(user['id']! as String)}, 'addedAt': clock.nowUtc().toIso8601String()});
            }
            serverChange('customer', cid, {...c, 'phones': [for (final d in details) d['number']], 'phoneDetails': details});
          }
          r = {...r, 'entityId': cid};
        }
        if (entity == 'location_proposal') {
          // Server rules (1.11.0): a pin for a customer without a usable pin
          // applies at once under `when_missing`, unless the phone is mocked.
          // 1.39.0: a caller with `customer.location.approve` sets it at once
          // whatever the policy (a mock deviceGeo still waits).
          final geo = (payload['geo'] as Json?) ?? const {};
          final method = (payload['method'] as String?) ?? 'gps';
          final deviceMock = (payload['deviceGeo'] as Json?)?['mock'] == true;
          final loc = (_customer(payload['customerId'] as String)?['location'] as Json?) ?? const {};
          final usable = loc['status'] == 'ok' || loc['status'] == 'overridden';
          final auto = !deviceMock && (pinApprover || (staffPinApproval == 'when_missing' && !usable));
          final status = auto ? 'approved' : 'pending';
          r = {...r, 'status': status};
          serverChange('location_proposal', '$entity-$id', {
            'id': '$entity-$id',
            'clientId': payload['clientId'] ?? id,
            'customerId': payload['customerId'],
            'status': status,
            'lat': geo['lat'],
            'lng': geo['lng'],
            'accuracyM': geo['accuracyM'],
            'note': payload['note'],
            'decisionReason': null,
            'method': method,
            'autoApplied': auto,
            'createdAt': clock.nowUtc().toIso8601String(),
            'decidedAt': auto ? clock.nowUtc().toIso8601String() : null,
          });
          if (auto) _applyPin(payload['customerId'] as String, (geo['lat'] as num).toDouble(), (geo['lng'] as num).toDouble());
        }
      }
      _applied[id] = r;
      results.add(r);
    }
    return {'serverTime': clock.nowUtc().toIso8601String(), 'results': results};
  }

  Json _problem(int status, String code, String title) =>
      {'type': 'about:blank', 'status': status, 'code': code, 'title': title};

  /// `PUT /api/v1/storage/o?t=…` (field-api ADR-039/053): no bearer token, the body must match the signed type,
  /// size and sha256.
  Future<ResponseBody> _storagePut(RequestOptions o, Stream<Uint8List>? s) async {
    final bytes = s == null ? <int>[] : await s.fold<List<int>>(<int>[], (a, b) => a..addAll(b));
    final ct = o.headers[Headers.contentTypeHeader]?.toString();
    final cl = o.headers[Headers.contentLengthHeader]?.toString();
    storagePuts.add((contentType: ct, contentLength: cl, hadAuth: o.headers.containsKey('Authorization'), bodyLength: bytes.length));
    if (o.method != 'PUT') return _json(405, _problem(405, 'METHOD_NOT_ALLOWED', 'PUT only'));
    final g = _grants[o.uri.queryParameters['t']];
    if (g == null) return _json(403, _problem(403, 'FORBIDDEN', 'Bad or expired signature'));
    if (uploadsFail) return _json(503, _problem(503, 'UNAVAILABLE', 'Storage unavailable'));
    if (ct != g.contentType) return _json(400, _problem(400, 'VALIDATION_FAILED', 'Content type does not match the signature'));
    if (bytes.length != g.size || (cl != null && cl != '${g.size}')) return _json(400, _problem(400, 'VALIDATION_FAILED', 'Size does not match the signature'));
    if (crypto.sha256.convert(bytes).toString() != g.sha256) return _json(400, _problem(400, 'VALIDATION_FAILED', 'sha256 does not match the signature'));
    _storedMedia.add(g.mediaId);
    uploadedMedia.add(g.mediaId);
    return _json(200, {'stored': true});
  }

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

/// RFC 3339 date-time as JSON Schema `format: date-time` checks it: the offset (`Z` or `±hh:mm`) is required.
bool isRfc3339(Object? v) => v is String && RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$').hasMatch(v);
