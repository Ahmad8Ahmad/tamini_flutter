import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/order_socket.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_badge.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/tamini_shimmer.dart';
import '../../../core/widgets/language_selector.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key, this.kitchenModeDefault = false});

  /// Start in kitchen mode (no prices, big buttons). Used for staff accounts.
  final bool kitchenModeDefault;

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  static const _statusFilters = [
    'Pending',
    'Confirmed',
    'Preparing',
    'Out for Delivery',
    'Completed',
    'Cancelled',
  ];

  String? _statusFilter;
  Timer? _pollTimer;
  OrderSocketService? _socket;
  bool _live = false;
  late bool _kitchenMode = widget.kitchenModeDefault;
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(initial: true);
      _initSocket();
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _socket?.close();
    super.dispose();
  }

  void _initSocket() {
    final auth = context.read<AuthProvider>();
    _socket = OrderSocketService(getToken: () => auth.accessToken);
    _socket!.onOrderEvent = (_) {
      if (!mounted) return;
      _load();
    };
    _socket!.onConnectionChanged = (connected) {
      if (!mounted) return;
      setState(() => _live = connected);
    };
    _socket!.connect();
  }

  Future<void> _load({bool initial = false}) async {
    final provider = context.read<OrderProvider>();
    final before = provider.restaurantOrders.map((o) => o.id).toSet();
    await provider.loadRestaurantOrders();
    if (!mounted || initial) return;
    final after = provider.restaurantOrders.map((o) => o.id).toSet();
    if (after.difference(before).isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).newOrderReceived),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateStatus(Order order, String status) async {
    final loc = AppLocalizations.of(context);
    final provider = context.read<OrderProvider>();
    final ok = await provider.updateOrderStatus(order.id, status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.savedSuccessfully : loc.errorOccurred),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final loc = AppLocalizations.of(context);
    final filtered = _statusFilter == null
        ? provider.restaurantOrders
        : provider.restaurantOrders
              .where((o) => o.status == _statusFilter)
              .toList();
    final shown = _kitchenMode ? _sortedForKitchen(filtered) : filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.orders),
        actions: [
          _buildLiveIndicator(loc),
          IconButton(
            onPressed: () => setState(() => _kitchenMode = !_kitchenMode),
            icon: Icon(
              _kitchenMode
                  ? Icons.restaurant_menu
                  : Icons.restaurant_menu_outlined,
              color: _kitchenMode ? AppTheme.orange600 : null,
            ),
            tooltip: loc.kitchenMode,
          ),
          const LanguageSelector(),
        ],
      ),
      body: Column(
        children: [
          if (_kitchenMode) _buildKitchenBanner(loc),
          _buildFilterChips(loc),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.orange500,
              child: _buildBody(provider, shown, loc),
            ),
          ),
        ],
      ),
    );
  }

  List<Order> _sortedForKitchen(List<Order> orders) {
    const rank = {
      'Pending': 0,
      'Confirmed': 1,
      'Preparing': 2,
      'In Progress': 2,
      'Out for Delivery': 3,
      'Completed': 4,
      'Cancelled': 5,
    };
    final list = List<Order>.from(orders);
    list.sort((a, b) => (rank[a.status] ?? 6).compareTo(rank[b.status] ?? 6));
    return list;
  }

  Widget _buildKitchenBanner(AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: 8,
      ),
      color: AppTheme.orange50,
      child: Row(
        children: [
          const Icon(
            Icons.restaurant_menu,
            size: 16,
            color: AppTheme.orange600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              loc.kitchenModeHint,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.orange600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _live ? AppTheme.success : AppTheme.gray400,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _live ? loc.live : loc.reconnecting,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _live ? AppTheme.success : AppTheme.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations loc) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ChoiceChip(
              label: const Text(
                'All',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              selected: _statusFilter == null,
              onSelected: (_) => setState(() => _statusFilter = null),
              selectedColor: AppTheme.orange50,
              labelStyle: TextStyle(
                color: _statusFilter == null
                    ? AppTheme.orange600
                    : AppTheme.textSecondary,
              ),
              side: BorderSide(
                color: _statusFilter == null
                    ? AppTheme.orange400
                    : AppTheme.borderLight,
              ),
            ),
          ),
          for (final status in _statusFilters)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ChoiceChip(
                label: Text(
                  loc.statusText(status),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                selected: _statusFilter == status,
                onSelected: (_) => setState(
                  () => _statusFilter = _statusFilter == status ? null : status,
                ),
                selectedColor: AppTheme.orange50,
                labelStyle: TextStyle(
                  color: _statusFilter == status
                      ? AppTheme.orange600
                      : AppTheme.textSecondary,
                ),
                side: BorderSide(
                  color: _statusFilter == status
                      ? AppTheme.orange400
                      : AppTheme.borderLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    OrderProvider provider,
    List<Order> orders,
    AppLocalizations loc,
  ) {
    if (provider.restaurantLoading && provider.restaurantOrders.isEmpty) {
      return TaminiShimmer.list(count: 5);
    }
    if (orders.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: TaminiEmptyState(
              icon: Icons.receipt_long_outlined,
              title: loc.noOrdersYet,
              subtitle: loc.ordersWillAppearHere,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => _buildOrderCard(orders[i], loc),
    );
  }

  Widget _buildOrderCard(Order order, AppLocalizations loc) {
    final expanded = _expanded.contains(order.id);
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(
          color: order.status == 'Pending'
              ? AppTheme.orange200
              : AppTheme.borderLight,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLg),
            ),
            onTap: () => setState(() {
              if (expanded) {
                _expanded.remove(order.id);
              } else {
                _expanded.add(order.id);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${order.customerOrderNumber ?? order.id}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _kitchenMode
                                  ? '${loc.orderNumber}${order.customerOrderNumber ?? order.id}'
                                  : order.customerName,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              order.restaurantName,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TaminiBadge(
                        text: loc.statusText(order.status),
                        status: TaminiBadge.fromString(order.status),
                        compact: true,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppTheme.gray400,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order.items
                        .map((it) => '${it.menuItemName} ×${it.quantity}')
                        .join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (!_kitchenMode) ...[
                        Text(
                          '${_price(order.totalPrice)} SYP',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.orange600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (order.paymentMethod != null)
                          _paymentChip(order.paymentMethod!),
                      ],
                      const Spacer(),
                      Text(
                        loc.formatDate(order.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppTheme.gray400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded) _buildDetails(order, loc),
          _buildActions(order, loc),
        ],
      ),
    );
  }

  Widget _paymentChip(String method) {
    final isCash = method.toLowerCase().contains('cash');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCash ? AppTheme.successBg : AppTheme.infoBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCash ? Icons.payments_outlined : Icons.credit_card_outlined,
            size: 12,
            color: isCash ? AppTheme.success : AppTheme.info,
          ),
          const SizedBox(width: 4),
          Text(
            method,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isCash ? AppTheme.success : AppTheme.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(Order order, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceSm,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.gray50,
        border: Border(top: BorderSide(color: AppTheme.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_kitchenMode) ...[
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppTheme.orange500,
                ),
                const SizedBox(width: 6),
                Text(
                  loc.customerLabel,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (order.customerPhone.isNotEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 13,
                    color: AppTheme.gray400,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.customerPhone,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            if (order.deliveryAddress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppTheme.gray400,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
          ],
          Text(
            loc.orderDetails,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.menuItemName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '×${item.quantity}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (!_kitchenMode) ...[
                    const SizedBox(width: 10),
                    Text(
                      '${_price(item.price * item.quantity)} SYP',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (!_kitchenMode && order.deliveryFee > 0)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.deliveryFee,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '${_price(order.deliveryFee)} SYP',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          if (!_kitchenMode) ...[
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    loc.total,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${_price(order.totalPrice)} SYP',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.orange600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(Order order, AppLocalizations loc) {
    final actions = <Widget>[];
    if (order.status == 'Pending') {
      actions.addAll([
        _actionButton(
          loc.confirmOrder,
          Icons.check,
          AppTheme.success,
          () => _updateStatus(order, 'Confirmed'),
        ),
        _actionButton(
          loc.cancelOrder,
          Icons.close,
          AppTheme.danger,
          () => _updateStatus(order, 'Cancelled'),
        ),
      ]);
    } else if (order.status == 'Confirmed') {
      actions.addAll([
        _actionButton(
          loc.startPreparing,
          Icons.restaurant,
          AppTheme.orange500,
          () => _updateStatus(order, 'Preparing'),
        ),
        _actionButton(
          loc.cancelOrder,
          Icons.close,
          AppTheme.danger,
          () => _updateStatus(order, 'Cancelled'),
        ),
      ]);
    } else if (order.status == 'Preparing' || order.status == 'In Progress') {
      actions.add(
        _actionButton(
          loc.outForDeliveryAction,
          Icons.delivery_dining_outlined,
          AppTheme.info,
          () => _updateStatus(order, 'Out for Delivery'),
        ),
      );
    } else if (order.status == 'Out for Delivery') {
      actions.add(
        _actionButton(
          loc.markCompleted,
          Icons.task_alt,
          AppTheme.success,
          () => _updateStatus(order, 'Completed'),
        ),
      );
    }
    if (actions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        0,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
      ),
      child: Wrap(spacing: AppTheme.spaceSm, children: actions),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final kitchen = _kitchenMode;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: kitchen ? 18 : 15, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: kitchen ? 14 : 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedMd),
        padding: EdgeInsets.symmetric(
          horizontal: kitchen ? 18 : 12,
          vertical: kitchen ? 12 : 8,
        ),
      ),
    );
  }

  String _price(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
}
