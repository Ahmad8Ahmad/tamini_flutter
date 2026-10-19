import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/sales_analytics.dart';

class SalesKpiGrid extends StatelessWidget {
  const SalesKpiGrid({super.key, required this.loc, required this.orders});

  final AppLocalizations loc;
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    var todayCount = 0;
    var todayRevenue = 0.0;
    var weekCount = 0;
    var weekRevenue = 0.0;
    var revenue = 0.0;
    for (final o in orders) {
      if (SalesAnalytics.isCancelled(o)) continue;
      revenue += o.totalPrice;
      final d = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
      if (d == today) {
        todayCount++;
        todayRevenue += o.totalPrice;
      }
      if (o.createdAt.isAfter(weekAgo)) {
        weekCount++;
        weekRevenue += o.totalPrice;
      }
    }
    final active = orders.where((o) => !SalesAnalytics.isCancelled(o)).length;
    final avg = active == 0 ? 0.0 : revenue / active;

    return Column(
      children: [
        Row(
          children: [
            _KpiCard(
              label: loc.todayOrders,
              value: '$todayCount',
              icon: Icons.receipt_long_outlined,
              color: AppTheme.orange500,
            ),
            const SizedBox(width: AppTheme.spaceMd),
            _KpiCard(
              label: loc.todayRevenue,
              value: formatPrice(todayRevenue),
              icon: Icons.payments_outlined,
              color: AppTheme.success,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            _KpiCard(
              label: 'This week',
              value: '$weekCount',
              icon: Icons.date_range_outlined,
              color: AppTheme.info,
            ),
            const SizedBox(width: AppTheme.spaceMd),
            _KpiCard(
              label: 'Week revenue',
              value: formatPrice(weekRevenue),
              icon: Icons.account_balance_wallet_outlined,
              color: AppTheme.warning,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            _KpiCard(
              label: loc.totalOrders,
              value: '${orders.length}',
              icon: Icons.list_alt_outlined,
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            _KpiCard(
              label: loc.avgOrderValue,
              value: formatPrice(avg),
              icon: Icons.stacked_line_chart_outlined,
              color: const Color(0xFFEC4899),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: AppTheme.roundedLg,
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(label, style: AppTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
