import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
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
import '../../customers/customers.dart';

const visitOutcomes = ['paid', 'partial_paid', 'promised', 'not_home', 'refused', 'shifted_address', 'customer_dead', 'product_returned_request', 'other'];

String outcomeLabel(AppLocalizations l, String o) => switch (o) {
      'paid' => l.visitOutcomePaid,
      'partial_paid' => l.visitOutcomePartial,
      'promised' => l.visitOutcomePromised,
      'not_home' => l.visitOutcomeNotHome,
      'refused' => l.visitOutcomeRefused,
      'shifted_address' => l.visitOutcomeShifted,
      'customer_dead' => l.visitOutcomeDead,
      'product_returned_request' => l.visitOutcomeReturn,
      _ => l.visitOutcomeOther,
    };

IconData outcomeIcon(String o) => switch (o) {
      'paid' => Icons.task_alt_rounded,
      'partial_paid' => Icons.timelapse_rounded,
      'promised' => Icons.handshake_rounded,
      'not_home' => Icons.door_front_door_rounded,
      'refused' => Icons.block_rounded,
      'shifted_address' => Icons.moving_rounded,
      'customer_dead' => Icons.sentiment_very_dissatisfied_rounded,
      'product_returned_request' => Icons.assignment_return_rounded,
      _ => Icons.more_horiz_rounded,
    };

class VisitPushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'visit', 'visit_checkout'};
  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) async {
    if (m.entity != 'visit' || m.op != 'create') return;
    await (db.update(db.visits)..where((t) => t.clientId.equals(m.mutationId))).write(
      VisitsCompanion(serverId: Value(r.entityId), syncState: Value(r.result == 'rejected' ? 'failed' : 'synced')),
    );
  }
}

/// Pull: visits by others on my customers (last 5) and server copies of mine.
class VisitPullHandler implements PullHandler {
  @override
  String get entity => 'visit';
  @override
  Future<void> upsert(AppDatabase db, String id, Json d) async {
    final clientId = (d['clientId'] as String?) ?? id;
    final geo = (d['geo'] as Json?) ?? const {};
    await db.into(db.visits).insertOnConflictUpdate(VisitsCompanion.insert(
          clientId: clientId,
          serverId: Value(id),
          customerId: d['customerId'] as String,
          checkInAt: DateTime.parse(d['checkInAt'] as String).toUtc(),
          outcome: (d['outcome'] as String?) ?? 'other',
          lat: Value((geo['lat'] as num?)?.toDouble()),
          lng: Value((geo['lng'] as num?)?.toDouble()),
          distanceToPinM: Value((d['distanceToPinM'] as num?)?.toInt()),
          syncState: const Value('synced'),
        ));
  }

  @override
  Future<void> delete(AppDatabase db, String id, {String? reason}) async {}
}

/// Media hook: once photos are confirmed, link them to the visit.
Future<void> linkVisitPhotos(OutboxWriter outbox, AppDatabase db, String visitClientId, List<String> mediaIds) async {
  await (db.update(db.visits)..where((t) => t.clientId.equals(visitClientId))).write(VisitsCompanion(photoMediaClientIdsJson: Value(jsonEncode(mediaIds))));
  await outbox.enqueue(
    mutationId: const Uuid().v7(),
    entity: 'visit',
    op: 'update',
    dependsOn: [visitClientId],
    payload: {'clientId': visitClientId, 'photoMediaIds': mediaIds},
  );
}

Future<String> recordVisit(WidgetRef ref, {required Customer customer, required String outcome, required GeoFix? fix, Uint8List? photo, String? note}) async {
  final db = ref.read(databaseProvider);
  final clock = ref.read(clockProvider);
  final id = const Uuid().v7();
  final at = clock.nowUtc();
  final dist = fix != null && customer.hasPin ? distanceMeters(fix.lat, fix.lng, customer.row.lat!, customer.row.lng!) : null;
  await db.transaction(() async {
    await db.into(db.visits).insert(VisitsCompanion.insert(
          clientId: id,
          customerId: customer.id,
          checkInAt: at,
          outcome: outcome,
          lat: Value(fix?.lat),
          lng: Value(fix?.lng),
          accuracyM: Value(fix?.accuracyM),
          mock: Value(fix?.mock ?? false),
          distanceToPinM: Value(dist),
          note: Value(note),
        ));
    await ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'visit', payload: {
      'clientId': id,
      'customerId': customer.id,
      'checkInAt': at.toIso8601String(),
      'deviceTime': clock.deviceNowUtc().toIso8601String(),
      'outcome': outcome,
      ...geoFields(fix, ref.read(locationEngineProvider).lastFailureReason),
      'source': 'manual',
    });
    await ref.read(customerRepositoryProvider).applyLocalVisit(customer.id, at);
  });
  if (photo != null) {
    final user = await ref.read(secureStoreProvider).read('session_user');
    final code = user == null ? '' : ((jsonDecode(user) as Map)['employeeCode'] ?? '').toString();
    final f = ref.read(fmtProvider);
    final wm = '${f.dateTime(at).replaceAll(RegExp('[^\\x00-\\x7F]'), '')} ${clock.businessDate()} $code ${fix == null ? '' : '${fix.lat.toStringAsFixed(5)},${fix.lng.toStringAsFixed(5)}'}';
    final processed = await processPhoto(photo, watermark: wm.trim());
    await ref.read(mediaServiceProvider).enqueue(photo: processed, kind: 'visit_photo', ownerEntity: 'visit', ownerClientId: id, fix: fix);
  }
  if (note != null && note.trim().isNotEmpty) {
    // Note is its own entity, depending on the visit.
    final nid = const Uuid().v7();
    await db.transaction(() async {
      await db.into(db.notes).insert(NotesCompanion.insert(clientId: nid, customerId: customer.id, body: note.trim(), createdAt: at));
      await ref.read(outboxWriterProvider).enqueue(
        mutationId: nid,
        entity: 'note',
        dependsOn: [id],
        payload: {'clientId': nid, 'customerId': customer.id, 'text': note.trim(), 'category': 'general', 'visitClientId': id},
      );
    });
  }
  unawaited(ref.read(syncEngineProvider).kick(reason: 'visit'));
  return id;
}

final visitsForCustomerProvider = StreamProvider.family<List<VisitRow>, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.visits)..where((t) => t.customerId.equals(id))..orderBy([(t) => OrderingTerm.desc(t.checkInAt)])).watch();
});

final todayVisitCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final start = parseBusinessDateUtcStart(ref.watch(clockProvider).businessDate());
  final c = db.visits.clientId.count();
  final q = db.selectOnly(db.visits)
    ..addColumns([c])
    ..where(db.visits.checkInAt.isBiggerOrEqualValue(start) & db.visits.userName.isNull());
  return q.map((r) => r.read(c) ?? 0).watchSingle();
});

DateTime parseBusinessDateUtcStart(String ymd) {
  final p = ymd.split('-').map(int.parse).toList();
  return DateTime.utc(p[0], p[1], p[2]).subtract(const Duration(hours: 6));
}

/// Visit check-in (design guide §5.5).
class VisitScreen extends ConsumerStatefulWidget {
  const VisitScreen({super.key, required this.customerId});
  final String customerId;
  @override
  ConsumerState<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends ConsumerState<VisitScreen> {
  String? _outcome;
  Uint8List? _photo;
  final _note = TextEditingController();
  late final Future<GeoFix?> _fix = ref.read(locationEngineProvider).currentFix();
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
    return Scaffold(
      appBar: AppBar(title: Text(l.visitTitle)),
      body: ListView(
        padding: const EdgeInsets.all(Space.screen),
        children: [
          Text(c.nameOf(lang), style: t.titleLarge),
          Text(c.code, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: Space.s16),
          FutureBuilder<GeoFix?>(
            future: _fix,
            builder: (context, s) {
              if (s.connectionState != ConnectionState.done) {
                return InfoBanner(icon: Icons.my_location_rounded, text: l.collectGpsSearching);
              }
              final g = s.data;
              if (g == null) return InfoBanner(icon: Icons.location_disabled_rounded, text: l.collectGpsNone, tone: BannerTone.warning);
              if (g.mock) return InfoBanner(icon: Icons.gpp_maybe_rounded, text: l.collectGpsMock, tone: BannerTone.danger);
              final d = c.hasPin ? distanceMeters(g.lat, g.lng, c.row.lat!, c.row.lng!) : null;
              final radius = (ref.read(serverSettingsProvider)['geofenceRadiusM'] as num?)?.toInt() ?? 150;
              if (d != null && d > radius) return InfoBanner(icon: Icons.wrong_location_rounded, text: l.visitFar(f.distance(d)), tone: BannerTone.warning);
              return InfoBanner(icon: Icons.gps_fixed_rounded, text: l.collectGpsAccurate(f.num(g.accuracyM.round())), tone: BannerTone.success);
            },
          ),
          const SizedBox(height: Space.s20),
          Text(l.visitOutcome, style: t.titleSmall),
          const SizedBox(height: Space.s8),
          Wrap(spacing: Space.s8, runSpacing: Space.s8, children: [
            for (final o in visitOutcomes)
              ChoiceChip(
                selected: _outcome == o,
                avatar: Icon(outcomeIcon(o), size: 18),
                showCheckmark: false,
                label: Text(outcomeLabel(l, o)),
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() => _outcome = o);
                },
              ),
          ]),
          const SizedBox(height: Space.s20),
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
          TextField(controller: _note, maxLines: 3, maxLength: 2000, decoration: InputDecoration(hintText: l.noteHint, labelText: l.actionNote)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s16),
          child: FilledButton(
            onPressed: _outcome == null || _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    final fix = await _fix;
                    await recordVisit(ref, customer: c, outcome: _outcome!, fix: fix, photo: _photo, note: _note.text);
                    if (!context.mounted) return;
                    showAppSnack(context, l.visitSaved);
                    if (_outcome == 'paid' || _outcome == 'partial_paid') {
                      context.pushReplacement('/collect/${c.id}');
                    } else if (_outcome == 'promised') {
                      context.pop('promise');
                    } else {
                      context.pop();
                    }
                  },
            child: Text(l.actionSave),
          ),
        ),
      ),
    );
  }
}

Stream<List<VisitRow>> watchVisitsFor(WidgetRef ref, String customerId) {
  final db = ref.read(databaseProvider);
  return (db.select(db.visits)..where((t) => t.customerId.equals(customerId))..orderBy([(t) => OrderingTerm.desc(t.checkInAt)])).watch();
}
