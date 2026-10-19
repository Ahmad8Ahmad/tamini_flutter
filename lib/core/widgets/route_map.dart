import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';
import '../theme/app_localizations.dart';
import '../theme/app_theme.dart';

/// Shared OpenStreetMap tile layer. Kept in one place so the tile server,
/// user-agent and attribution never drift between screens.
TileLayer osmTileLayer() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.tamini.app',
);

MapOptions _mapOptions({
  required LatLng center,
  required double zoom,
  void Function(LatLng)? onTap,
}) => MapOptions(
  initialCenter: center,
  initialZoom: zoom,
  onTap: onTap == null ? null : (_, point) => onTap(point),
  interactionOptions: const InteractionOptions(
    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
  ),
);

/// The circular white-bordered icon marker used across the route maps.
Marker circleMarker(LatLng point, IconData icon, Color color) => Marker(
  point: point,
  width: 34,
  height: 34,
  child: Container(
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Icon(icon, size: 18, color: Colors.white),
  ),
);

/// Static restaurant → customer route map (no live driver).
class RouteMapCard extends StatelessWidget {
  const RouteMapCard({
    super.key,
    required this.origin,
    required this.destination,
    this.height = 220,
  });

  final LatLng origin;
  final LatLng destination;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppTheme.roundedLg,
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: _mapOptions(center: origin, zoom: 13),
          children: [
            osmTileLayer(),
            MarkerLayer(
              markers: [
                circleMarker(origin, Icons.store_outlined, AppTheme.info),
                circleMarker(
                  destination,
                  Icons.location_on_outlined,
                  AppTheme.orange500,
                ),
              ],
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [origin, destination],
                  strokeWidth: 3,
                  color: AppTheme.orange400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Live order map: draws whatever points the tracking payload has (restaurant,
/// driver, customer), frames them again whenever the driver moves, and falls
/// back to [fallbackPoint] before the first tracking response arrives. Shows
/// the "tracking unavailable" placeholder when there is nothing to draw.
class TrackingMapCard extends StatefulWidget {
  const TrackingMapCard({
    super.key,
    required this.tracking,
    this.fallbackPoint,
    this.height = 260,
    this.placeholderHeight = 240,
    required this.onOpenInMaps,
  });

  final OrderTracking? tracking;
  final LatLng? fallbackPoint;
  final double height;
  final double placeholderHeight;
  final VoidCallback onOpenInMaps;

  @override
  State<TrackingMapCard> createState() => _TrackingMapCardState();
}

class _TrackingMapCardState extends State<TrackingMapCard> {
  final _mapController = MapController();
  LatLng? _lastDriverPos;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<LatLng> get _points {
    final t = widget.tracking;
    final points = <LatLng>[];
    if (t != null) {
      if (t.restaurantLat != null && t.restaurantLng != null) {
        points.add(LatLng(t.restaurantLat!, t.restaurantLng!));
      }
      if (t.hasDriverLocation) {
        points.add(LatLng(t.driverLat!, t.driverLng!));
      }
      if (t.deliveryLat != null && t.deliveryLng != null) {
        points.add(LatLng(t.deliveryLat!, t.deliveryLng!));
      }
    }
    if (points.isEmpty && widget.fallbackPoint != null) {
      points.add(widget.fallbackPoint!);
    }
    return points;
  }

  List<Marker> get _markers {
    final t = widget.tracking;
    final markers = <Marker>[];
    if (t == null) return markers;
    if (t.restaurantLat != null && t.restaurantLng != null) {
      markers.add(
        circleMarker(
          LatLng(t.restaurantLat!, t.restaurantLng!),
          Icons.store_outlined,
          AppTheme.info,
        ),
      );
    }
    if (t.hasDriverLocation) {
      markers.add(
        circleMarker(
          LatLng(t.driverLat!, t.driverLng!),
          Icons.delivery_dining_outlined,
          AppTheme.orange500,
        ),
      );
    }
    if (t.deliveryLat != null && t.deliveryLng != null) {
      markers.add(
        circleMarker(
          LatLng(t.deliveryLat!, t.deliveryLng!),
          Icons.home_outlined,
          AppTheme.success,
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final points = _points;
    if (points.isEmpty) return _placeholder(context);

    final t = widget.tracking;
    final restaurantPos = t != null &&
            t.restaurantLat != null &&
            t.restaurantLng != null
        ? LatLng(t.restaurantLat!, t.restaurantLng!)
        : null;
    final deliveryPos = t != null && t.deliveryLat != null && t.deliveryLng != null
        ? LatLng(t.deliveryLat!, t.deliveryLng!)
        : null;

    _scheduleFollowIfMoved(points);

    return ClipRRect(
      borderRadius: AppTheme.roundedLg,
        child: SizedBox(
          height: widget.height,
          child: FlutterMap(
            mapController: _mapController,
            options: _mapOptions(center: points.first, zoom: 13),
          children: [
            osmTileLayer(),
            MarkerLayer(markers: _markers),
            if (restaurantPos != null && deliveryPos != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [restaurantPos, deliveryPos],
                    strokeWidth: 3,
                    color: AppTheme.orange400,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      height: widget.placeholderHeight,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: context.colors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 44, color: AppTheme.gray400),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
            child: Text(
              loc.trackingUnavailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: widget.onOpenInMaps,
            icon: const Icon(Icons.map_outlined, size: 18),
            label: Text(
              loc.openInMaps,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.orange600,
              side: const BorderSide(color: AppTheme.orange400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Defers the follow-camera work out of `build`. Mutating `_lastDriverPos`
  /// and driving the map controller are side effects that must not run while
  /// the widget tree is being built.
  void _scheduleFollowIfMoved(List<LatLng> points) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final t = widget.tracking;
      if (t == null || !t.hasDriverLocation) return;
      final driverPos = LatLng(t.driverLat!, t.driverLng!);
      if (_lastDriverPos == driverPos) return;
      _lastDriverPos = driverPos;
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(48),
        ),
      );
    });
  }
}
