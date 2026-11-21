import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/colleague_activity.dart';
import '../../../core/feature/feature_manifest.dart';
import '../../../core/location/location_engine.dart';
import '../../../core/media/media.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/sync/outbox.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'customer_providers.dart';
import 'domain/customer.dart';
import 'domain/map_pin.dart';

/// Customer pins (FR-CUS-008, FR-CUS-011): the staff picks the point on a
/// map (the map moves under a fixed pin, ride-app style; see
/// `MapPinScreen`) and the phone sends it as a `location_proposal` with
/// `method: map` and where the phone was (`deviceGeo`, contract 1.11.0).
///
/// Under `customers.staffPinApproval = when_missing` (default) the server
/// sets the pin at once for a customer without a usable pin; moving an
/// existing pin waits for a manager. The pin itself always arrives as a
/// customer change on pull. Rules shown before sending: `domain/map_pin.dart`.

/// The branch's `customers.staffPinApproval`; missing → `when_missing`.
final staffPinApprovalProvider = Provider<StaffPinApproval>((ref) => StaffPinApproval.parse(ref.watch(serverSettingsProvider)['customers.staffPinApproval']));

/// Saves the proposal on the phone. With a photo, the photo is queued and
/// the `location_proposal` mutation follows once the photo is confirmed
/// (see [submitLocationProposal]), because the contract wants the server
/// media id in the body; until then the row is `waiting_photo` and nothing
/// is lost offline. Without a photo the mutation is queued at once, in the
/// same transaction as the row. The client id (UUIDv7) is made here once.
Future<String> recordLocationProposal(Ref ref, {required Customer customer, required double lat, required double lng, GeoFix? phone, Uint8List? photo, String? note}) async {
  assert(insideBangladesh(lat, lng));
  final db = ref.read(databaseProvider);
  final clock = ref.read(clockProvider);
  final id = const Uuid().v7();
  final text = note?.trim();
  final row = LocationProposalsCompanion.insert(
    clientId: id,
    customerId: customer.id,
    lat: lat,
    lng: lng,
    accuracyM: 0,
    method: const Value('map'),
    deviceGeoJson: Value(phone == null ? null : jsonEncode(phone.toJson())),
    note: Value(text == null || text.isEmpty ? null : text),
    syncState: Value(photo == null ? 'queued' : 'waiting_photo'),
  );
  if (photo == null) {
    final outbox = ref.read(outboxWriterProvider);
    await db.transaction(() async {
      await db.into(db.locationProposals).insert(row);
      await submitLocationProposal(outbox, db, id, const []);
    });
    unawaited(ref.read(syncEngineProvider).kick(reason: 'pin'));
    return id;
  }
  await db.into(db.locationProposals).insert(row);
  final user = await ref.read(secureStoreProvider).read('session_user');
  final code = user == null ? '' : ((jsonDecode(user) as Map)['employeeCode'] ?? '').toString();
  final f = ref.read(fmtProvider);
  final at = clock.nowUtc();
  final wm = '${f.dateTime(at).replaceAll(RegExp('[^\\x00-\\x7F]'), '')} ${clock.businessDate()} $code ${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';
  final processed = await processPhoto(photo, watermark: wm.trim());
  final mediaId = await ref.read(mediaServiceProvider).enqueue(photo: processed, kind: 'location_proof', ownerEntity: 'location_proposal', ownerClientId: id, fix: phone);
  await (db.update(db.locationProposals)..where((t) => t.clientId.equals(id))).write(LocationProposalsCompanion(photoMediaClientId: Value(mediaId)));
  unawaited(ref.read(mediaServiceProvider).uploadPending().catchError((Object _) {}));
  return id;
}

class PinCorrectionService {
  PinCorrectionService(this._ref);
  final Ref _ref;
  Future<String> record({required Customer customer, required double lat, required double lng, GeoFix? phone, Uint8List? photo, String? note}) =>
      recordLocationProposal(_ref, customer: customer, lat: lat, lng: lng, phone: phone, photo: photo, note: note);
}

final pinCorrectionServiceProvider = Provider<PinCorrectionService>(PinCorrectionService.new);

/// Body of the `location_proposal` mutation. Rows from before 0.8.0 are
/// GPS proposals and keep their old shape (no `method`: the server reads
/// that as `gps`).
Json locationProposalPayload(LocationProposalRow p, List<String> mediaIds) {
  final device = p.deviceGeoJson == null ? null : jsonDecode(p.deviceGeoJson!) as Json;
  return {
    'clientId': p.clientId,
    'customerId': p.customerId,
    'geo': {'lat': p.lat, 'lng': p.lng, 'accuracyM': p.accuracyM, 'mock': false},
    if (p.method == 'map') ...{
      'method': 'map',
      'deviceGeo': device == null
          ? null
          : {'lat': device['lat'], 'lng': device['lng'], 'accuracyM': device['accuracyM'], 'mock': device['mock'] ?? false, if (device['fixAt'] != null) 'capturedAt': device['fixAt']},
    },
    if (mediaIds.isNotEmpty) 'photoMediaId': mediaIds.first,
    'note': ?p.note,
  };
}

/// Media hook: the photo is on the server → queue the proposal itself.
/// Idempotent: the mutation id is the proposal's client id.
Future<void> submitLocationProposal(OutboxWriter outbox, AppDatabase db, String proposalClientId, List<String> mediaIds) async {
  final p = await (db.select(db.locationProposals)..where((t) => t.clientId.equals(proposalClientId))).getSingleOrNull();
  if (p == null) return;
  await db.transaction(() async {
    await outbox.enqueue(mutationId: p.clientId, entity: 'location_proposal', payload: locationProposalPayload(p, mediaIds));
    if (p.syncState == 'waiting_photo') {
      await (db.update(db.locationProposals)..where((t) => t.clientId.equals(p.clientId))).write(const LocationProposalsCompanion(syncState: Value('queued')));
    }
  });
}

class LocationProposalPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'location_proposal'};
  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) => (db.update(db.locationProposals)..where((t) => t.clientId.equals(m.mutationId))).write(
    LocationProposalsCompanion(
      syncState: Value(r.result == 'rejected' ? 'failed' : 'synced'),
      // 1.11.0: a pin the server set at once comes back `approved`.
      status: r.status == 'approved' ? const Value('approved') : const Value.absent(),
    ),
  );
}

/// Pull (contract 1.7.0): the server sends `location_proposal` to the
/// proposer when it is created and again when a manager decides. The
/// approved pin itself arrives separately as a customer change.
class LocationProposalPullHandler implements PullHandler {
  @override
  String get entity => 'location_proposal';
  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final clientId = (d['clientId'] as String?) ?? id;
    final status = (d['status'] as String?) ?? 'pending';
    final reason = d['decisionReason'] as String?;
    // Since 1.31.0 the feed carries the whole branch's pins: a colleague's goes to the colleague table (FR-M-057).
    final proposer = d['proposer'] as Json?;
    if (isColleague(me: await savedUserId(db), staffId: proposer?['id'] as String?) && d['customerId'] != null) {
      await upsertColleagueActivity(
        db,
        kind: 'pin',
        serverId: id,
        customerId: d['customerId'] as String,
        staffId: proposer!['id'] as String,
        staffName: (proposer['name'] as String?) ?? '',
        at: DateTime.tryParse('${d['createdAt']}')?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        status: status,
        note: reason,
      );
      return;
    }
    final updated = await (db.update(
      db.locationProposals,
    )..where((t) => t.clientId.equals(clientId))).write(LocationProposalsCompanion(status: Value(status), decisionReason: Value(reason), syncState: const Value('synced')));
    if (updated == 0 && d['customerId'] != null && d['lat'] != null && d['lng'] != null) {
      // Not on this phone (reinstall): keep the server's copy.
      await db
          .into(db.locationProposals)
          .insertOnConflictUpdate(
            LocationProposalsCompanion.insert(
              clientId: clientId,
              customerId: d['customerId'] as String,
              lat: (d['lat'] as num).toDouble(),
              lng: (d['lng'] as num).toDouble(),
              accuracyM: ((d['accuracyM'] as num?) ?? 0).toDouble(),
              note: Value(d['note'] as String?),
              method: Value((d['method'] as String?) ?? 'gps'),
              status: Value(status),
              decisionReason: Value(reason),
              syncState: const Value('synced'),
            ),
          );
    }
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) async {}
}

/// The newest proposal for a customer when it still needs a line on the
/// detail screen: waiting (pending) or turned down (rejected, with reason).
/// Approved ones disappear: the new pin is the answer.
final openProposalProvider = StreamProvider.family<LocationProposalRow?, String>((ref, customerId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.locationProposals)
        ..where((t) => t.customerId.equals(customerId))
        ..orderBy([(t) => OrderingTerm.desc(t.clientId)]) // UUIDv7 = time order
        ..limit(1))
      .watchSingleOrNull()
      .map((p) => p == null || p.status == 'approved' ? null : p);
});

/// Opens the pin screen.
void openPinCorrection(BuildContext context, String customerId) => context.push('/customers/$customerId/pin');

/// Small status line on customer detail while a proposal is open.
class PinProposalStatus extends ConsumerWidget {
  const PinProposalStatus({super.key, required this.customerId});
  final String customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(openProposalProvider(customerId)).value;
    if (p == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final rejected = p.status == 'rejected';
    final failed = p.syncState == 'failed';
    // Not sent yet, and the server will set it at once (customer had no pin).
    final c = ref.watch(customerProvider(customerId)).value;
    final policy = ref.watch(staffPinApprovalProvider);
    final appliesWhenSent =
        !rejected && !failed && p.syncState != 'synced' && c != null && checkMapPin(lat: p.lat, lng: p.lng, phone: _phoneOf(p), customerHasUsablePin: c.pinUsable, policy: policy).appliesAtOnce;
    return Padding(
      padding: const EdgeInsets.only(top: Space.s12),
      child: InfoBanner(
        icon: rejected || failed ? Icons.error_outline_rounded : (appliesWhenSent ? Icons.cloud_upload_rounded : Icons.hourglass_top_rounded),
        tone: rejected ? BannerTone.warning : (failed ? BannerTone.danger : BannerTone.info),
        text: rejected ? l.pinRejected(p.decisionReason ?? '') : (failed ? l.pinFailed : (appliesWhenSent ? l.pinApplyWhenSent : l.pinPending)),
        onTap: rejected ? () => openPinCorrection(context, customerId) : null,
      ),
    );
  }
}

GeoFix? _phoneOf(LocationProposalRow p) {
  if (p.deviceGeoJson == null) return null;
  final d = jsonDecode(p.deviceGeoJson!) as Json;
  return GeoFix(
    lat: (d['lat'] as num).toDouble(),
    lng: (d['lng'] as num).toDouble(),
    accuracyM: ((d['accuracyM'] as num?) ?? 0).toDouble(),
    mock: d['mock'] == true,
    fixAt: DateTime.tryParse('${d['fixAt']}') ?? DateTime.utc(1970),
  );
}

/// Pins on a customer's timeline (FR-M-057): mine and my colleagues', each with who set or proposed it.
Stream<List<TimelineEntry>> watchPinTimeline(AppDatabase db, AppLocalizations l, Fmt f, String customerId, String? myName) {
  String title(String status) => switch (status) {
        'approved' => l.timelinePinSet,
        'rejected' => l.timelinePinRejected,
        _ => l.timelinePinPending,
      };
  final own = (db.select(db.locationProposals)..where((t) => t.customerId.equals(customerId))).watch();
  return combineLatest2(own, watchColleagueActivities(db, customerId, 'pin'), (mine, others) => [
        for (final p in others)
          TimelineEntry(at: p.at, icon: Icons.location_on_rounded, title: title(p.status ?? 'pending'), subtitle: [f.dateTime(p.at), l.timelinePinBy(p.staffName), if (p.note != null) p.note!].join(' · ')),
        // My own proposals carry no time of their own on this phone: the UUIDv7 id holds it, so only the name and state show.
        for (final p in mine)
          TimelineEntry(at: _uuidV7Time(p.clientId), icon: Icons.location_on_rounded, title: title(p.status), subtitle: [if (myName != null) l.timelinePinBy(myName), if (p.decisionReason != null) p.decisionReason!].join(' · ')),
      ]);
}

DateTime _uuidV7Time(String id) {
  final hex = id.replaceAll('-', '');
  final ms = hex.length >= 12 ? int.tryParse(hex.substring(0, 12), radix: 16) : null;
  return ms == null ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true) : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}
