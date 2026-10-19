import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/maps_launcher.dart';
import '../../../core/widgets/route_map.dart';
import '../../../core/widgets/tamini_badge.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with WidgetsBindingObserver {
  /// While a driver is moving the position changes constantly, so refresh
  /// every 10s; while the order is still with the kitchen only the status can
  /// change, so a 30s window is enough. One fast ticker runs and skips the
  /// network call until the active window has elapsed.
  static const _fastInterval = Duration(seconds: 10);
  static const _slowInterval = Duration(seconds: 30);
  static const _activeStatuses = {
    'Pending',
    'Confirmed',
    'Preparing',
    'In Progress',
    'Out for Delivery',
  };
  static const _terminalStatuses = {
    'Delivered',
    'Completed',
    'Cancelled',
    'Canceled',
  };

  Timer? _pollTimer;
  DateTime _lastFetch = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop the tracking poll while the app is backgrounded; a locked phone
    // polling every 10s keeps the backend awake and burns battery for no
    // visible updates. Resume (and fetch immediately) when the user comes
    // back.
    if (state == AppLifecycleState.resumed) {
      _startPolling();
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _fetchTracking();
    _pollTimer = Timer.periodic(_fastInterval, (_) {
      if (!mounted) return;
      final p = Provider.of<OrderProvider>(context, listen: false);
      final status = p.tracking?.status ?? widget.order.status;
      if (_terminalStatuses.contains(status)) {
        // Nothing more to track: the timer stops instead of ticking until
        // dispose. Pull-to-refresh still works for a last look.
        _pollTimer?.cancel();
        _pollTimer = null;
        return;
      }
      if (!_activeStatuses.contains(status)) return;
      final moving =
          status == 'Out for Delivery' || (p.tracking?.hasDriverLocation ?? false);
      final interval = moving ? _fastInterval : _slowInterval;
      if (DateTime.now().difference(_lastFetch) < interval) return;
      _fetchTracking();
    });
  }

  void _fetchTracking() {
    _lastFetch = DateTime.now();
    Provider.of<OrderProvider>(context, listen: false)
        .fetchTracking(widget.order.id);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _openInMaps(OrderTracking? tracking) {
    final order = widget.order;
    return openInGoogleMaps(
      lat: tracking?.deliveryLat ??
          (order.deliveryLat != 0 ? order.deliveryLat : null),
      lng: tracking?.deliveryLng ??
          (order.deliveryLng != 0 ? order.deliveryLng : null),
      query: order.deliveryAddress,
    );
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
            TrackingMapCard(
              tracking: tracking,
              fallbackPoint:
                  widget.order.deliveryLat != 0 && widget.order.deliveryLng != 0
                  ? LatLng(widget.order.deliveryLat, widget.order.deliveryLng)
                  : null,
              height: 280,
              placeholderHeight: 220,
              onOpenInMaps: () => _openInMaps(tracking),
            ),
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

  Widget _buildDriverCard(AppLocalizations loc, OrderTracking tracking) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: context.colors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: context.colors.tint,
            child: const Icon(Icons.person_outline, color: AppTheme.orange600, size: 24),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.driverInfo,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  tracking.driverName ?? '',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
                ),
              ],
            ),
          ),
          if (tracking.driverPhone != null && tracking.driverPhone!.isNotEmpty)
            IconButton(
              onPressed: () => dialNumber(tracking.driverPhone!),
              style: IconButton.styleFrom(backgroundColor: context.colors.successBg),
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
        color: context.colors.card,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: context.colors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.orderDetails,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
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
        Icon(icon, size: 16, color: context.colors.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
          ),
        ),
      ],
    );
  }
}
