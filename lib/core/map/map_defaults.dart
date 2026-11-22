import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../feature/feature_manifest.dart';
import '../permissions/permission_service.dart';

/// Where every map opens when there is no better point (no customer pin, no
/// GPS fix): Galachipa upazila, Patuakhali (owner decision 2026-11-22).
const defaultMapCenter = LatLng(22.164, 90.426);

/// Zoom of [defaultMapCenter]: the whole upazila in view.
const defaultMapZoom = 12.0;

/// The map layers of every feature (map places, FR-PLC-001) the user may see:
/// the feature's flag is on and the layer's permission is held. Every map of
/// the app draws these, so a feature's layer shows on all of them.
final mapLayersProvider = Provider<List<MapLayerDef>>((ref) {
  final access = ref.watch(accessProvider);
  return [
    for (final m in ref.watch(featureManifestsProvider))
      if (access.flag(m.flag))
        for (final x in m.mapLayers)
          if (x.permission == null || access.can(x.permission!)) x,
  ];
});
