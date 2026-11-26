import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/secure_store.dart';
import '../../providers.dart';

/// Renew the tracking token when it has less than this left (FR-M-077, ADR-M40): the token lives about 24 h,
/// so a phone opened at least once a working day never lets it run out while the app is closed.
const trackingTokenRenewWithin = Duration(hours: 12);

/// The points-only tracking token from `POST /location/tracking-token` (contract 1.49.0). The native location
/// service uploads with it while the app is closed; the 15-minute access token is never handed to it.
class TrackingToken {
  const TrackingToken({required this.token, required this.expiresAt});
  final String token;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() => {'token': token, 'expiresAt': expiresAt.toUtc().toIso8601String()};

  static TrackingToken? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return TrackingToken(token: j['token'] as String, expiresAt: DateTime.parse(j['expiresAt'] as String).toUtc());
    } catch (_) {
      return null;
    }
  }
}

/// True when there is no token or it expires within [trackingTokenRenewWithin] of [nowUtc].
bool trackingTokenNeedsRenewal(TrackingToken? t, DateTime nowUtc) => t == null || !t.expiresAt.isAfter(nowUtc.add(trackingTokenRenewWithin));

/// Keeps the tracking token in the keystore (never in the DB or plain prefs on the Dart side).
class TrackingTokenStore {
  TrackingTokenStore(this._store);
  final SecureStore _store;
  static const _key = 'tracking_token';

  Future<TrackingToken?> read() async => TrackingToken.tryParse(await _store.read(_key));
  Future<void> write(TrackingToken t) => _store.write(_key, jsonEncode(t.toJson()));
  Future<void> clear() => _store.delete(_key);
}

final trackingTokenStoreProvider = Provider<TrackingTokenStore>((ref) => TrackingTokenStore(ref.watch(secureStoreProvider)));
