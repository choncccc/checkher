import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme.dart';

/// Roads, rivers, sea and place names around Agoo, drawn by the app from
/// `assets/map/agoo_map.json` so the map works without internet. Rebuild the
/// asset with `tool/build_offline_map.py`.
class OfflineMapData {
  OfflineMapData._(this.bounds, this.sea, this.water, this.roads, this.places);

  final LatLngBounds bounds;
  final List<Polygon> sea;
  final List<Polyline> water;
  final List<Polyline> roads;
  final List<(String, LatLng, bool)> places; // name, position, is a town

  static Future<OfflineMapData>? _cached;

  static Future<OfflineMapData> load() => _cached ??= rootBundle
      .loadString('assets/map/agoo_map.json')
      .then(_parse);

  static const _sea = Color(0xFFBFE8F0);
  static const _river = Color(0xFF8FD3E3);

  static OfflineMapData _parse(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    List<LatLng> points(List<dynamic> flat) => [
      for (var i = 0; i < flat.length; i += 2)
        LatLng((flat[i] as num).toDouble(), (flat[i + 1] as num).toDouble()),
    ];
    final b = (json['bounds'] as List).cast<num>();
    return OfflineMapData._(
      LatLngBounds(
        LatLng(b[0].toDouble(), b[1].toDouble()),
        LatLng(b[2].toDouble(), b[3].toDouble()),
      ),
      [
        for (final s in json['sea'] as List)
          Polygon(points: points(s as List), color: _sea),
      ],
      [
        for (final w in json['water'] as List)
          Polyline(points: points(w as List), color: _river, strokeWidth: 2),
      ],
      [
        for (final r in json['roads'] as List)
          switch (r[0] as String) {
            'major' => Polyline(
              points: points(r[1] as List),
              color: const Color(0xFFFFE6A8),
              strokeWidth: 5,
              borderColor: const Color(0xFFE2C27A),
              borderStrokeWidth: 1,
            ),
            'minor' => Polyline(
              points: points(r[1] as List),
              color: Colors.white,
              strokeWidth: 3.5,
              borderColor: const Color(0xFFCFDDDA),
              borderStrokeWidth: 1,
            ),
            _ => Polyline(
              points: points(r[1] as List),
              color: Colors.white,
              strokeWidth: 2,
            ),
          },
      ],
      [
        for (final p in json['places'] as List)
          (
            p[0] as String,
            LatLng((p[1] as num).toDouble(), (p[2] as num).toDouble()),
            p[3] == 1,
          ),
      ],
    );
  }
}

/// A pin on the [OfflineMap].
class MapPin {
  const MapPin({required this.position, required this.onTap});
  final LatLng position;
  final VoidCallback onTap;
}

class OfflineMap extends StatefulWidget {
  const OfflineMap({
    super.key,
    required this.controller,
    required this.pins,
    this.selected,
  });

  final MapController controller;
  final List<MapPin> pins;
  final int? selected; // index into [pins] drawn highlighted

  @override
  State<OfflineMap> createState() => _OfflineMapState();
}

class _OfflineMapState extends State<OfflineMap> {
  // Built once: flutter_map re-checks the camera whenever the options
  // object changes, which fails mid-animation.
  MapOptions? _options;

  MapOptions _buildOptions(OfflineMapData data) => MapOptions(
    // Must already sit inside the bounds below, or the constraint check
    // fails before the fit is applied.
    initialCenter: data.bounds.center,
    // Start with every pin in view.
    initialCameraFit: CameraFit.coordinates(
      coordinates: [for (final p in widget.pins) p.position],
      padding: const EdgeInsets.fromLTRB(30, 50, 30, 20),
      maxZoom: 16,
    ),
    minZoom: 12,
    maxZoom: 18,
    backgroundColor: const Color(0xFFEFF5F3),
    cameraConstraint: CameraConstraint.containCenter(bounds: data.bounds),
    interactionOptions: const InteractionOptions(
      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pins = widget.pins;
    final selected = widget.selected;
    return FutureBuilder(
      future: OfflineMapData.load(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const ColoredBox(
            color: Color(0xFFEFF5F3),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return FlutterMap(
          mapController: widget.controller,
          options: _options ??= _buildOptions(data),
          children: [
            PolygonLayer(polygons: data.sea),
            PolylineLayer(polylines: data.water),
            PolylineLayer(polylines: data.roads),
            MarkerLayer(
              markers: [
                for (final (name, at, town) in data.places)
                  Marker(
                    point: at,
                    width: 120,
                    height: 20,
                    child: IgnorePointer(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: town ? 12 : 9,
                          fontWeight: town ? FontWeight.w700 : FontWeight.w500,
                          color: town
                              ? AppColors.ink
                              : AppColors.inkSoft.withAlpha(170),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (var i = 0; i < pins.length; i++)
                  if (i != selected) _pin(pins[i], false),
                // Selected pin last so it sits on top.
                if (selected != null) _pin(pins[selected], true),
              ],
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 9, color: AppColors.inkSoft),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Marker _pin(MapPin pin, bool isSelected) {
    final size = isSelected ? 46.0 : 34.0;
    return Marker(
      point: pin.position,
      width: size,
      height: size,
      // The pin's tip, not its middle, marks the spot.
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: pin.onTap,
        child: Icon(
          Icons.location_on,
          size: size,
          color: isSelected ? AppColors.periodRed : AppColors.deepTeal,
          shadows: const [Shadow(color: Color(0x55000000), blurRadius: 4)],
        ),
      ),
    );
  }
}
