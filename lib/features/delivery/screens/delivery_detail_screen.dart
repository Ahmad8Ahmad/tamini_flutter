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

class DeliveryDetailScreen extends StatefulWidget {
  final Delivery delivery;

  const DeliveryDetailScreen({super.key, required this.delivery});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  int? _completingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<DeliveryProvider>()
          .fetchOrderDetail(widget.delivery.orderId);
    });
  }

  @override
  void dispose() {
    context.read<DeliveryProvider>().clearOrderDetail();
    super.dispose();
  }

  Future<void> _complete(AppLocalizations loc) async {
    final d = widget.delivery;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.completeDelivery),
        content: Text(loc.completeDeliveryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              loc.confirm,
              style: const TextStyle(
                color: AppTheme.success,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _completingId = d.id);
    final ok = await context.read<DeliveryProvider>().completeDelivery(d.id);
    if (!mounted) return;
    setState(() => _completingId = null);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.errorOccurred),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Future<void> _callCustomer(String phone) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(RegExp(r'[^0-9+]'), ''),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openInMaps() async {
    final d = widget.delivery;
    final addr = d.deliveryAddress;
    final Uri uri = addr != null && addr.isNotEmpty
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addr)}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(d.restaurantName)}',
          );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final d = widget.delivery;
    final p = context.watch<DeliveryProvider>();
    final order = p.activeOrderDetail;
    final isActive = d.isActive;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${loc.orderNumber}${d.orderId}',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [LanguageSelector()],
      ),
      body: RefreshIndicator(
        color: AppTheme.orange500,
        onRefresh: () => p.fetchOrderDetail(d.orderId),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          children: [
            _buildStatusBanner(d, loc),
            const SizedBox(height: AppTheme.spaceMd),
            _buildRouteCard(d, loc),
            const SizedBox(height: AppTheme.spaceMd),
            if (d.restaurantLat != null &&
                d.restaurantLng != null &&
                d.deliveryLat != null &&
                d.deliveryLng != null) ...[
              _buildMapCard(d),
              const SizedBox(height: AppTheme.spaceMd),
            ],
            _buildCustomerCard(d, loc),
            if (order != null && order.items.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceMd),
              _buildOrderItemsCard(order, loc),
            ],
            if (p.loadingDetail)
              const Padding(
                padding: EdgeInsets.all(AppTheme.spaceMd),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.orange500),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: isActive
          ? _buildBottomBar(d, loc)
          : null,
    );
  }

  Widget _buildStatusBanner(Delivery d, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.deliveryStatusText(d.status),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  d.restaurantName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              '${_formatPrice(d.calculatedFee ?? 0)} SYP',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(Delivery d, AppLocalizations loc) {
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
          _routeRow(
            icon: Icons.store_outlined,
            color: AppTheme.info,
            label: loc.pickup,
            value: d.restaurantName,
          ),
          if (d.restaurantAddress != null) ...[
            const SizedBox(height: 8),
            _routeRow(
              icon: Icons.location_on_outlined,
              color: AppTheme.gray400,
              label: loc.fromLabel,
              value: d.restaurantAddress!,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _routeRow(
            icon: Icons.location_on_outlined,
            color: AppTheme.orange600,
            label: loc.toLabel,
            value: d.deliveryAddress ?? '\u2014',
          ),
          if (d.distance != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  size: 16,
                  color: AppTheme.gray400,
                ),
                const SizedBox(width: 6),
                Text(
                  '${d.distance!.toStringAsFixed(1)} ${loc.km}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.info,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapCard(Delivery d) {
    final restaurantPos = LatLng(d.restaurantLat!, d.restaurantLng!);
    final deliveryPos = LatLng(d.deliveryLat!, d.deliveryLng!);
    final points = [restaurantPos, deliveryPos];
    return ClipRRect(
      borderRadius: AppTheme.roundedLg,
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: restaurantPos,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tamini.app',
            ),
            MarkerLayer(markers: [
              Marker(
                point: restaurantPos,
                width: 34,
                height: 34,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.info,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.store_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              Marker(
                point: deliveryPos,
                width: 34,
                height: 34,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.orange500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
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

  Widget _buildCustomerCard(Delivery d, AppLocalizations loc) {
    final customer = d.customerName;
    final phone = d.customerPhone;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        boxShadow: AppTheme.shadowSm,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer?.isNotEmpty == true ? customer! : '\u2014',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (phone != null && phone.isNotEmpty)
                  Text(
                    phone,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (phone != null && phone.isNotEmpty)
            IconButton(
              onPressed: () => _callCustomer(phone),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.successBg,
              ),
              icon: const Icon(Icons.call, color: AppTheme.success, size: 20),
            ),
          IconButton(
            onPressed: _openInMaps,
            style: IconButton.styleFrom(backgroundColor: AppTheme.orange50),
            icon: const Icon(
              Icons.map_outlined,
              color: AppTheme.orange600,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(Order order, AppLocalizations loc) {
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
              const Icon(
                Icons.receipt_long_outlined,
                size: 16,
                color: AppTheme.orange500,
              ),
              const SizedBox(width: 6),
              Text(
                loc.orderSummary,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${order.items.length} ${loc.items}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppTheme.gray400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          for (var i = 0; i < order.items.length; i++) ...[
            _itemRow(order.items[i]),
            if (i != order.items.length - 1) const Divider(height: 16),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.total,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${_formatPrice(order.totalPrice.toInt())} SYP',
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
      ),
    );
  }

  Widget _itemRow(OrderItem item) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppTheme.orange50,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${item.quantity}x',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.orange600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.menuItemName,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${_formatPrice((item.price * item.quantity).toInt())} SYP',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Delivery d, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
          onPressed: _completingId == d.id ? null : () => _complete(loc),
          child: _completingId == d.id
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  loc.completeDelivery,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _routeRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: AppTheme.labelSmall,
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatPrice(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
