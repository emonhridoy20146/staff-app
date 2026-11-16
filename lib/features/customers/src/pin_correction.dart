import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/db/app_database.dart';
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

/// Pin correction (FR-CUS-008): the staff stands at the customer and
/// proposes the phone's GPS position as the new pin, with a camera photo.
/// A manager approves it on the web; the pin itself only changes when the
/// approved customer comes back through sync.
///
/// Server rules mirrored here so the staff sees the reason before sending:
/// accuracy ≤ 30 m, no mock location, inside Bangladesh.
const pinMaxAccuracyM = 30;

/// Rough Bangladesh bounding box (server does the exact check).
bool insideBangladesh(double lat, double lng) => lat >= 20.5 && lat <= 26.7 && lng >= 88.0 && lng <= 92.75;

enum PinFixProblem { none, noFix, mock, weak, outside }

PinFixProblem checkPinFix(GeoFix? fix) {
  if (fix == null) return PinFixProblem.noFix;
  if (fix.mock) return PinFixProblem.mock;
  if (fix.accuracyM > pinMaxAccuracyM) return PinFixProblem.weak;
  if (!insideBangladesh(fix.lat, fix.lng)) return PinFixProblem.outside;
  return PinFixProblem.none;
}

/// Saves the proposal on the phone and queues its photo. The
/// `location_proposal` mutation is queued once the photo is confirmed
/// (see [submitLocationProposal]) because the contract wants the server
/// media id in the body. Until then the row is `waiting_photo` and the
/// photo sits in the media queue — nothing is lost offline.
Future<String> recordLocationProposal(Ref ref, {required Customer customer, required GeoFix fix, required Uint8List photo, String? note}) async {
  assert(checkPinFix(fix) == PinFixProblem.none);
  final db = ref.read(databaseProvider);
  final clock = ref.read(clockProvider);
  final id = const Uuid().v7();
  final text = note?.trim();
  await db.into(db.locationProposals).insert(LocationProposalsCompanion.insert(
        clientId: id,
        customerId: customer.id,
        lat: fix.lat,
        lng: fix.lng,
        accuracyM: fix.accuracyM,
        note: Value(text == null || text.isEmpty ? null : text),
        syncState: const Value('waiting_photo'),
      ));
  final user = await ref.read(secureStoreProvider).read('session_user');
  final code = user == null ? '' : ((jsonDecode(user) as Map)['employeeCode'] ?? '').toString();
  final f = ref.read(fmtProvider);
  final at = clock.nowUtc();
  final wm = '${f.dateTime(at).replaceAll(RegExp('[^\\x00-\\x7F]'), '')} ${clock.businessDate()} $code ${fix.lat.toStringAsFixed(5)},${fix.lng.toStringAsFixed(5)}';
  final processed = await processPhoto(photo, watermark: wm.trim());
  final mediaId = await ref.read(mediaServiceProvider).enqueue(photo: processed, kind: 'location_proof', ownerEntity: 'location_proposal', ownerClientId: id, fix: fix);
  await (db.update(db.locationProposals)..where((t) => t.clientId.equals(id))).write(LocationProposalsCompanion(photoMediaClientId: Value(mediaId)));
  unawaited(ref.read(mediaServiceProvider).uploadPending().catchError((Object _) {}));
  return id;
}

class PinCorrectionService {
  PinCorrectionService(this._ref);
  final Ref _ref;
  Future<String> record({required Customer customer, required GeoFix fix, required Uint8List photo, String? note}) =>
      recordLocationProposal(_ref, customer: customer, fix: fix, photo: photo, note: note);
}

final pinCorrectionServiceProvider = Provider<PinCorrectionService>(PinCorrectionService.new);

/// Media hook: the photo is on the server → queue the proposal itself.
/// Idempotent: the mutation id is the proposal's client id.
Future<void> submitLocationProposal(OutboxWriter outbox, AppDatabase db, String proposalClientId, List<String> mediaIds) async {
  final p = await (db.select(db.locationProposals)..where((t) => t.clientId.equals(proposalClientId))).getSingleOrNull();
  if (p == null) return;
  await db.transaction(() async {
    await outbox.enqueue(mutationId: p.clientId, entity: 'location_proposal', payload: {
      'clientId': p.clientId,
      'customerId': p.customerId,
      'geo': {'lat': p.lat, 'lng': p.lng, 'accuracyM': p.accuracyM, 'mock': false},
      if (mediaIds.isNotEmpty) 'photoMediaId': mediaIds.first,
      'note': ?p.note,
    });
    if (p.syncState == 'waiting_photo') {
      await (db.update(db.locationProposals)..where((t) => t.clientId.equals(p.clientId))).write(const LocationProposalsCompanion(syncState: Value('queued')));
    }
  });
}

class LocationProposalPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'location_proposal'};
  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) =>
      (db.update(db.locationProposals)..where((t) => t.clientId.equals(m.mutationId))).write(
        LocationProposalsCompanion(syncState: Value(r.result == 'rejected' ? 'failed' : 'synced')),
      );
}

/// The newest proposal for a customer that is still open on the phone:
/// not yet approved (the customer pin is not at the proposed spot yet).
final openProposalProvider = StreamProvider.family<LocationProposalRow?, String>((ref, customerId) {
  final db = ref.watch(databaseProvider);
  final customer = ref.watch(customerProvider(customerId)).value;
  return (db.select(db.locationProposals)
        ..where((t) => t.customerId.equals(customerId) & t.status.equals('pending'))
        ..orderBy([(t) => OrderingTerm.desc(t.clientId)]) // UUIDv7 = time order
        ..limit(1))
      .watchSingleOrNull()
      .map((p) {
    if (p == null || customer == null || !customer.hasPin) return p;
    final approved = distanceMeters(p.lat, p.lng, customer.row.lat!, customer.row.lng!) < 5;
    return approved ? null : p;
  });
});

/// Opens the pin screen.
void openPinCorrection(BuildContext context, String customerId) => context.push('/customers/$customerId/pin');

class PinCorrectionScreen extends ConsumerStatefulWidget {
  const PinCorrectionScreen({super.key, required this.customerId});
  final String customerId;
  @override
  ConsumerState<PinCorrectionScreen> createState() => _PinCorrectionScreenState();
}

class _PinCorrectionScreenState extends ConsumerState<PinCorrectionScreen> {
  late Future<GeoFix?> _fix = ref.read(locationEngineProvider).currentFix();
  Uint8List? _photo;
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final bytes = await ref.read(photoCapturerProvider).capture(context);
    if (bytes != null) setState(() => _photo = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final c = ref.watch(customerProvider(widget.customerId)).value;
    if (c == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return FutureBuilder<GeoFix?>(
      future: _fix,
      builder: (context, s) {
        final searching = s.connectionState != ConnectionState.done;
        final fix = s.data;
        final problem = searching ? null : checkPinFix(fix);
        final ok = problem == PinFixProblem.none && _photo != null && !_busy;
        return Scaffold(
          appBar: AppBar(title: Text(c.hasPin ? l.actionCorrectLocation : l.actionSetLocation)),
          body: ListView(
            padding: const EdgeInsets.all(Space.screen),
            children: [
              Text(c.nameOf(lang), style: t.titleLarge),
              Text(c.code, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: Space.s12),
              Text(l.pinIntro, style: t.bodyLarge),
              const SizedBox(height: Space.s16),
              if (searching)
                InfoBanner(icon: Icons.my_location_rounded, text: l.collectGpsSearching)
              else
                InfoBanner(
                  icon: switch (problem!) {
                    PinFixProblem.none => Icons.gps_fixed_rounded,
                    PinFixProblem.mock => Icons.gpp_maybe_rounded,
                    PinFixProblem.noFix => Icons.location_disabled_rounded,
                    _ => Icons.gps_not_fixed_rounded,
                  },
                  tone: switch (problem) {
                    PinFixProblem.none => BannerTone.success,
                    PinFixProblem.mock || PinFixProblem.outside => BannerTone.danger,
                    _ => BannerTone.warning,
                  },
                  text: switch (problem) {
                    PinFixProblem.none => l.collectGpsAccurate(f.num(fix!.accuracyM.round())),
                    PinFixProblem.noFix => l.collectGpsNone,
                    PinFixProblem.mock => l.collectGpsMock,
                    PinFixProblem.weak => l.pinAccuracyWeak(f.num(fix!.accuracyM.round()), f.num(pinMaxAccuracyM)),
                    PinFixProblem.outside => l.pinOutside,
                  },
                ),
              if (!searching && fix != null && c.hasPin && problem == PinFixProblem.none) ...[
                const SizedBox(height: Space.s8),
                Text(l.pinDistanceFromOld(f.distance(distanceMeters(fix.lat, fix.lng, c.row.lat!, c.row.lng!))), style: t.bodyMedium),
              ],
              if (!searching && problem != PinFixProblem.none) ...[
                const SizedBox(height: Space.s8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _fix = ref.read(locationEngineProvider).currentFix()),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l.pinRetry),
                  ),
                ),
              ],
              const SizedBox(height: Space.s20),
              Text(l.pinPhotoNeeded, style: t.titleSmall),
              const SizedBox(height: Space.s8),
              if (_photo == null)
                OutlinedButton.icon(onPressed: _takePhoto, icon: const Icon(Icons.photo_camera_rounded), label: Text(l.visitTakePhoto))
              else
                ClipRRect(
                  borderRadius: Radii.brXl,
                  child: Stack(children: [
                    Image.memory(_photo!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Positioned(
                      right: Space.s8,
                      bottom: Space.s8,
                      child: FilledButton.tonalIcon(onPressed: _takePhoto, icon: const Icon(Icons.refresh_rounded), label: Text(l.visitRetake)),
                    ),
                  ]),
                ),
              const SizedBox(height: Space.s4),
              Text(l.visitCameraOnly, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: Space.s16),
              TextField(controller: _note, maxLines: 2, maxLength: 500, decoration: InputDecoration(hintText: l.pinNoteHint, labelText: l.actionNote)),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s16),
              child: FilledButton.icon(
                icon: const Icon(Icons.send_rounded),
                onPressed: !ok
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        await ref.read(pinCorrectionServiceProvider).record(customer: c, fix: fix!, photo: _photo!, note: _note.text);
                        if (!context.mounted) return;
                        showAppSnack(context, l.pinSent);
                        context.pop();
                      },
                label: Text(l.pinSubmit),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Small status line on customer detail while a proposal is open.
class PinProposalStatus extends ConsumerWidget {
  const PinProposalStatus({super.key, required this.customerId});
  final String customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(openProposalProvider(customerId)).value;
    if (p == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Space.s12),
      child: InfoBanner(
        icon: p.syncState == 'failed' ? Icons.error_outline_rounded : Icons.hourglass_top_rounded,
        tone: p.syncState == 'failed' ? BannerTone.danger : BannerTone.info,
        text: p.syncState == 'failed' ? l.pinFailed : l.pinPending,
      ),
    );
  }
}
