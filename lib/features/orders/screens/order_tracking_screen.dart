import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tamini_badge.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const _pollInterval = Duration(seconds: 10);
  Timer? _pollTimer;
  MapController? _mapController;
  LatLng? _lastDriverPos;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _startPolling();
  }

  void _startPolling() {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    provider.fetchTracking(widget.order.id);
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!mounted) return;
      final p = Provider.of<OrderProvider>(context, listen: false);
      if (!_isActive(widget.order.status)) return;
      p.fetchTracking(widget.order.id);
    });
  }

  bool _isActive(String status) {
    const active = {'Pending', 'Confirmed', 'Preparing', 'In Progress', 'Out for Delivery'};
    return active.contains(status);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _openInMaps(OrderTracking? tracking) async {
    final order = widget.order;
    final lat = tracking?.deliveryLat ?? (order.deliveryLat != 0 ? order.deliveryLat : null);
    final lng = tracking?.deliveryLng ?? (order.deliveryLng != 0 ? order.deliveryLng : null);
    final Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(order.deliveryAddress)}');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callDriver(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^0-9+]'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _followIfMoved(OrderTracking? tracking, List<LatLng> points) {
    final t = tracking;
    if (t == null || !t.hasDriverLocation) return;
    final driverPos = LatLng(t.driverLat!, t.driverLng!);
    if (_lastDriverPos == driverPos) return;
    _lastDriverPos = driverPos;
    if (!mounted || _mapController == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _mapController == null) return;
      _mapController!.fitCamera(
        CameraFit.bounds(bounds: LatLngBounds.fromPoints(points), padding: const EdgeInsets.all(48)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final tracking = context.watch<OrderProvider>().tracking;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.liveTracking, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        color: AppTheme.orange500,
        onRefresh: () => Provider.of<OrderProvider>(context, listen: false).fetchTracking(widget.order.id),
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          children: [
            _buildStatusCard(loc, tracking),
            const SizedBox(height: AppTheme.spaceMd),
            _buildMap(loc, tracking),
            const SizedBox(height: AppTheme.spaceMd),
            if (tracking != null && tracking.driverName != null) ...[
              _buildDriverCard(loc, tracking),
              const SizedBox(height: AppTheme.spaceMd),
            ],
            _buildOrderCard(loc, tracking),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations loc, OrderTracking? tracking) {
    final status = TaminiBadge.fromString(widget.order.status);
    final message = tracking != null && tracking.hasDriverLocation
        ? loc.driverOnTheWay
        : loc.waitingForDriver;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.roundedLg,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${loc.yourOrder} #${widget.order.customerOrderNumber ?? widget.order.id}',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                ),
              ),
              TaminiBadge(text: loc.statusText(widget.order.status), status: status, showDot: false),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap(AppLocalizations loc, OrderTracking? tracking) {
    final points = <LatLng>[];
    final t = tracking;
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
    if (points.isEmpty && widget.order.deliveryLat != 0 && widget.order.deliveryLng != 0) {
      points.add(LatLng(widget.order.deliveryLat, widget.order.deliveryLng));
    }

    if (points.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppTheme.gray50,
          borderRadius: AppTheme.roundedLg,
          border: Border.all(color: AppTheme.borderLight),
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
                style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.gray500, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openInMaps(tracking),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(loc.openInMaps, style: const TextStyle(fontFamily: 'Cairo')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.orange600,
                side: const BorderSide(color: AppTheme.orange400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
              ),
            ),
          ],
        ),
      );
    }

    final restaurantPos = t != null && t.restaurantLat != null && t.restaurantLng != null
        ? LatLng(t.restaurantLat!, t.restaurantLng!)
        : null;
    final deliveryPos = t != null && t.deliveryLat != null && t.deliveryLng != null
        ? LatLng(t.deliveryLat!, t.deliveryLng!)
        : null;

    _followIfMoved(tracking, points);

    return ClipRRect(
      borderRadius: AppTheme.roundedLg,
      child: SizedBox(
        height: 280,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: points.first,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tamini.app',
            ),
            MarkerLayer(markers: _buildMarkers(tracking)),
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

  List<Marker> _buildMarkers(OrderTracking? tracking) {
    final markers = <Marker>[];

    void add(LatLng p, IconData icon, Color color) {
      markers.add(
        Marker(
          point: p,
          width: 34,
          height: 34,
          child: Container(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      );
    }

    final t = tracking;
    if (t != null) {
      if (t.restaurantLat != null && t.restaurantLng != null) {
        add(LatLng(t.restaurantLat!, t.restaurantLng!), Icons.store_outlined, AppTheme.info);
      }
      if (t.hasDriverLocation) {
        add(LatLng(t.driverLat!, t.driverLng!), Icons.delivery_dining_outlined, AppTheme.orange500);
      }
      if (t.deliveryLat != null && t.deliveryLng != null) {
        add(LatLng(t.deliveryLat!, t.deliveryLng!), Icons.home_outlined, AppTheme.success);
      }
    }
    return markers;
  }

  Widget _buildDriverCard(AppLocalizations loc, OrderTracking tracking) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.orange50,
            child: const Icon(Icons.person_outline, color: AppTheme.orange600, size: 24),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.driverInfo,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.gray400),
                ),
                const SizedBox(height: 2),
                Text(
                  tracking.driverName ?? '',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          if (tracking.driverPhone != null && tracking.driverPhone!.isNotEmpty)
            IconButton(
              onPressed: () => _callDriver(tracking.driverPhone!),
              style: IconButton.styleFrom(backgroundColor: AppTheme.successBg),
              icon: const Icon(Icons.call, color: AppTheme.success, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(AppLocalizations loc, OrderTracking? tracking) {
    final order = widget.order;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.orderDetails,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          _detailRow(Icons.store_outlined, loc.restaurant, order.restaurantName),
          const SizedBox(height: 8),
          _detailRow(Icons.location_on_outlined, loc.deliveryAddress, order.deliveryAddress),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _openInMaps(tracking),
            icon: const Icon(Icons.directions_outlined, size: 18),
            label: Text(loc.openInMaps, style: const TextStyle(fontFamily: 'Cairo')),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              foregroundColor: AppTheme.orange600,
              side: const BorderSide(color: AppTheme.orange400),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.gray400),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.gray400),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}
