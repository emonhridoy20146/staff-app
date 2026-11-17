import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/location/location_engine.dart';
import '../../../../core/media/media.dart';
import '../../../../core/providers.dart';
import '../../../../core/settings/ui_prefs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/common.dart';
import '../../../../l10n/app_localizations.dart';
import '../customer_providers.dart';
import '../domain/customer.dart';
import '../domain/map_pin.dart';
import '../pin_correction.dart';

/// Barishal, when neither the customer nor the phone has a position.
const _fallback = LatLng(22.7010, 90.3535);

/// Set or move a customer's pin (FR-CUS-008, FR-CUS-011), ride-app style:
/// the pin stays in the middle and the map moves under it. Starts at the
/// customer's pin, else at the phone's position. Works offline (the pin is
/// saved and sent later); only the map tiles need the network.
class MapPinScreen extends ConsumerStatefulWidget {
  const MapPinScreen({super.key, required this.customerId});
  final String customerId;
  @override
  ConsumerState<MapPinScreen> createState() => _MapPinScreenState();
}

class _MapPinScreenState extends ConsumerState<MapPinScreen> {
  final _map = MapController();
  final _note = TextEditingController();
  LatLng? _start;
  LatLng? _point;
  bool _ready = false;
  bool _moving = false;
  bool _touched = false;
  bool _locating = true;
  GeoFix? _phone;
  Uint8List? _photo;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_locate());
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Fresh fix of the phone. Brings the map there when asked (my-location
  /// button), or on first open for a customer without a pin until the staff
  /// has moved the map themself.
  Future<void> _locate({bool bringHere = false}) async {
    setState(() => _locating = true);
    final fix = await ref.read(locationEngineProvider).currentFix();
    if (!mounted) return;
    setState(() {
      _phone = fix ?? _phone;
      _locating = false;
    });
    _jumpToPhone(always: bringHere);
  }

  void _jumpToPhone({bool always = false}) {
    final fix = _phone;
    final c = ref.read(customerProvider(widget.customerId)).value;
    if (fix != null && _ready && (always || (!_touched && c != null && !c.hasPin))) _go(LatLng(fix.lat, fix.lng));
  }

  void _go(LatLng p, {double? zoom}) {
    _map.move(p, zoom ?? (_map.camera.zoom < 17 ? 18 : _map.camera.zoom));
    setState(() => _point = p);
  }

  Future<void> _takePhoto() async {
    final bytes = await ref.read(photoCapturerProvider).capture(context);
    if (bytes != null) setState(() => _photo = bytes);
  }

  Future<void> _typeCoords() async {
    final p = await showDialog<({double lat, double lng})>(context: context, builder: (_) => const _CoordsDialog());
    if (p != null && mounted) {
      _touched = true;
      _go(LatLng(p.lat, p.lng), zoom: 18);
    }
  }

  void _onEvent(MapEvent e) {
    final moving = switch (e) {
      MapEventMoveStart() || MapEventFlingAnimationStart() || MapEventDoubleTapZoomStart() => true,
      MapEventMoveEnd() || MapEventFlingAnimationEnd() || MapEventFlingAnimationNotStarted() || MapEventDoubleTapZoomEnd() => false,
      _ => _moving,
    };
    if (moving != _moving) setState(() => _moving = moving);
  }

  Future<void> _send(Customer c, LatLng p, MapPinCheck check) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    await ref.read(pinCorrectionServiceProvider).record(customer: c, lat: p.latitude, lng: p.longitude, phone: _phone, photo: _photo, note: _note.text);
    if (!mounted) return;
    showAppSnack(context, check.appliesAtOnce ? l.pinSentApplied : l.pinSent);
    // Opened from a link (nothing under it): show the customer instead.
    context.canPop() ? context.pop() : context.go('/customers/${c.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final tiles = ref.watch(tileConfigProvider);
    final tilesOn = ref.watch(mapTilesEnabledProvider);
    final policy = ref.watch(staffPinApprovalProvider);
    final c = ref.watch(customerProvider(widget.customerId)).value;
    if (c == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final old = c.hasPin ? LatLng(c.row.lat!, c.row.lng!) : null;
    final start = _start ??= old ?? (_phone != null ? LatLng(_phone!.lat, _phone!.lng) : null) ?? _fallback;
    final p = _point ?? start;
    final check = checkMapPin(lat: p.latitude, lng: p.longitude, phone: _phone, customerHasUsablePin: c.pinUsable, policy: policy);
    final movedM = old == null ? null : distanceMeters(old.latitude, old.longitude, p.latitude, p.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(c.hasPin ? l.actionCorrectLocation : l.actionSetLocation),
        actions: [IconButton(tooltip: l.pinTypeCoords, onPressed: _typeCoords, icon: const Icon(Icons.edit_location_alt_rounded))],
      ),
      body: LayoutBuilder(
        builder: (context, box) => Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Semantics(
                    label: l.pinMapLabel,
                    child: FlutterMap(
                      mapController: _map,
                      options: MapOptions(
                        initialCenter: start,
                        initialZoom: old != null || _phone != null ? 18 : 14,
                        maxZoom: tiles.maxZoom.toDouble(),
                        backgroundColor: cs.surfaceContainer,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                        onMapReady: () {
                          _ready = true;
                          _jumpToPhone();
                        },
                        onMapEvent: _onEvent,
                        onPositionChanged: (camera, gesture) {
                          if (gesture) _touched = true;
                          setState(() => _point = camera.center);
                        },
                        onTap: (_, at) {
                          _touched = true;
                          _go(at, zoom: _map.camera.zoom);
                        },
                      ),
                      children: [
                        if (tilesOn) TileLayer(urlTemplate: tiles.urlTemplate, subdomains: tiles.subdomains, userAgentPackageName: 'bd.howlader.field.staff'),
                        MarkerLayer(
                          markers: [
                            if (old != null) Marker(point: old, width: 24, height: 24, child: const _OldPin()),
                            if (_phone != null) Marker(point: LatLng(_phone!.lat, _phone!.lng), width: 28, height: 28, child: const _PhoneDot()),
                          ],
                        ),
                        if (tilesOn)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(Space.s4),
                              child: Text(tiles.attribution, style: t.labelSmall!.copyWith(color: cs.onSurfaceVariant)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // The pin itself: fixed in the middle, its tip on the map centre.
                  IgnorePointer(
                    child: Center(child: _CentrePin(lifted: _moving)),
                  ),
                  Positioned(
                    right: Space.screen,
                    bottom: Space.screen,
                    child: FloatingActionButton.small(
                      heroTag: 'pin-my-location',
                      tooltip: l.mapMyLocation,
                      onPressed: _locating ? null : () => _locate(bringHere: true),
                      child: _locating ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location_rounded),
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: box.maxHeight * 0.45),
              child: Material(
                color: cs.surface,
                elevation: 4,
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(Space.screen, Space.s12, Space.screen, Space.s8),
                  children: [
                    Text(c.nameOf(lang), style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: Space.s4),
                    Text(l.pinIntro, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: Space.s8),
                    Semantics(
                      liveRegion: true,
                      label: '${l.pinAt} ${formatCoords(p.latitude, p.longitude)}',
                      excludeSemantics: true,
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 20, color: cs.primary),
                          const SizedBox(width: Space.s8),
                          Text(formatCoords(p.latitude, p.longitude), style: t.bodyMedium!.copyWith(fontFamily: AppTheme.monoFamily)),
                        ],
                      ),
                    ),
                    if (movedM != null) Text(l.pinDistanceFromOld(f.distance(movedM)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                    Text(
                      _locating && _phone == null
                          ? l.collectGpsSearching
                          : check.phoneDistanceM == null
                          ? l.pinPhoneUnknown
                          : (check.farFromPhone ? l.pinPhoneFar(f.distance(check.phoneDistanceM!)) : l.pinPhoneDistance(f.distance(check.phoneDistanceM!))),
                      style: t.bodySmall!.copyWith(color: check.farFromPhone ? context.semanticColors.warning.fg : cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: Space.s8),
                    if (check.outside)
                      InfoBanner(icon: Icons.wrong_location_rounded, tone: BannerTone.danger, text: l.pinOutside)
                    else if (check.phoneMock)
                      InfoBanner(icon: Icons.gpp_maybe_rounded, tone: BannerTone.warning, text: l.pinPhoneMock)
                    else
                      InfoBanner(
                        icon: check.appliesAtOnce ? Icons.bolt_rounded : Icons.verified_user_rounded,
                        tone: check.appliesAtOnce ? BannerTone.success : BannerTone.info,
                        text: check.appliesAtOnce ? l.pinWillApply : l.pinNeedsManager,
                      ),
                    const SizedBox(height: Space.s8),
                    Row(
                      children: [
                        if (_photo != null) ...[
                          ClipRRect(
                            borderRadius: Radii.brMd,
                            child: Image.memory(_photo!, width: 48, height: 48, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: Space.s8),
                        ],
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _takePhoto,
                            icon: Icon(_photo == null ? Icons.photo_camera_rounded : Icons.refresh_rounded),
                            label: Text(_photo == null ? l.pinPhotoOptional : l.visitRetake, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.s8),
                    TextField(
                      controller: _note,
                      maxLines: 1,
                      maxLength: 500,
                      decoration: InputDecoration(hintText: l.pinNoteHint, labelText: l.actionNote, counterText: ''),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s16),
          child: FilledButton.icon(
            icon: Icon(check.appliesAtOnce ? Icons.add_location_alt_rounded : Icons.send_rounded),
            onPressed: !check.canSend || _busy ? null : () => _send(c, p, check),
            label: Text(check.appliesAtOnce ? l.pinSubmitApply : l.pinSubmit),
          ),
        ),
      ),
    );
  }
}

/// Fixed centre pin; lifts while the map moves (its shadow dot stays on the
/// point, so the exact spot is always visible).
class _CentrePin extends StatelessWidget {
  const _CentrePin({required this.lifted});
  final bool lifted;
  static const _size = 48.0;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduce = MediaQuery.of(context).disableAnimations;
    return SizedBox(
      width: _size,
      height: _size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: lifted ? 10 : 6,
            height: lifted ? 10 : 6,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: lifted ? 0.25 : 0.45),
              shape: BoxShape.circle,
            ),
          ),
          AnimatedPositioned(
            duration: reduce ? Duration.zero : const Duration(milliseconds: 150),
            top: lifted ? -8 : 0,
            child: Icon(
              Icons.location_on_rounded,
              size: _size,
              color: cs.primary,
              shadows: [Shadow(blurRadius: 4, offset: const Offset(0, 2), color: cs.shadow.withValues(alpha: 0.25))],
            ),
          ),
        ],
      ),
    );
  }
}

/// The customer's pin as it is now, hollow, for comparison.
class _OldPin extends StatelessWidget {
  const _OldPin();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.onSurfaceVariant.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: cs.onSurfaceVariant, width: 2.5),
      ),
    );
  }
}

/// Where the phone is.
class _PhoneDot extends StatelessWidget {
  const _PhoneDot();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: cs.secondary.withValues(alpha: 0.2), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: cs.secondary,
          shape: BoxShape.circle,
          border: Border.all(color: cs.surface, width: 2),
        ),
      ),
    );
  }
}

/// Coordinates typed or pasted (e.g. a location the customer shared).
class _CoordsDialog extends StatefulWidget {
  const _CoordsDialog();
  @override
  State<_CoordsDialog> createState() => _CoordsDialogState();
}

class _CoordsDialogState extends State<_CoordsDialog> {
  final _text = TextEditingController();
  bool _error = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _go() {
    final p = parseCoords(_text.text);
    if (p == null) return setState(() => _error = true);
    Navigator.of(context).pop(p);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) setState(() => (_text.text = data!.text!, _error = false));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.pinTypeCoords),
      content: TextField(
        controller: _text,
        autofocus: true,
        keyboardType: TextInputType.text,
        onChanged: (_) => _error ? setState(() => _error = false) : null,
        onSubmitted: (_) => _go(),
        decoration: InputDecoration(
          hintText: '22.70123, 90.37011',
          helperText: l.pinTypeCoordsHelp,
          helperMaxLines: 2,
          errorText: _error ? l.pinTypeCoordsError : null,
          suffixIcon: IconButton(tooltip: MaterialLocalizations.of(context).pasteButtonLabel, onPressed: _paste, icon: const Icon(Icons.content_paste_rounded)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
        FilledButton(onPressed: _go, child: Text(l.pinGo)),
      ],
    );
  }
}
