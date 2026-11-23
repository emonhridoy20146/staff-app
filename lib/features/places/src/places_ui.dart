import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/feature/feature_manifest.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/auth.dart';
import 'places_data.dart';

/// The symbol of each place kind (the label next to it says the same in words).
IconData placeIconData(String icon) => switch (icon) {
      'shop' => Icons.storefront_rounded,
      'market' => Icons.shopping_basket_rounded,
      'mosque' => Icons.mosque_rounded,
      'school' => Icons.school_rounded,
      'bank' => Icons.account_balance_rounded,
      'hospital' => Icons.local_hospital_rounded,
      'bus_stop' => Icons.directions_bus_rounded,
      'office' => Icons.business_rounded,
      'landmark' => Icons.flag_rounded,
      _ => Icons.place_rounded,
    };

String placeIconLabel(AppLocalizations l, String icon) => switch (icon) {
      'shop' => l.placeIconShop,
      'market' => l.placeIconMarket,
      'mosque' => l.placeIconMosque,
      'school' => l.placeIconSchool,
      'bank' => l.placeIconBank,
      'hospital' => l.placeIconHospital,
      'bus_stop' => l.placeIconBusStop,
      'office' => l.placeIconOffice,
      'landmark' => l.placeIconLandmark,
      _ => l.placeIconOther,
    };

/// Google-Maps-style detail by zoom (owner decision 2026-11-22): far out no places at all, in the
/// middle only the small square icon, close in the icon with its name.
const placeIconMinZoom = 13.0;
const placeLabelMinZoom = 16.0;

/// How much of a place the map shows at [zoom].
enum PlaceDetail { hidden, icon, label }

PlaceDetail placeDetailAt(double zoom) => zoom < placeIconMinZoom
    ? PlaceDetail.hidden
    : zoom < placeLabelMinZoom
        ? PlaceDetail.icon
        : PlaceDetail.label;

/// The square: 24 dp with small rounded corners and the kind's icon inside. Not the customer
/// teardrop/round pin, so the two never look alike.
const _square = Space.s24;
const _squareIcon = Space.s16;

/// Width of a marker with its name; the name is cut with … beyond it.
const _labelW = 200.0;

/// FR-PLC-001: every place on every map, as much as the zoom allows. [mode] reference (the
/// pin-setting screen) draws the same markers but they take no touches. [exceptId] leaves one place
/// out (the move screen draws that one itself).
class PlacesLayer extends ConsumerWidget {
  const PlacesLayer({super.key, this.mode = MapLayerMode.interactive, this.exceptId});
  final MapLayerMode mode;
  final String? exceptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MapCamera.of rebuilds this layer as the map zooms.
    final detail = placeDetailAt(MapCamera.of(context).zoom);
    if (detail == PlaceDetail.hidden) return const SizedBox.shrink();
    final places = ref.watch(placesProvider).value ?? const <MapPlace>[];
    final tappable = mode == MapLayerMode.interactive;
    final label = detail == PlaceDetail.label;
    // A tappable marker keeps a 48 dp target around the square; a reference one is just the square.
    final box = tappable ? Sizes.minTarget : _square;
    final width = label ? _labelW : box;
    final layer = MarkerLayer(
      markers: [
        for (final p in places)
          if (p.id != exceptId)
            Marker(
              point: LatLng(p.row.lat, p.row.lng),
              width: width,
              height: box,
              // The square's centre sits on the point; the name runs to the right.
              alignment: label ? Alignment((width / 2 - box / 2) / (width / 2), 0) : Alignment.center,
              child: PlaceMarker(place: p, showLabel: label, box: box, onTap: tappable ? () => showPlaceDetails(context, p.id) : null),
            ),
      ],
    );
    return tappable ? layer : IgnorePointer(child: layer);
  }
}

class PlaceMarker extends StatelessWidget {
  const PlaceMarker({super.key, required this.place, this.onTap, this.showLabel = true, this.box = Sizes.minTarget});
  final MapPlace place;

  /// Null on a reference map: nothing to tap.
  final VoidCallback? onTap;
  final bool showLabel;

  /// Side of the area around the square (the tap target on an interactive map).
  final double box;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    // Waiting for a move = warning colour; the details sheet says it in words too.
    final st = place.movePending ? sem.warning : sem.info;
    final t = Theme.of(context).textTheme;
    final marker = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: box,
          height: box,
          child: Center(
            child: Container(
              key: const Key('place-square'),
              width: _square,
              height: _square,
              decoration: BoxDecoration(color: st.bg, borderRadius: Radii.brSm, border: Border.all(color: st.fg, width: 1.5)),
              child: Icon(placeIconData(place.icon), size: _squareIcon, color: st.fg),
            ),
          ),
        ),
        if (showLabel)
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: Space.s2),
              padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s2),
              decoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.92), borderRadius: Radii.brXs),
              child: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.labelMedium!.copyWith(color: cs.onSurface)),
            ),
          ),
      ],
    );
    return Semantics(
      button: onTap != null,
      label: '${place.name}, ${placeIconLabel(AppLocalizations.of(context), place.icon)}',
      excludeSemantics: true,
      child: onTap == null ? marker : GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: marker),
    );
  }
}

/// Long press on the map: a new place at that point (FR-PLC-002).
void openNewPlace(BuildContext context, WidgetRef ref, double lat, double lng) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => PlaceEditorSheet(lat: lat, lng: lng),
  );
}

/// Name, kind and note of a new place, or of one of my places.
class PlaceEditorSheet extends ConsumerStatefulWidget {
  const PlaceEditorSheet({super.key, this.lat, this.lng, this.place});
  final double? lat;
  final double? lng;
  final MapPlace? place;

  @override
  ConsumerState<PlaceEditorSheet> createState() => _PlaceEditorSheetState();
}

class _PlaceEditorSheetState extends ConsumerState<PlaceEditorSheet> {
  late final _name = TextEditingController(text: widget.place?.name ?? '');
  late final _note = TextEditingController(text: widget.place?.row.note ?? '');
  late String _icon = widget.place?.icon ?? 'shop';
  bool _tried = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _tried = true);
    if (_name.text.trim().isEmpty || _busy) return;
    setState(() => _busy = true);
    final l = AppLocalizations.of(context);
    final svc = ref.read(placeServiceProvider);
    final p = widget.place;
    if (p == null) {
      await svc.create(name: _name.text, icon: _icon, note: _note.text, lat: widget.lat!, lng: widget.lng!);
    } else {
      await svc.edit(p.id, name: _name.text, icon: _icon, note: _note.text);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnack(context, p == null ? l.placeSavedNew(_name.text.trim()) : l.placeSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final missing = _tried && _name.text.trim().isEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.screen + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.place == null ? l.placeNewTitle : l.placeEditTitle, style: t.titleLarge),
            const SizedBox(height: Space.s4),
            Text(l.placeNewHint, style: t.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: Space.s16),
            TextField(
              key: const Key('place-name'),
              controller: _name,
              maxLength: placeNameMax,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l.placeName, hintText: l.placeNameHint, errorText: missing ? l.placeNameRequired : null),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Space.s8),
            Text(l.placeKind, style: t.titleSmall),
            const SizedBox(height: Space.s8),
            Wrap(
              spacing: Space.s8,
              runSpacing: Space.s8,
              children: [
                for (final i in placeIcons)
                  ChoiceChip(
                    key: Key('place-icon-$i'),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    avatar: Icon(placeIconData(i), size: 20),
                    label: Text(placeIconLabel(l, i)),
                    selected: _icon == i,
                    onSelected: (_) => setState(() => _icon = i),
                  ),
              ],
            ),
            const SizedBox(height: Space.s16),
            TextField(
              key: const Key('place-note'),
              controller: _note,
              maxLength: placeNoteMax,
              maxLines: 2,
              decoration: InputDecoration(labelText: l.placeNote, hintText: l.placeNoteHint),
            ),
            const SizedBox(height: Space.s8),
            FilledButton.icon(
              key: const Key('place-save'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(Sizes.minTarget)),
              onPressed: _busy ? null : _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(widget.place == null ? l.placeAdd : l.placeSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tap on a place: what it is, who added it, a move waiting for the office, and what I may do.
void showPlaceDetails(BuildContext context, String localId) {
  showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => PlaceDetailsSheet(localId: localId));
}

class PlaceDetailsSheet extends ConsumerWidget {
  const PlaceDetailsSheet({super.key, required this.localId});
  final String localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final f = ref.watch(fmtProvider);
    final p = ref.watch(placeProvider(localId)).value;
    final me = ref.watch(sessionProvider).user?.id;
    if (p == null) return Padding(padding: const EdgeInsets.all(Space.s24), child: Text(l.placeGone));
    final mine = p.isMine(me);
    // ADR-M30: an office user (place.manage, from the server snapshot) moves the place itself, no request.
    final manage = ref.watch(accessProvider).can(Perm.placeManage);
    final decision = p.lastDecision;
    final error = p.createFailed || p.editFailed || p.moveFailed ? placeErrorText(l, p.row.errorCode) : null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.screen, 0, Space.screen, Space.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(placeIconData(p.icon), color: sem.info.fg),
              const SizedBox(width: Space.s8),
              Expanded(child: Text(p.name, style: t.titleLarge)),
            ]),
            const SizedBox(height: Space.s4),
            Text(placeIconLabel(l, p.icon), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
            if (p.row.note != null) ...[const SizedBox(height: Space.s12), Text(p.row.note!, style: t.bodyLarge)],
            const SizedBox(height: Space.s12),
            Text(mine ? l.placeAddedByMe : l.placeAddedBy(p.row.createdByName ?? ''), style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
            if (p.createQueued || p.editQueued || p.movedUnsent) ...[const SizedBox(height: Space.s8), _Note(icon: Icons.cloud_upload_rounded, text: l.placeWaitingToSend, style: sem.info)],
            if (p.movePending) ...[
              const SizedBox(height: Space.s8),
              _Note(icon: Icons.hourglass_top_rounded, text: p.moveQueued ? l.placeMoveQueued : l.placeMovePending(p.pendingByName ?? ''), style: sem.warning),
            ],
            if (!p.movePending && decision != null) ...[
              const SizedBox(height: Space.s8),
              _Note(
                icon: decision['decision'] == 'approve' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                text: decision['decision'] == 'approve' ? l.placeMoveApproved : l.placeMoveRejected((decision['reason'] as String?) ?? ''),
                style: decision['decision'] == 'approve' ? sem.success : sem.danger,
              ),
            ],
            if (error != null) ...[const SizedBox(height: Space.s8), _Note(icon: Icons.error_rounded, text: error, style: sem.danger)],
            const SizedBox(height: Space.s16),
            Wrap(spacing: Space.s12, runSpacing: Space.s8, children: [
              if (mine)
                OutlinedButton.icon(
                  key: const Key('place-edit'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(Sizes.minTarget, Sizes.minTarget)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => PlaceEditorSheet(place: p));
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(l.placeEdit),
                ),
              if (manage ? !p.createFailed : !p.movePending && !p.createFailed)
                FilledButton.tonalIcon(
                  key: const Key('place-move'),
                  style: FilledButton.styleFrom(minimumSize: const Size(Sizes.minTarget, Sizes.minTarget)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/places/${Uri.encodeComponent(p.id)}/move');
                  },
                  icon: const Icon(Icons.open_with_rounded),
                  label: Text(manage ? l.placeMoveNow : l.placeRequestMove),
                ),
            ]),
            if (p.row.updatedAt != null) ...[const SizedBox(height: Space.s12), Text(l.placeUpdatedAt(f.dateTime(p.row.updatedAt!)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant))],
          ],
        ),
      ),
    );
  }
}

String placeErrorText(AppLocalizations l, String? code) => switch (code) {
      'MOVE_PENDING' => l.placeErrMovePending,
      'MOVE_TOO_SHORT' => l.placeErrMoveTooShort,
      'OUTSIDE_BANGLADESH' => l.placeErrOutside,
      'MOVE_NEEDS_MANAGE' => l.placeErrMoveNeedsManage,
      'NOT_OWNER' || 'FORBIDDEN' => l.placeErrNotOwner,
      'NOT_FOUND' || 'PLACE_DELETED' => l.placeGone,
      _ => l.placeErrGeneric,
    };

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, required this.style});
  final IconData icon;
  final String text;
  final StatusStyle style;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(Space.s12),
        decoration: BoxDecoration(color: style.bg, borderRadius: Radii.brMd),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 20, color: style.fg),
          const SizedBox(width: Space.s8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: style.fg))),
        ]),
      );
}

/// FR-PLC-004: move the map under the fixed pin to the right spot, say why, send. The marker stays
/// where it is until the office approves. An office user (place.manage) moves it at once instead
/// (FR-PLC-003, ADR-M30): no reason field, offline-first, the marker moves now and goes back if refused.
class PlaceMoveScreen extends ConsumerStatefulWidget {
  const PlaceMoveScreen({super.key, required this.localId});
  final String localId;
  @override
  ConsumerState<PlaceMoveScreen> createState() => _PlaceMoveScreenState();
}

class _PlaceMoveScreenState extends ConsumerState<PlaceMoveScreen> {
  final _map = MapController();
  final _reason = TextEditingController();
  LatLng? _point;
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _send(MapPlace p, LatLng to, {required bool direct}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final svc = ref.read(placeServiceProvider);
    if (direct) {
      await svc.moveNow(p.id, lat: to.latitude, lng: to.longitude);
    } else {
      await svc.requestMove(p.id, lat: to.latitude, lng: to.longitude, reason: _reason.text);
    }
    if (!mounted) return;
    showAppSnack(context, direct ? l.placeMovedNow : l.placeMoveSent);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final p = ref.watch(placeProvider(widget.localId)).value;
    final tiles = ref.watch(tileConfigProvider);
    final tilesOn = ref.watch(mapTilesEnabledProvider);
    if (p == null) return Scaffold(appBar: AppBar(), body: Center(child: Text(l.placeGone)));
    final here = LatLng(p.row.lat, p.row.lng);
    final to = _point ?? here;
    final metres = const Distance().as(LengthUnit.Meter, here, to).round();
    final tooShort = metres < 5;
    final direct = ref.watch(accessProvider).can(Perm.placeManage);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.placeMoveTitle(p.name))),
      body: Column(children: [
        Expanded(
          child: Stack(children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: here,
                initialZoom: 18,
                maxZoom: tiles.maxZoom.toDouble(),
                backgroundColor: cs.surfaceContainer,
                onPositionChanged: (cam, _) => setState(() => _point = cam.center),
              ),
              children: [
                if (tilesOn) TileLayer(urlTemplate: tiles.urlTemplate, subdomains: tiles.subdomains, userAgentPackageName: 'bd.howlader.field.staff'),
                PlacesLayer(mode: MapLayerMode.reference, exceptId: p.id),
                MarkerLayer(markers: [
                  Marker(
                    point: here,
                    width: 28,
                    height: 28,
                    child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: sem.info.bg, border: Border.all(color: sem.info.fg, width: 2)), child: Icon(placeIconData(p.icon), size: 16, color: sem.info.fg)),
                  ),
                ]),
              ],
            ),
            // The fixed pin in the middle: the map moves under it.
            IgnorePointer(child: Center(child: Padding(padding: const EdgeInsets.only(bottom: 40), child: Icon(Icons.location_on_rounded, size: 48, color: sem.warning.fg)))),
          ]),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(Space.screen),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              Text(direct ? l.placeMoveNowHint : l.placeMoveHint, style: t.bodyMedium),
              const SizedBox(height: Space.s4),
              Text(l.placeMoveDistance(ref.watch(fmtProvider).num(metres)), style: t.titleSmall),
              const SizedBox(height: Space.s8),
              if (!direct) TextField(key: const Key('place-move-reason'), controller: _reason, maxLength: placeNoteMax, decoration: InputDecoration(labelText: l.placeMoveReason)),
              FilledButton.icon(
                key: const Key('place-move-send'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(Sizes.minTarget)),
                onPressed: tooShort || _busy ? null : () => _send(p, to, direct: direct),
                icon: Icon(direct ? Icons.check_rounded : Icons.send_rounded),
                label: Text(tooShort ? l.placeMoveDragFirst : direct ? l.placeMoveNowSave : l.placeMoveSend),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
