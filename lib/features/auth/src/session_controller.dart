import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_models.dart';
import '../../../core/api/field_api.dart';
import '../../../core/auth/pin.dart';
import '../../../core/db/colleague_activity.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../core/providers.dart';

/// Where the user is in the auth / first-run flow. The router maps each
/// stage to a screen (FR-M-001).
enum SessionStage { loading, signedOut, mustChangePassword, needsPin, needsConsent, needsPrimer, needsBootstrap, locked, ready }

@immutable
class SessionState {
  const SessionState({required this.stage, this.user, this.pinFailures = 0, this.lockedOut = false});
  final SessionStage stage;
  final ApiUser? user;
  final int pinFailures;

  /// 5 wrong PINs → password login of the same user required (data kept).
  final bool lockedOut;

  SessionState copyWith({SessionStage? stage, ApiUser? user, int? pinFailures, bool? lockedOut}) =>
      SessionState(stage: stage ?? this.stage, user: user ?? this.user, pinFailures: pinFailures ?? this.pinFailures, lockedOut: lockedOut ?? this.lockedOut);
}

/// Why a password login did not go through. Each has its own words on the
/// login screen (owner report 2026-11-24: three different cases used to read
/// "Account locked").
enum LoginError {
  invalid,
  network,

  /// 423 `ACCOUNT_LOCKED`: too many wrong passwords; [LoginFailure.until] is the unlock time.
  locked,

  /// 403 `DEVICE_NOT_APPROVED`: the server has already asked the office to approve this phone. Not an error.
  deviceNotApproved,

  /// Another user's unsynced data is still on this phone (never deleted, CLAUDE.md §2.3).
  otherUserUnsynced,

  /// Any other 403; [LoginFailure.code] is shown.
  forbidden,
  other,
}

class LoginFailure implements Exception {
  const LoginFailure(this.error, {this.code, this.until, this.networkLock = false, this.requestId});
  final LoginError error;

  /// 423 with `details.scope: ip` (contract 1.47.0): this network is locked, not the account.
  final bool networkLock;

  /// 403 `details.pendingDeviceId` (1.47.0): the approval request the office approves.
  final String? requestId;

  /// The server's problem `code` (shown for [LoginError.forbidden]).
  final String? code;

  /// UTC unlock time from `details.until` (423).
  final DateTime? until;

  /// Maps a failed `POST /auth/login` by its status and problem `code` (contract 1.47.0 details).
  /// [now] (server-offset UTC) turns `details.retryAfterSec` into a time when `until` is missing.
  static LoginFailure fromApi(ApiException e, {DateTime? now}) {
    if (e.isNetwork) return const LoginFailure(LoginError.network);
    final code = e.problem?.code;
    final details = e.problem?.details ?? const <String, dynamic>{};
    if (e.statusCode == 401) return const LoginFailure(LoginError.invalid);
    // The lock is read from the code first; a 423 without one is still a lock.
    if (code == 'ACCOUNT_LOCKED' || e.statusCode == 423) {
      final rawUntil = details['until'];
      final retryAfter = details['retryAfterSec'];
      var until = rawUntil is String ? DateTime.tryParse(rawUntil)?.toUtc() : null;
      if (until == null && retryAfter is num && retryAfter > 0 && now != null) {
        until = now.toUtc().add(Duration(seconds: retryAfter.toInt()));
      }
      return LoginFailure(LoginError.locked, code: code, until: until, networkLock: details['scope'] == 'ip');
    }
    if (code == 'DEVICE_NOT_APPROVED') {
      final id = details['pendingDeviceId'];
      return LoginFailure(LoginError.deviceNotApproved, code: code, requestId: id is String && id.isNotEmpty ? id : null);
    }
    if (e.statusCode == 403) return LoginFailure(LoginError.forbidden, code: e.code);
    return LoginFailure(LoginError.other, code: code);
  }

  @override
  String toString() => 'LoginFailure($error, $code, $until)';
}

const maxPinFailures = 5;
const appLockAfter = Duration(minutes: 5);
const currentConsentVersion = '2026-11-v1';

class SessionController extends Notifier<SessionState> {
  static const _kUser = 'session_user';
  static const _kPinHash = 'pin_hash';
  static const _kPinSalt = 'pin_salt';
  static const _kPinFails = 'pin_failures';
  static const _kLockedUser = 'locked_user_id';

  PinHasher get _hasher => ref.read(pinHasherProvider);

  @override
  SessionState build() => const SessionState(stage: SessionStage.loading);

  /// Restores state at app start: valid session → PIN lock screen.
  Future<void> restore() async {
    final store = ref.read(secureStoreProvider);
    final tokens = ref.read(tokenStoreProvider);
    await tokens.load();
    tokens.onSessionExpired = _onExpired;
    final userJson = await store.read(_kUser);
    final db = ref.read(databaseProvider);
    final access = await db.kvGet('access');
    if (access != null) {
      final j = jsonDecode(access) as Json;
      ref.read(accessProvider.notifier).set(
            permissions: (j['permissions'] as List).cast<String>(),
            flags: (j['flags'] as Json).map((k, v) => MapEntry(k, v as bool)),
          );
    }
    final ar = await db.kvGet('attendance_required');
    if (ar != null) ref.read(attendanceRequiredProvider.notifier).state = jsonDecode(ar) as bool;
    final ss = await db.kvGet('server_settings');
    if (ss != null) ref.read(serverSettingsProvider.notifier).state = jsonDecode(ss) as Json;
    final cash = await db.kvGet('server_cash');
    if (cash != null) ref.read(serverCashProvider.notifier).state = CashPositionDto.fromJson(jsonDecode(cash) as Json);
    final target = await db.kvGet('my_target');
    if (target != null) ref.read(myTargetProvider.notifier).state = MyTarget.fromJson(jsonDecode(target) as Json);
    final fails = int.tryParse(await store.read(_kPinFails) ?? '0') ?? 0;
    if (!tokens.hasSession || userJson == null) {
      state = SessionState(stage: SessionStage.signedOut, lockedOut: (await store.read(_kLockedUser)) != null);
      return;
    }
    final user = ApiUser.fromJson(jsonDecode(userJson) as Json);
    await saveUserId(db, user.id);
    if (fails >= maxPinFailures) {
      state = SessionState(stage: SessionStage.signedOut, user: user, lockedOut: true);
      return;
    }
    final next = await _nextStage(user);
    state = SessionState(stage: next == SessionStage.ready ? SessionStage.locked : next, user: user, pinFailures: fails);
  }

  Future<SessionStage> _nextStage(ApiUser user) async {
    final store = ref.read(secureStoreProvider);
    final db = ref.read(databaseProvider);
    if (user.mustChangePassword) return SessionStage.mustChangePassword;
    if (await store.read(_kPinHash) == null) return SessionStage.needsPin;
    if (await db.kvGet('consent_version') != jsonEncode(currentConsentVersion)) return SessionStage.needsConsent;
    if (await db.kvGet('primer_done') == null) return SessionStage.needsPrimer;
    final meta = await (db.select(db.syncMeta)..where((t) => t.id.equals(1))).getSingleOrNull();
    if (meta == null || !meta.bootstrapDone) return SessionStage.needsBootstrap;
    return SessionStage.ready;
  }

  Future<void> _advance() async {
    final u = state.user;
    if (u == null) return;
    state = state.copyWith(stage: await _nextStage(u));
  }

  Future<void> login(String phone, String password) async {
    final api = ref.read(fieldApiProvider);
    final store = ref.read(secureStoreProvider);
    LoginResponse r;
    try {
      r = await api.login(phone: phone.trim(), password: password);
    } on ApiException catch (e) {
      throw LoginFailure.fromApi(e, now: ref.read(clockProvider).nowUtc());
    }
    // A different user on this phone: only allowed when nothing is unsynced
    // (never delete unsynced data — CLAUDE.md §2.3).
    final lockedUser = await store.read(_kLockedUser);
    final prevJson = await store.read(_kUser);
    final prevId = lockedUser ?? (prevJson == null ? null : (jsonDecode(prevJson) as Json)['id'] as String?);
    if (prevId != null && prevId != r.user.id) {
      final unsynced = await ref.read(outboxReaderProvider).unsyncedCount();
      if (unsynced > 0) throw const LoginFailure(LoginError.otherUserUnsynced);
      await ref.read(databaseProvider).wipeAll();
      await store.delete(_kPinHash);
    }
    if (r.serverTime != null) ref.read(clockProvider).syncWithServer(r.serverTime!);
    await ref.read(tokenStoreProvider).save(r.accessToken, r.refreshToken);
    await store.write(_kUser, jsonEncode(r.user.toJson()));
    await store.write(_kPinFails, '0');
    await store.delete(_kLockedUser);
    ref.read(accessProvider.notifier).set(permissions: r.permissions, flags: r.flags);
    await ref.read(databaseProvider).kvSet('access', jsonEncode({'permissions': r.permissions, 'flags': r.flags}));
    ref.read(attendanceRequiredProvider.notifier).state = r.attendanceRequired ?? true;
    await ref.read(databaseProvider).kvSet('attendance_required', jsonEncode(r.attendanceRequired ?? true));
    await saveUserId(ref.read(databaseProvider), r.user.id);
    state = SessionState(stage: SessionStage.loading, user: r.user);
    await _advance();
  }

  /// Online-only (ADR-M08).
  Future<void> changePassword(String current, String next) async {
    await ref.read(fieldApiProvider).changePassword(current: current, next: next);
    final u = state.user!.copyWith(mustChangePassword: false);
    await ref.read(secureStoreProvider).write(_kUser, jsonEncode(u.toJson()));
    state = state.copyWith(user: u);
    await _advance();
  }

  Future<void> setPin(String pin) async {
    final store = ref.read(secureStoreProvider);
    final salt = _hasher.newSalt();
    final hash = await compute(_hashIsolate, [pin, salt, _hasher.iterations.toString()]);
    await store.write(_kPinSalt, salt);
    await store.write(_kPinHash, hash);
    await _advance();
  }

  /// Returns true when unlocked.
  Future<bool> unlock(String pin) async {
    final store = ref.read(secureStoreProvider);
    final salt = await store.read(_kPinSalt);
    final hash = await store.read(_kPinHash);
    if (salt == null || hash == null) return false;
    final candidate = await compute(_hashIsolate, [pin, salt, _hasher.iterations.toString()]);
    if (candidate == hash) {
      await store.write(_kPinFails, '0');
      state = state.copyWith(stage: SessionStage.ready, pinFailures: 0);
      unawaited(ref.read(syncEngineProvider).kick(reason: 'unlock'));
      return true;
    }
    final fails = state.pinFailures + 1;
    await store.write(_kPinFails, '$fails');
    if (fails >= maxPinFailures) {
      // Keep data (encrypted) and the queue; require password login of the
      // same user. Tokens are dropped so the next login must be online.
      await store.write(_kLockedUser, state.user?.id ?? '');
      await ref.read(tokenStoreProvider).clear();
      state = SessionState(stage: SessionStage.signedOut, user: state.user, pinFailures: fails, lockedOut: true);
    } else {
      state = state.copyWith(pinFailures: fails);
    }
    return false;
  }

  Future<void> acceptConsent() async {
    await ref.read(databaseProvider).kvSet('consent_version', jsonEncode(currentConsentVersion));
    await _advance();
  }

  Future<void> finishPrimer() async {
    await ref.read(databaseProvider).kvSet('primer_done', 'true');
    await _advance();
  }

  Future<void> runBootstrap() async {
    await ref.read(syncEngineProvider).kick(reason: 'bootstrap');
    await _advance();
  }

  /// "Forgot PIN" → password login (same user, data kept).
  void usePassword() => state = state.copyWith(stage: SessionStage.signedOut);

  /// App came back from background after [appLockAfter].
  void lock() {
    if (state.stage == SessionStage.ready) state = state.copyWith(stage: SessionStage.locked);
  }

  void _onExpired() {
    // Refresh token rejected: back to login; data and queue stay on device.
    if (state.stage == SessionStage.ready || state.stage == SessionStage.locked) {
      state = state.copyWith(stage: SessionStage.signedOut);
    }
  }

  /// Logout is blocked while anything is unsynced (FR-M-016).
  Future<int> unsyncedCount() => ref.read(outboxReaderProvider).unsyncedCount();

  Future<void> logout() async {
    final unsynced = await unsyncedCount();
    if (unsynced > 0) throw StateError('Unsynced items present');
    try {
      await ref.read(fieldApiProvider).logout();
    } catch (_) {}
    final store = ref.read(secureStoreProvider);
    await ref.read(tokenStoreProvider).clear();
    for (final k in [_kUser, _kPinHash, _kPinSalt, _kPinFails, _kLockedUser]) {
      await store.delete(k);
    }
    await ref.read(databaseProvider).wipeAll();
    ref.read(accessProvider.notifier).clear();
    ref.read(myTargetProvider.notifier).state = null;
    ref.read(attendanceRequiredProvider.notifier).state = true;
    state = const SessionState(stage: SessionStage.signedOut);
  }
}

String _hashIsolate(List<String> a) => PinHasher(iterations: int.parse(a[2])).hash(a[0], a[1]);

final pinHasherProvider = Provider<PinHasher>((ref) => const PinHasher());

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);
