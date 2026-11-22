import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show BuildContext;

import '../../core/feature/feature_manifest.dart';
import '../../core/permissions/permission_service.dart';
import 'src/places_data.dart';
import 'src/places_ui.dart';

/// Map places (master FR-PLC-001..006, contract 1.38.0, field-api ADR-051): names on the map that
/// OpenStreetMap lacks. Long-press the customer map to add one (works offline); tap one to see it,
/// change my own, or ask the office to move it.
final placesManifest = FeatureManifest(
  name: 'places',
  flag: 'module.places',
  permissions: const [Perm.placeView, Perm.placeCreate],
  routes: [GoRoute(path: '/places/:id/move', builder: (_, s) => PlaceMoveScreen(localId: s.pathParameters['id']!))],
  pullHandlers: [PlacePullHandler()],
  pushHandlers: [PlacePushHandler()],
  mapLayers: [
    MapLayerDef(id: 'places', permission: Perm.placeView, layer: (_, _) => const PlacesLayer(), onLongPress: _longPress),
  ],
);

void _longPress(BuildContext context, WidgetRef ref, double lat, double lng) {
  // Only someone who may add a place gets the sheet; viewing needs place.view (the layer's permission).
  if (!ref.read(accessProvider).can(Perm.placeCreate)) return;
  openNewPlace(context, ref, lat, lng);
}
