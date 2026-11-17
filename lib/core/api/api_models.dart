// Typed models for the field-api v1 contract (`field-api/docs/openapi.yaml`,
// version pinned in `contract.lock`). Hand-written per ADR-M04's alternative
// (generator output for oneOf / nullable unions was not reliable); every
// model is covered by fixture tests in test/core/api/. Field names mirror
// the contract exactly — do not rename.
//
// JSON shape helpers only; no business logic here.

typedef Json = Map<String, dynamic>;

T? _opt<T>(Json j, String k) => j[k] as T?;

DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String).toUtc();

class I18nText {
  const I18nText({required this.bn, this.en});
  factory I18nText.fromJson(Object? j) {
    if (j is String) return I18nText(bn: j, en: j);
    final m = (j as Json?) ?? const {};
    return I18nText(bn: (m['bn'] ?? m['en'] ?? '') as String, en: m['en'] as String?);
  }
  final String bn;
  final String? en;

  String of(String lang) => lang == 'en' ? (en ?? bn) : bn;
  Json toJson() => {'bn': bn, if (en != null) 'en': en};
}

/// RFC 9457 problem (+ `code`).
class Problem {
  const Problem({required this.status, required this.code, required this.title, this.detail, this.details});
  factory Problem.fromJson(Json j) => Problem(
        status: (j['status'] as num?)?.toInt() ?? 0,
        code: (j['code'] as String?) ?? 'UNKNOWN',
        title: (j['title'] as String?) ?? '',
        detail: j['detail'] as String?,
        details: j['details'] as Json?,
      );
  final int status;
  final String code;
  final String title;
  final String? detail;
  final Json? details;
}

class ApiUser {
  const ApiUser({
    required this.id,
    required this.name,
    required this.role,
    required this.branchIds,
    required this.employeeCode,
    this.phone,
    this.mustChangePassword = false,
    this.cashLimitPoisha,
    this.locale = 'bn',
    this.shiftId,
  });
  factory ApiUser.fromJson(Json j) => ApiUser(
        id: j['id'] as String,
        name: I18nText.fromJson(j['name']),
        role: (j['role'] as String?) ?? 'field_staff',
        branchIds: ((j['branchIds'] as List?) ?? const []).cast<String>(),
        employeeCode: (j['employeeCode'] as String?) ?? '',
        phone: j['phone'] as String?,
        mustChangePassword: (j['mustChangePassword'] as bool?) ?? false,
        cashLimitPoisha: (j['cashLimitPoisha'] as num?)?.toInt(),
        locale: (j['locale'] as String?) ?? 'bn',
        shiftId: j['shiftId'] as String?,
      );
  final String id;
  final I18nText name;
  final String role;
  final List<String> branchIds;
  final String employeeCode;
  final String? phone;
  final bool mustChangePassword;
  final int? cashLimitPoisha;
  final String locale;
  final String? shiftId;

  Json toJson() => {
        'id': id,
        'name': name.toJson(),
        'role': role,
        'branchIds': branchIds,
        'employeeCode': employeeCode,
        'phone': phone,
        'mustChangePassword': mustChangePassword,
        'cashLimitPoisha': cashLimitPoisha,
        'locale': locale,
        'shiftId': shiftId,
      };

  ApiUser copyWith({bool? mustChangePassword}) => ApiUser(
        id: id,
        name: name,
        role: role,
        branchIds: branchIds,
        employeeCode: employeeCode,
        phone: phone,
        mustChangePassword: mustChangePassword ?? this.mustChangePassword,
        cashLimitPoisha: cashLimitPoisha,
        locale: locale,
        shiftId: shiftId,
      );
}

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.permissions,
    required this.flags,
    this.accessTokenExpiresAt,
    this.serverTime,
  });
  factory LoginResponse.fromJson(Json j) => LoginResponse(
        accessToken: j['accessToken'] as String,
        refreshToken: (j['refreshToken'] as String?) ?? '',
        accessTokenExpiresAt: _date(j['accessTokenExpiresAt']),
        user: ApiUser.fromJson(j['user'] as Json),
        permissions: ((j['permissions'] as List?) ?? const []).cast<String>(),
        flags: ((j['flags'] as Json?) ?? const {}).map((k, v) => MapEntry(k, v as bool)),
        serverTime: _date(j['serverTime']),
      );
  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;
  final ApiUser user;
  final List<String> permissions;
  final Map<String, bool> flags;
  final DateTime? serverTime;
}

class TileProviderConfig {
  const TileProviderConfig({required this.urlTemplate, required this.attribution, this.maxZoom = 19, this.subdomains = const []});
  factory TileProviderConfig.fromJson(Json j) => TileProviderConfig(
        urlTemplate: j['urlTemplate'] as String,
        attribution: (j['attribution'] as String?) ?? '',
        maxZoom: (j['maxZoom'] as num?)?.toInt() ?? 19,
        subdomains: ((j['subdomains'] as List?) ?? const []).cast<String>(),
      );
  final String urlTemplate;
  final String attribution;
  final int maxZoom;
  final List<String> subdomains;

  /// Development default (OSM standard tiles; NOT for production volume —
  /// ADR-014: production provider comes from /meta/app-config).
  static const osmDev = TileProviderConfig(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors',
  );
}

class AppConfig {
  const AppConfig({
    required this.minAppVersion,
    this.latestAppVersion,
    this.storeUrl,
    this.killSwitch = false,
    this.tileProvider,
    this.privacyNoticeVersion,
    this.serverTime,
  });
  factory AppConfig.fromJson(Json j) => AppConfig(
        minAppVersion: (j['minAppVersion'] as String?) ?? '0.0.0',
        latestAppVersion: j['latestAppVersion'] as String?,
        storeUrl: j['storeUrl'] as String?,
        killSwitch: (j['killSwitch'] as bool?) ?? false,
        tileProvider: j['tileProvider'] == null ? null : TileProviderConfig.fromJson(j['tileProvider'] as Json),
        privacyNoticeVersion: j['privacyNoticeVersion'] as String?,
        serverTime: _date(j['serverTime']),
      );
  final String minAppVersion;
  final String? latestAppVersion;
  final String? storeUrl;
  final bool killSwitch;
  final TileProviderConfig? tileProvider;
  final String? privacyNoticeVersion;
  final DateTime? serverTime;
}

/// `SyncMutation` (push item).
class SyncMutation {
  const SyncMutation({required this.mutationId, required this.entity, required this.op, required this.payload, this.createdAt});
  final String mutationId;
  final String entity;
  final String op;
  final Json payload;
  final DateTime? createdAt;

  Json toJson() => {
        'mutationId': mutationId,
        'entity': entity,
        'op': op,
        'payload': payload,
        if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
      };

  /// Contract enum `SyncMutation.entity`. Pushing anything else is a bug.
  static const entities = {
    'visit', 'collection', 'note', 'promise', 'promise_cancel', 'deposit', //
    'attendance_event', 'tag', 'location_proposal', 'visit_checkout', 'handover_decision', 'cash_closing', 'contact_attempt',
    'broadcast_ack', // 1.12.0
  };
}

class SyncPushResult {
  const SyncPushResult({required this.mutationId, required this.result, this.entityId, this.status, this.conflictCode, this.conflictMessage, this.error, this.retryable = false});
  factory SyncPushResult.fromJson(Json j) {
    final c = j['conflict'] as Json?;
    return SyncPushResult(
      mutationId: j['mutationId'] as String,
      result: j['result'] as String,
      entityId: j['entityId'] as String?,
      status: j['status'] as String?,
      conflictCode: c?['code'] as String?,
      conflictMessage: c == null ? null : I18nText.fromJson(c['message']),
      error: j['error'] == null ? null : Problem.fromJson(j['error'] as Json),
      retryable: j['retryable'] == true,
    );
  }
  final String mutationId;

  /// applied | replayed | conflict | rejected
  final String result;
  final String? entityId;
  final String? status;
  final String? conflictCode;
  final I18nText? conflictMessage;
  final Problem? error;

  /// Only on `rejected`: a transient server failure; keep it queued (1.5.0).
  final bool retryable;
}

class SyncPushResponse {
  const SyncPushResponse({required this.results, this.serverTime});
  factory SyncPushResponse.fromJson(Json j) => SyncPushResponse(
        results: ((j['results'] as List?) ?? const []).map((e) => SyncPushResult.fromJson(e as Json)).toList(),
        serverTime: _date(j['serverTime']),
      );
  final List<SyncPushResult> results;
  final DateTime? serverTime;
}

class SyncChange {
  const SyncChange({required this.seq, required this.entity, required this.op, required this.id, this.data, this.reason});
  factory SyncChange.fromJson(Json j) => SyncChange(
        seq: (j['seq'] as num?)?.toInt() ?? 0,
        entity: j['entity'] as String,
        op: j['op'] as String,
        id: j['id'] as String,
        data: j['data'] as Json?,
        reason: j['reason'] as String?,
      );
  final int seq;
  final String entity;

  /// upsert | delete
  final String op;
  final String id;
  final Json? data;
  final String? reason;
}

class CashPositionDto {
  const CashPositionDto({required this.onHandPoisha, required this.limitPoisha, this.pendingDepositsPoisha = 0, this.state = 'ok'});
  factory CashPositionDto.fromJson(Json j) => CashPositionDto(
        onHandPoisha: (j['onHandPoisha'] as num?)?.toInt() ?? 0,
        limitPoisha: (j['limitPoisha'] as num?)?.toInt() ?? 0,
        pendingDepositsPoisha: (j['pendingDepositsPoisha'] as num?)?.toInt() ?? 0,
        state: (j['state'] as String?) ?? 'ok',
      );
  final int onHandPoisha;
  final int limitPoisha;
  final int pendingDepositsPoisha;
  final String state;
}

class SyncPullResponse {
  const SyncPullResponse({
    required this.changes,
    required this.nextCursor,
    required this.hasMore,
    this.permissions,
    this.flags,
    this.settings,
    this.cash,
    this.target,
    this.serverTime,
  });
  factory SyncPullResponse.fromJson(Json j) {
    final perms = j['permissions'] as Json?;
    return SyncPullResponse(
      changes: ((j['changes'] as List?) ?? const []).map((e) => SyncChange.fromJson(e as Json)).toList(),
      nextCursor: (j['nextCursor'] ?? j['pullCursor'] ?? '') as String,
      hasMore: (j['hasMore'] as bool?) ?? false,
      permissions: perms == null ? null : ((perms['keys'] as List?) ?? const []).cast<String>(),
      flags: (j['flags'] as Json?)?.map((k, v) => MapEntry(k, v as bool)),
      settings: _opt<Json>(j, 'settings'),
      cash: j['cash'] == null ? null : CashPositionDto.fromJson(j['cash'] as Json),
      target: j['target'] == null ? null : MyTarget.fromJson(j['target'] as Json),
      serverTime: _date(j['serverTime']),
    );
  }
  final List<SyncChange> changes;
  final String nextCursor;
  final bool hasMore;
  final List<String>? permissions;
  final Map<String, bool>? flags;
  final Json? settings;
  final CashPositionDto? cash;

  /// My daily target (1.10.0; only while flag module.targets is on).
  final MyTarget? target;
  final DateTime? serverTime;
}

/// The caller's effective target for one business day (contract 1.10.0).
/// Visits are compared with visit credit (solo + joint × cowork.visitCredit).
class MyTarget {
  const MyTarget({required this.businessDate, required this.amountPoisha, required this.visits, this.source = 'branch', this.workingDay = true});
  factory MyTarget.fromJson(Json j) => MyTarget(
        businessDate: j['businessDate'] as String,
        amountPoisha: ((j['amountPoisha'] as num?) ?? 0).toInt(),
        visits: ((j['visits'] as num?) ?? 0).toDouble(),
        source: (j['source'] as String?) ?? 'branch',
        workingDay: (j['workingDay'] as bool?) ?? true,
      );
  final String businessDate;
  final int amountPoisha;

  /// A number, not a count: compared with visit credit, so it can be 12.5.
  final double visits;

  /// personal | branch
  final String source;

  /// false on weekly off, holiday or approved leave (targets are 0).
  final bool workingDay;

  Json toJson() => {'businessDate': businessDate, 'amountPoisha': amountPoisha, 'visits': visits, 'source': source, 'workingDay': workingDay};
}

class ReceiptBlockDto {
  const ReceiptBlockDto({required this.prefix, required this.businessDate, required this.from, required this.to});
  factory ReceiptBlockDto.fromJson(Json j) => ReceiptBlockDto(
        prefix: j['prefix'] as String,
        businessDate: j['businessDate'] as String,
        from: (j['from'] as num).toInt(),
        to: (j['to'] as num).toInt(),
      );
  final String prefix;
  final String businessDate;
  final int from;
  final int to;
}
