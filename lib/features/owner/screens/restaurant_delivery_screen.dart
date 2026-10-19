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

class _RestaurantDeliveryScreenState extends State<RestaurantDeliveryScreen>
    with WidgetsBindingObserver {
  /// How often the selected order's driver position is refreshed.
  ///
  /// 10s matches the customer tracking screen. The owner view does not need
  /// sub-second positions and this halves the poll load when several owner
  /// screens are open at once.
  static const _pollInterval = Duration(seconds: 10);
  static const _activeStatuses = {
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
  Order? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The driver-position poll is only useful while someone is looking at
    // the screen; a backgrounded phone should not keep the backend busy.
    if (state == AppLifecycleState.resumed) {
      if (_selected != null) _startTracking(_selected!.id);
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
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
      final p = context.read<OrderProvider>();
      if (_terminalStatuses.contains(p.tracking?.status)) {
        // The order is done; stop polling until the list is refreshed or
        // another order is selected.
        _pollTimer?.cancel();
        _pollTimer = null;
        return;
      }
      p.fetchTracking(orderId);
    });
  }

  void _selectOrder(Order order) {
    if (_selected?.id == order.id) return;
    setState(() => _selected = order);
    _startTracking(order.id);
  }

  Future<void> _openInMaps(OrderTracking? tracking) {
    final order = _selected;
    if (order == null) return Future.value();
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.tint,
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
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
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
                    selectedColor: context.colors.tint,
                    labelStyle: TextStyle(
                      color: _selected?.id == order.id
                          ? AppTheme.orange600
                          : context.colors.textSecondary,
                    ),
                    side: BorderSide(
                      color: _selected?.id == order.id
                          ? AppTheme.orange400
                          : context.colors.borderLight,
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
    final order = _selected;
    final status = order != null
        ? TaminiBadge.fromString(order.status)
        : BadgeStatus.info;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.card,
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
          TrackingMapCard(
            tracking: tracking,
            fallbackPoint:
                order != null && order.deliveryLat != 0 && order.deliveryLng != 0
                ? LatLng(order.deliveryLat, order.deliveryLng)
                : null,
            height: 260,
            placeholderHeight: 240,
            onOpenInMaps: () => _openInMaps(tracking),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(AppLocalizations loc, OrderTracking? tracking) {
    if (tracking == null) return const SizedBox.shrink();
    final hasDriver =
        tracking.driverName != null && tracking.driverName!.isNotEmpty;
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
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDriver ? tracking.driverName! : loc.waitingForDriver,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (tracking.driverPhone != null && tracking.driverPhone!.isNotEmpty)
            IconButton(
              onPressed: () => dialNumber(tracking.driverPhone!),
              style: IconButton.styleFrom(
                backgroundColor: context.colors.successBg,
              ),
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
        color: context.colors.card,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: context.colors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.orderDetails,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
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
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
