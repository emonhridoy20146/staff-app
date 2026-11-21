import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/status_colors.dart';

/// Whether the phone's location switch is on, live (it follows the switch
/// without restarting the app).
final gpsEnabledProvider = StreamProvider<bool>((ref) async* {
  yield await Geolocator.isLocationServiceEnabled();
  yield* ref.watch(gpsStatusStreamProvider);
});

/// The platform's location-switch changes; tests replace it with an empty stream.
final gpsStatusStreamProvider = Provider<Stream<bool>>((ref) => Geolocator.getServiceStatusStream().map((s) => s == ServiceStatus.enabled));

/// GPS on/off icon for the app header: green pin when on, red crossed pin
/// when off (tap opens the location settings).
class GpsStatusIcon extends ConsumerWidget {
  const GpsStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final sem = context.semanticColors;
    final on = ref.watch(gpsEnabledProvider).value ?? true;
    return IconButton(
      tooltip: on ? l.gpsStatusOn : l.gpsStatusOff,
      color: on ? sem.success.fg : sem.danger.fg,
      icon: Icon(on ? Icons.location_on_rounded : Icons.location_off_rounded),
      onPressed: on ? null : Geolocator.openLocationSettings,
      disabledColor: sem.success.fg,
    );
  }
}
