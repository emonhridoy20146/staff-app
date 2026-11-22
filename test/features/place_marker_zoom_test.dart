import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/feature/feature_manifest.dart';
import 'package:staff_app/core/map/map_defaults.dart';
import 'package:staff_app/core/theme/app_theme.dart';
import 'package:staff_app/features/places/src/places_data.dart';
import 'package:staff_app/features/places/src/places_ui.dart';
import 'package:staff_app/l10n/app_localizations.dart';

/// Place markers by zoom (FR-M-063, owner decision 2026-11-22): far out nothing, in the middle only
/// the small square icon, close in the icon with its name.
void main() {
  const place = MapPlace(
    PlaceRow(localId: 'pl-1', serverId: 'pl-1', name: 'চরকাজল বাজার', icon: 'market', lat: 22.164, lng: 90.426, version: 1, createState: 'synced', editState: 'none', moveState: 'none'),
  );

  Future<void> pumpMap(WidgetTester t, double zoom, {MapLayerMode mode = MapLayerMode.interactive, Brightness brightness = Brightness.light}) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          placesProvider.overrideWith((_) => Stream.value(const [place])),
        ],
        child: MaterialApp(
          theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
          locale: const Locale('bn'),
          localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FlutterMap(
              options: MapOptions(initialCenter: const LatLng(22.164, 90.426), initialZoom: zoom),
              children: [PlacesLayer(mode: mode)],
            ),
          ),
        ),
      ),
    );
    await t.pump();
    await t.pump();
  }

  test('thresholds', () {
    expect(placeDetailAt(12.9), PlaceDetail.hidden);
    expect(placeDetailAt(placeIconMinZoom), PlaceDetail.icon);
    expect(placeDetailAt(15.9), PlaceDetail.icon);
    expect(placeDetailAt(placeLabelMinZoom), PlaceDetail.label);
    expect(placeDetailAt(19), PlaceDetail.label);
    // The app's default view (Galachipa) is far out: no clutter there.
    expect(placeDetailAt(defaultMapZoom), PlaceDetail.hidden);
  });

  testWidgets('zoomed far out: no place markers at all', (t) async {
    await pumpMap(t, 12);
    expect(find.byType(PlaceMarker), findsNothing);
    expect(find.text('চরকাজল বাজার'), findsNothing);
  });

  testWidgets('middle zoom: only the small square icon, no name', (t) async {
    await pumpMap(t, 14);
    expect(find.byType(PlaceMarker), findsOneWidget);
    expect(find.byKey(const Key('place-square')), findsOneWidget);
    expect(find.byIcon(Icons.shopping_basket_rounded), findsOneWidget);
    expect(find.text('চরকাজল বাজার'), findsNothing);
    final square = t.getSize(find.byKey(const Key('place-square')));
    expect(square.width, inInclusiveRange(20, 24));
    expect(square.height, square.width, reason: 'a square, not the customer pin');
    // Still a 48 dp target where it can be tapped.
    expect(t.getSize(find.byType(PlaceMarker)).height, greaterThanOrEqualTo(48));
    expect(t.getSize(find.byType(PlaceMarker)).width, greaterThanOrEqualTo(48));
  });

  testWidgets('zoomed in: the square icon and its name', (t) async {
    await pumpMap(t, 17, brightness: Brightness.dark);
    expect(find.byKey(const Key('place-square')), findsOneWidget);
    expect(find.text('চরকাজল বাজার'), findsOneWidget);
    expect(t.getSize(find.byType(PlaceMarker)).height, greaterThanOrEqualTo(48));
    // Tapping opens the details sheet.
    expect(find.descendant(of: find.byType(PlaceMarker), matching: find.byType(GestureDetector)), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('reference mode (pin screen): same marker, nothing to tap', (t) async {
    await pumpMap(t, 17, mode: MapLayerMode.reference);
    expect(find.text('চরকাজল বাজার'), findsOneWidget);
    expect(find.descendant(of: find.byType(PlaceMarker), matching: find.byType(GestureDetector)), findsNothing);
    expect(find.ancestor(of: find.byType(PlaceMarker), matching: find.byType(IgnorePointer)), findsWidgets);
  });

  testWidgets('name fits at 130 % text', (t) async {
    t.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpMap(t, 18);
    expect(find.text('চরকাজল বাজার'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
