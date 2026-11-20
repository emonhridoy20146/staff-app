import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Blocks the entire app when location permission is not granted or GPS is off.
/// Shown as an overlay on the main app shell whenever the user is signed in
/// and on duty (or about to start duty).
class LocationGateScreen extends ConsumerStatefulWidget {
  const LocationGateScreen({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<LocationGateScreen> createState() => _LocationGateScreenState();
}

class _LocationGateScreenState extends ConsumerState<LocationGateScreen> with WidgetsBindingObserver {
  bool _permissionOk = true;
  bool _serviceOk = true;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      final perm = await Geolocator.checkPermission();
      final permOk = perm == LocationPermission.always || perm == LocationPermission.whileInUse;
      if (mounted) {
        setState(() {
          _serviceOk = service;
          _permissionOk = permOk;
        });
      }
    } catch (_) {
    } finally {
      _checking = false;
    }
  }

  Future<void> _requestPermission() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    } else {
      final r = await Geolocator.requestPermission();
      if (r == LocationPermission.always || r == LocationPermission.whileInUse) {
        await _check();
      }
    }
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionOk && _serviceOk) return widget.child;

    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.s32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_rounded, size: 72, color: cs.error),
              const SizedBox(height: Space.s24),
              Text(l.locationGateTitle, style: t.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: Space.s12),
              Text(l.locationGateBody, style: t.bodyLarge!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: Space.s32),
              if (!_permissionOk) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.location_on_rounded),
                    onPressed: _requestPermission,
                    label: Text(l.locationGatePermission),
                  ),
                ),
                const SizedBox(height: Space.s12),
              ],
              if (!_serviceOk) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _openLocationSettings,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.gps_fixed_rounded),
                        const SizedBox(width: Space.s8),
                        Text(l.locationGateService),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Space.s12),
              ],
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _check,
                  label: Text(l.locationGateRetry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
