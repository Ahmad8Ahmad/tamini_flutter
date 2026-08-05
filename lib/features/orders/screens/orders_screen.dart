import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/tamini_badge.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/dashboard_button.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int? _loadedForUserId;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);

    final userId = auth.user?.id;
    if (userId != null && _loadedForUserId != userId) {
      _loadedForUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<OrderProvider>().loadOrders();
      });
    }
    if (userId == null) _loadedForUserId = null;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myOrders, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
        actions: const [DashboardButton()],
      ),
      body: orders.loading && orders.orders.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orange500))
          : orders.orders.isEmpty
              ? TaminiEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: loc.noOrdersYet,
                  subtitle: loc.isArabic ? 'ستظهر طلباتك هنا' : 'Your orders will appear here',
                )
              : RefreshIndicator(
                  color: AppTheme.orange500,
                  onRefresh: () => orders.loadOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
                    itemCount: orders.orders.length,
                    itemBuilder: (ctx, i) => _buildOrderCard(orders.orders[i]),
                  ),
                ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final loc = AppLocalizations.of(context);
    final status = TaminiBadge.fromString(order.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${loc.orderNumber}${order.customerOrderNumber ?? order.id}',
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textPrimary),
              ),
              TaminiBadge(text: loc.statusText(order.status), status: status),
            ],
          ),
          const SizedBox(height: 10),
          // Restaurant + items count
          Row(
            children: [
              const Icon(Icons.store_outlined, size: 16, color: AppTheme.orange400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.restaurantName,
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.gray100,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${order.items.length} ${loc.items}',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.gray500),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppTheme.borderLight),
          ),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppTheme.gray400),
                  const SizedBox(width: 4),
                  Text(
                    loc.formatDate(order.createdAt),
                    style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.gray400, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                '${order.totalPrice.toStringAsFixed(0)} SYP',
                style: AppTheme.priceMedium.copyWith(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
