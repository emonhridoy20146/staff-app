import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/providers.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/brand.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/auth.dart';
import 'permission_requests.dart';

/// Privacy & tracking consent (versioned). Honest tracking principle.
class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final items = [
      (Icons.schedule_rounded, l.consentDutyOnly),
      (Icons.map_rounded, l.consentWhy),
      (Icons.visibility_rounded, l.consentVisible),
      (Icons.photo_camera_rounded, l.consentPhotos),
      (Icons.auto_delete_rounded, l.consentRetention),
    ];
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Space.s24, Space.s32, Space.s24, Space.s16),
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: Radii.brXl),
                    child: Icon(Icons.privacy_tip_rounded, size: 32, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(height: Space.s20),
                  Text(l.consentTitle, style: t.headlineSmall),
                  const SizedBox(height: Space.s8),
                  Text(l.consentIntro, style: t.bodyLarge!.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: Space.s24),
                  for (final (icon, text) in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.s16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: cs.surfaceContainer, shape: BoxShape.circle),
                            child: Icon(icon, size: 20, color: cs.primary),
                          ),
                          const SizedBox(width: Space.s16),
                          Expanded(child: Padding(padding: const EdgeInsets.only(top: Space.s8), child: Text(text, style: t.bodyLarge))),
                        ],
                      ),
                    ),
                  const SizedBox(height: Space.s8),
                  Text(l.consentVersion('2026-11-v1'), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s24, Space.s8, Space.s24, Space.s24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  onPressed: () => ref.read(sessionProvider.notifier).acceptConsent(),
                  label: Text(l.consentAgree),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Permissions primer: ALL permissions are mandatory before the user can
/// proceed. No "Later" button — field staff must grant every permission.
class PermissionsPrimerScreen extends ConsumerStatefulWidget {
  const PermissionsPrimerScreen({super.key});
  @override
  ConsumerState<PermissionsPrimerScreen> createState() => _PermissionsPrimerScreenState();
}

class _PermissionsPrimerScreenState extends ConsumerState<PermissionsPrimerScreen> with WidgetsBindingObserver {
  final _granted = <String>{};
  final _permanentlyDenied = <String>{};
  static const _ids = ['location', 'camera', 'notifications', 'battery'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkAll();
  }

  Future<void> _checkAll() async {
    final req = ref.read(permissionRequesterProvider);
    for (final id in _ids) {
      final ok = await req.isGranted(id);
      if (ok && mounted) {
        setState(() {
          _granted.add(id);
          _permanentlyDenied.remove(id);
        });
      }
    }
  }

  Future<void> _ask(String id) async {
    if (_permanentlyDenied.contains(id)) {
      await _openAppSettings();
      return;
    }
    final r = await ref.read(permissionRequesterProvider).request(id);
    if (!mounted) return;
    switch (r) {
      case PermissionResult.granted:
        setState(() {
          _granted.add(id);
          _permanentlyDenied.remove(id);
        });
      case PermissionResult.permanentlyDenied:
        setState(() => _permanentlyDenied.add(id));
      case PermissionResult.denied:
        if (id == 'battery') await _openBatterySettings();
    }
  }

  Future<void> _openBatterySettings() async {
    try {
      await const MethodChannel('com.howlader.staff/permissions').invokeMethod('openBatterySettings');
    } catch (_) {
      await _openAppSettings();
    }
  }

  Future<void> _openAppSettings() async {
    try {
      const channel = MethodChannel('com.howlader.staff/permissions');
      await channel.invokeMethod('openAppSettings');
    } catch (_) {
      await Geolocator.openAppSettings();
    }
  }

  bool get _allGranted => _ids.where((id) => id != 'battery').every(_granted.contains);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final deniedHints = {
      'location': l.primerDeniedLocation,
      'camera': l.primerDeniedCamera,
      'notifications': l.primerDeniedNotifications,
      'battery': l.primerDeniedBattery,
    };
    final items = [
      ('location', Icons.location_on_rounded, l.primerLocation, l.primerLocationBody),
      ('camera', Icons.photo_camera_rounded, l.primerCamera, l.primerCameraBody),
      ('notifications', Icons.notifications_active_rounded, l.primerNotifications, l.primerNotificationsBody),
      ('battery', Icons.battery_saver_rounded, l.primerBattery, l.primerBatteryBody),
    ];
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Space.s24, Space.s32, Space.s24, Space.s16),
                children: [
                  Text(l.primerTitle, style: t.headlineSmall),
                  const SizedBox(height: Space.s8),
                  Text(l.primerRequired, style: t.bodyLarge!.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: Space.s24),
                  for (final (id, icon, title, body) in items) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(icon, color: cs.primary),
                              const SizedBox(width: Space.s12),
                              Expanded(child: Text(title, style: t.titleMedium)),
                              if (_granted.contains(id))
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.check_circle_rounded, color: sem.success.fg, size: 20),
                                  const SizedBox(width: Space.s4),
                                  Text(l.primerAllowed, style: t.labelMedium!.copyWith(color: sem.success.fg)),
                                ])
                              else
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(minimumSize: const Size(96, Sizes.minTarget)),
                                  onPressed: () => _ask(id),
                                  child: Text(_permanentlyDenied.contains(id) ? l.primerOpenSettings : l.primerAllow),
                                ),
                            ],
                          ),
                          const SizedBox(height: Space.s8),
                          Text(body, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                          if (!_granted.contains(id) && _permanentlyDenied.contains(id)) ...[
                            const SizedBox(height: Space.s8),
                            Text(l.primerDeniedForever, style: t.bodySmall!.copyWith(color: sem.warning.fg)),
                          ] else if (!_granted.contains(id)) ...[
                            const SizedBox(height: Space.s8),
                            Text(deniedHints[id] ?? '', style: t.bodySmall!.copyWith(color: cs.error)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: Space.cardGap),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s24, Space.s8, Space.s24, Space.s24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _allGranted ? () => ref.read(sessionProvider.notifier).finishPrimer() : null,
                  child: Text(l.actionContinue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Initial bootstrap with progress (NFR-M-004).
class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});
  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    setState(() => _failed = false);
    await ref.read(sessionProvider.notifier).runBootstrap();
    if (!mounted) return;
    final st = ref.read(syncEngineProvider).current;
    if (st.lastErrorCode != null) setState(() => _failed = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final status = ref.watch(syncStatusProvider).value ?? const SyncStatus();
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.s32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandMark(size: 64),
              const SizedBox(height: Space.s32),
              Text(l.bootstrapTitle, style: t.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: Space.s8),
              Text(l.bootstrapBody, style: t.bodyLarge!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: Space.s32),
              if (_failed) ...[
                InfoBanner(icon: Icons.wifi_off_rounded, text: l.bootstrapFailed, tone: BannerTone.warning),
                const SizedBox(height: Space.s16),
                FilledButton(onPressed: _run, child: Text(l.actionRetry)),
              ] else
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(Radii.full)),
                  child: LinearProgressIndicator(value: status.bootstrapProgress, minHeight: 8),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 426 → update screen; the queue stays intact (FR-M-017).
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});
  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.system_update_rounded, size: 64, color: cs.primary),
              const SizedBox(height: Space.s24),
              Text(l.updateTitle, style: t.headlineSmall),
              const SizedBox(height: Space.s8),
              Text(l.updateBody, style: t.bodyLarge!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: Space.s32),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, child: Text(l.updateButton))),
            ],
          ),
        ),
      ),
    );
  }
}
