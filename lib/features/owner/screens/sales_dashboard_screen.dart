import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/sales_analytics.dart';
import '../widgets/sales_kpi_grid.dart';
import '../widgets/sales_peak_hours_card.dart';
import '../widgets/sales_period_toggle.dart';
import '../widgets/sales_status_card.dart';
import '../widgets/sales_top_items_card.dart';
import '../widgets/sales_trend_card.dart';
import '../widgets/sales_weekly_card.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  int _periodDays = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadRestaurantOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final orders = context.watch<OrderProvider>().restaurantOrders;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.salesDashboard,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.orange500,
        onRefresh: () => context.read<OrderProvider>().loadRestaurantOrders(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          children: [
            if (orders.isEmpty)
              _SalesEmptyState(loc: loc)
            else ...[
              SalesKpiGrid(loc: loc, orders: orders),
              const SizedBox(height: AppTheme.spaceMd),
              SalesPeriodToggle(
                periodDays: _periodDays,
                onChanged: (days) => setState(() => _periodDays = days),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              SalesTrendCard(
                loc: loc,
                days: SalesAnalytics.dailyData(
                  SalesAnalytics.activeOrders(orders),
                  _periodDays,
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              SalesWeeklyCard(
                loc: loc,
                weeks: SalesAnalytics.weeklyData(
                  SalesAnalytics.activeOrders(orders),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              SalesPeakHoursCard(
                loc: loc,
                hours: SalesAnalytics.peakHours(
                  SalesAnalytics.activeOrders(orders),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              SalesStatusCard(
                loc: loc,
                counts: SalesAnalytics.statusCounts(orders),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              SalesTopItemsCard(
                loc: loc,
                items: SalesAnalytics.topItems(
                  SalesAnalytics.activeOrders(orders),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SalesEmptyState extends StatelessWidget {
  const _SalesEmptyState({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceXxl),
      child: Column(
        children: [
          const Icon(
            Icons.insights_outlined,
            size: 64,
            color: AppTheme.gray300,
          ),
          const SizedBox(height: 16),
          Text(
            loc.noDataYet,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
