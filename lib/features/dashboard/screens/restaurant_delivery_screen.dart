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
import '../../../core/widgets/language_selector.dart';
import '../../../core/widgets/tamini_badge.dart';

class RestaurantDeliveryScreen extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;

  const RestaurantDeliveryScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<RestaurantDeliveryScreen> createState() =>
      _RestaurantDeliveryScreenState();
}

class _RestaurantDeliveryScreenState extends State<RestaurantDeliveryScreen> {
  static const _pollInterval = Duration(seconds: 5);
  static const _activeStatuses = {
    'Confirmed',
    'Preparing',
    'In Progress',
    'Out for Delivery',
  };

  Timer? _pollTimer;
  MapController? _mapController;
  Order? _selected;
  LatLng? _lastDriverPos;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  List<Order> _inTransitOrders(List<Order> orders) => orders
      .where((o) => o.restaurant == widget.restaurantId)
      .where((o) => _activeStatuses.contains(o.status))
      .toList();

  Future<void> _load() async {
    final provider = context.read<OrderProvider>();
    await provider.loadRestaurantOrders();
    if (!mounted) return;
    final inTransit = _inTransitOrders(provider.restaurantOrders);
    if (_selected == null || !inTransit.any((o) => o.id == _selected!.id)) {
      setState(() => _selected = inTransit.isNotEmpty ? inTransit.first : null);
    }
    if (_selected != null) _startTracking(_selected!.id);
  }

  void _startTracking(int orderId) {
    final provider = context.read<OrderProvider>();
    provider.fetchTracking(orderId);
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!mounted) return;
      context.read<OrderProvider>().fetchTracking(orderId);
    });
  }

  void _selectOrder(Order order) {
    if (_selected?.id == order.id) return;
    setState(() => _selected = order);
    _lastDriverPos = null;
    _startTracking(order.id);
  }

  Future<void> _callDriver(String phone) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(RegExp(r'[^0-9+]'), ''),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openInMaps(OrderTracking? tracking) async {
    final order = _selected;
    if (order == null) return;
    final lat =
        tracking?.deliveryLat ??
        (order.deliveryLat != 0 ? order.deliveryLat : null);
    final lng =
        tracking?.deliveryLng ??
        (order.deliveryLng != 0 ? order.deliveryLng : null);
    final Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(order.deliveryAddress)}',
      );
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<OrderProvider>();
    final inTransit = _inTransitOrders(provider.restaurantOrders);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.liveDelivery,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [LanguageSelector()],
      ),
      body: RefreshIndicator(
        color: AppTheme.orange500,
        onRefresh: _load,
        child: inTransit.isEmpty
            ? _buildEmpty(loc)
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                children: [
                  _buildOrderSelector(inTransit, loc),
                  const SizedBox(height: AppTheme.spaceMd),
                  if (_selected != null) ...[
                    _buildTrackingCard(loc, provider.tracking),
                    const SizedBox(height: AppTheme.spaceMd),
                    _buildDriverCard(loc, provider.tracking),
                    const SizedBox(height: AppTheme.spaceMd),
                    _buildOrderCard(loc, provider.tracking),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations loc) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.orange50,
                    ),
                    child: const Icon(
                      Icons.delivery_dining_outlined,
                      size: 46,
                      color: AppTheme.orange300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.noDeliveriesYet,
                    textAlign: TextAlign.center,
                    style: AppTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.noDeliveriesHint,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSelector(List<Order> orders, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.selectOrder,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final order in orders)
                Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spaceSm),
                  child: ChoiceChip(
                    label: Text(
                      '${loc.orderNumber}${order.customerOrderNumber ?? order.id}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    selected: _selected?.id == order.id,
                    onSelected: (_) => _selectOrder(order),
                    selectedColor: AppTheme.orange50,
                    labelStyle: TextStyle(
                      color: _selected?.id == order.id
                          ? AppTheme.orange600
                          : AppTheme.textSecondary,
                    ),
                    side: BorderSide(
                      color: _selected?.id == order.id
                          ? AppTheme.orange400
                          : AppTheme.borderLight,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingCard(AppLocalizations loc, OrderTracking? tracking) {
    final points = <LatLng>[];
    final t = tracking;
    final order = _selected;
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
    if (points.isEmpty &&
        order != null &&
        order.deliveryLat != 0 &&
        order.deliveryLng != 0) {
      points.add(LatLng(order.deliveryLat, order.deliveryLng));
    }

    final status = order != null
        ? TaminiBadge.fromString(order.status)
        : BadgeStatus.info;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  order?.restaurantName ?? widget.restaurantName,
                  style: AppTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (order != null)
                TaminiBadge(
                  text: loc.statusText(order.status),
                  status: status,
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          if (points.isEmpty)
            _mapPlaceholder(loc, tracking)
          else
            _buildMap(points, tracking),
        ],
      ),
    );
  }

  Widget _mapPlaceholder(AppLocalizations loc, OrderTracking? tracking) {
    return Container(
      height: 240,
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
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppTheme.gray500,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _openInMaps(tracking),
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

  Widget _buildMap(List<LatLng> points, OrderTracking? tracking) {
    final t = tracking;
    final restaurantPos =
        t != null && t.restaurantLat != null && t.restaurantLng != null
        ? LatLng(t.restaurantLat!, t.restaurantLng!)
        : null;
    final deliveryPos =
        t != null && t.deliveryLat != null && t.deliveryLng != null
        ? LatLng(t.deliveryLat!, t.deliveryLng!)
        : null;

    _followIfMoved(tracking, points);

    return ClipRRect(
      borderRadius: AppTheme.roundedLg,
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: points.first,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
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
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(48),
        ),
      );
    });
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      );
    }

    final t = tracking;
    if (t != null) {
      if (t.restaurantLat != null && t.restaurantLng != null) {
        add(
          LatLng(t.restaurantLat!, t.restaurantLng!),
          Icons.store_outlined,
          AppTheme.info,
        );
      }
      if (t.hasDriverLocation) {
        add(
          LatLng(t.driverLat!, t.driverLng!),
          Icons.delivery_dining_outlined,
          AppTheme.orange500,
        );
      }
      if (t.deliveryLat != null && t.deliveryLng != null) {
        add(
          LatLng(t.deliveryLat!, t.deliveryLng!),
          Icons.home_outlined,
          AppTheme.success,
        );
      }
    }
    return markers;
  }

  Widget _buildDriverCard(AppLocalizations loc, OrderTracking? tracking) {
    if (tracking == null) return const SizedBox.shrink();
    final hasDriver =
        tracking.driverName != null && tracking.driverName!.isNotEmpty;
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
            child: const Icon(
              Icons.person_outline,
              color: AppTheme.orange600,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.driverInfo,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDriver ? tracking.driverName! : loc.waitingForDriver,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
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
    final order = _selected;
    if (order == null) return const SizedBox.shrink();
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
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          _detailRow(
            Icons.person_outline,
            loc.customerLabel,
            order.customerName,
          ),
          if (order.customerPhone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _detailRow(Icons.phone_outlined, loc.phone, order.customerPhone),
          ],
          const SizedBox(height: 8),
          _detailRow(
            Icons.location_on_outlined,
            loc.deliveryAddress,
            order.deliveryAddress,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _openInMaps(tracking),
            icon: const Icon(Icons.directions_outlined, size: 18),
            label: Text(
              loc.openInMaps,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.gray400),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
