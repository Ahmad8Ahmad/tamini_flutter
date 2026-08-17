import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/language_selector.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  static const Set<String> _cancelled = {'Cancelled', 'Canceled'};

  int _periodDays = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadRestaurantOrders();
    });
  }

  bool _isCancelled(Order o) => _cancelled.contains(o.status);

  List<Order> _activeOrders(List<Order> orders) =>
      orders.where((o) => !_isCancelled(o)).toList();

  List<({DateTime day, double revenue, int orders})> _dailyData(
    List<Order> orders,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <({DateTime day, double revenue, int orders})>[];
    for (int i = _periodDays - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      double rev = 0;
      int count = 0;
      for (final o in orders) {
        final d = DateTime(
          o.createdAt.year,
          o.createdAt.month,
          o.createdAt.day,
        );
        if (d == day) {
          rev += o.totalPrice;
          count++;
        }
      }
      result.add((day: day, revenue: rev, orders: count));
    }
    return result;
  }

  List<({String label, double revenue, int orders})> _weeklyData(
    List<Order> orders,
  ) {
    final now = DateTime.now();
    final result = <({String label, double revenue, int orders})>[];
    for (int i = 3; i >= 0; i--) {
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      double rev = 0;
      int count = 0;
      for (final o in orders) {
        if (o.createdAt.isAfter(
              weekStart.subtract(const Duration(days: 1)),
            ) &&
            o.createdAt.isBefore(weekEnd.add(const Duration(days: 1)))) {
          rev += o.totalPrice;
          count++;
        }
      }
      final startStr = '${weekStart.month}/${weekStart.day}';
      final endStr = '${weekEnd.month}/${weekEnd.day}';
      result.add((label: '$startStr-$endStr', revenue: rev, orders: count));
    }
    return result;
  }

  List<({int hour, int count})> _peakHours(List<Order> orders) {
    final counts = List.filled(24, 0);
    for (final o in orders) {
      counts[o.createdAt.hour]++;
    }
    return [
      for (int h = 0; h < 24; h++)
        (hour: h, count: counts[h]),
    ];
  }

  List<(String, int)> _statusCounts(List<Order> orders) {
    final counts = <String, int>{};
    for (final o in orders) {
      counts[o.status] = (counts[o.status] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => (e.key, e.value)).toList();
  }

  List<(String, int)> _topItems(List<Order> orders) {
    final map = <String, int>{};
    for (final o in orders) {
      for (final it in o.items) {
        map[it.menuItemName] = (map[it.menuItemName] ?? 0) + it.quantity;
      }
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => (e.key, e.value)).toList();
  }

  String _price(double v) {
    final s = v == v.roundToDouble()
        ? v.toInt().toString()
        : v.toStringAsFixed(2);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '.') {
        buf.write(s.substring(i));
        break;
      }
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _dayLabel(DateTime day) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[day.weekday % 7];
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
        actions: const [LanguageSelector()],
      ),
      body: RefreshIndicator(
        color: AppTheme.orange500,
        onRefresh: () => context.read<OrderProvider>().loadRestaurantOrders(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          children: [
            if (orders.isEmpty)
              _buildEmpty(loc)
            else ...[
              _buildKpis(loc, orders),
              const SizedBox(height: AppTheme.spaceMd),
              _buildPeriodToggle(loc),
              const SizedBox(height: AppTheme.spaceSm),
              _buildTrendCard(loc, _dailyData(_activeOrders(orders))),
              const SizedBox(height: AppTheme.spaceMd),
              _buildWeeklyCard(loc, _weeklyData(_activeOrders(orders))),
              const SizedBox(height: AppTheme.spaceMd),
              _buildPeakHoursCard(loc, _peakHours(_activeOrders(orders))),
              const SizedBox(height: AppTheme.spaceMd),
              _buildStatusCard(loc, _statusCounts(orders)),
              const SizedBox(height: AppTheme.spaceMd),
              _buildTopItemsCard(loc, _topItems(_activeOrders(orders))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations loc) {
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
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle(AppLocalizations loc) {
    return Row(
      children: [
        for (final days in [7, 30])
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spaceSm),
            child: ChoiceChip(
              label: Text(
                days == 7 ? '7 days' : '30 days',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              selected: _periodDays == days,
              onSelected: (_) => setState(() => _periodDays = days),
              selectedColor: AppTheme.orange50,
              labelStyle: TextStyle(
                color: _periodDays == days
                    ? AppTheme.orange600
                    : AppTheme.textSecondary,
              ),
              side: BorderSide(
                color: _periodDays == days
                    ? AppTheme.orange400
                    : AppTheme.borderLight,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKpis(AppLocalizations loc, List<Order> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    var todayCount = 0;
    var todayRevenue = 0.0;
    var weekCount = 0;
    var weekRevenue = 0.0;
    var revenue = 0.0;
    for (final o in orders) {
      if (_isCancelled(o)) continue;
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
    final active = orders.where((o) => !_isCancelled(o)).length;
    final avg = active == 0 ? 0.0 : revenue / active;

    return Column(
      children: [
        Row(
          children: [
            _kpiCard(
              label: loc.todayOrders,
              value: '$todayCount',
              icon: Icons.receipt_long_outlined,
              color: AppTheme.orange500,
            ),
            const SizedBox(width: AppTheme.spaceMd),
            _kpiCard(
              label: loc.todayRevenue,
              value: _price(todayRevenue),
              icon: Icons.payments_outlined,
              color: AppTheme.success,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            _kpiCard(
              label: 'This week',
              value: '$weekCount',
              icon: Icons.date_range_outlined,
              color: AppTheme.info,
            ),
            const SizedBox(width: AppTheme.spaceMd),
            _kpiCard(
              label: 'Week revenue',
              value: _price(weekRevenue),
              icon: Icons.account_balance_wallet_outlined,
              color: AppTheme.warning,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            _kpiCard(
              label: loc.totalOrders,
              value: '${orders.length}',
              icon: Icons.list_alt_outlined,
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            _kpiCard(
              label: loc.avgOrderValue,
              value: _price(avg),
              icon: Icons.stacked_line_chart_outlined,
              color: const Color(0xFFEC4899),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: Colors.white,
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

  Widget _buildTrendCard(
    AppLocalizations loc,
    List<({DateTime day, double revenue, int orders})> days,
  ) {
    final maxRev = days.fold<double>(
      0,
      (m, d) => d.revenue > m ? d.revenue : m,
    );
    final showLabel = days.length <= 10;
    return _sectionCard(
      title: loc.revenueTrend,
      icon: Icons.bar_chart_outlined,
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final d in days)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (d.revenue > 0)
                        Text(
                          _price(d.revenue),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.gray400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      Container(
                        height: 60,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: maxRev == 0
                              ? 2
                              : (d.revenue / maxRev) * 60,
                          decoration: BoxDecoration(
                            color: d.orders > 0
                                ? AppTheme.orange500
                                : AppTheme.gray200,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (showLabel)
                        Text(
                          _dayLabel(d.day),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray400,
                          ),
                        )
                      else
                        Text(
                          '${d.day.day}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray400,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCard(
    AppLocalizations loc,
    List<({String label, double revenue, int orders})> weeks,
  ) {
    final maxRev = weeks.fold<double>(
      0,
      (m, w) => w.revenue > m ? w.revenue : m,
    );
    return _sectionCard(
      title: 'Weekly Summary',
      icon: Icons.calendar_view_week_outlined,
      child: Column(
        children: [
          for (var i = 0; i < weeks.length; i++) ...[
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    weeks[i].label,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    child: LinearProgressIndicator(
                      value: maxRev == 0 ? 0 : weeks[i].revenue / maxRev,
                      minHeight: 10,
                      backgroundColor: AppTheme.gray100,
                      color: AppTheme.orange500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    _price(weeks[i].revenue),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.orange600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text(
                    '${weeks[i].orders}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.gray500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            if (i != weeks.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildPeakHoursCard(
    AppLocalizations loc,
    List<({int hour, int count})> hours,
  ) {
    final maxCount = hours.fold<int>(0, (m, h) => h.count > m ? h.count : m);
    final peakHour = hours.reduce(
      (a, b) => a.count >= b.count ? a : b,
    );
    return _sectionCard(
      title: 'Peak Hours',
      icon: Icons.access_time_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceSm),
            decoration: BoxDecoration(
              color: AppTheme.orange50,
              borderRadius: AppTheme.roundedMd,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.orange600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Busiest: ${_hourLabel(peakHour.hour)}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.orange600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${peakHour.count} orders',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.orange600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final h in hours)
                  Expanded(
                    child: Tooltip(
                      message: '${_hourLabel(h.hour)}: ${h.count}',
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        height: maxCount == 0
                            ? 2
                            : (h.count / maxCount) * 70,
                        decoration: BoxDecoration(
                          color: h.count == maxCount && h.count > 0
                              ? AppTheme.orange600
                              : h.count > 0
                                  ? AppTheme.orange300
                                  : AppTheme.gray100,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12 AM',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 8,
                  color: AppTheme.gray400,
                ),
              ),
              Text(
                '12 PM',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 8,
                  color: AppTheme.gray400,
                ),
              ),
              Text(
                '11 PM',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 8,
                  color: AppTheme.gray400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _hourLabel(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }

  Widget _buildStatusCard(AppLocalizations loc, List<(String, int)> counts) {
    final total = counts.fold<int>(0, (s, c) => s + c.$2);
    return _sectionCard(
      title: loc.statusBreakdown,
      icon: Icons.donut_small_outlined,
      child: Column(
        children: [
          for (final (status, count) in counts) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    loc.statusText(status),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.gray500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : count / total,
                minHeight: 8,
                backgroundColor: AppTheme.gray100,
                color: _statusColor(status),
              ),
            ),
            if (status != counts.last.$1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.orange500;
      case 'confirmed':
        return AppTheme.info;
      case 'preparing':
      case 'in progress':
        return const Color(0xFF8B5CF6);
      case 'out for delivery':
      case 'delivered':
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
      case 'canceled':
        return AppTheme.danger;
      default:
        return AppTheme.gray500;
    }
  }

  Widget _buildTopItemsCard(AppLocalizations loc, List<(String, int)> items) {
    return _sectionCard(
      title: loc.topItems,
      icon: Icons.local_fire_department_outlined,
      child: Column(
        children: [
          for (var i = 0; i < items.length && i < 8; i++) ...[
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i < 3 ? AppTheme.orange50 : AppTheme.gray100,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: i < 3 ? AppTheme.orange600 : AppTheme.gray500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i].$1,
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
                  '×${items[i].$2}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.orange600,
                  ),
                ),
              ],
            ),
            if (i != items.length - 1 && i != 7) const Divider(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
              Icon(icon, size: 16, color: AppTheme.orange500),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          child,
        ],
      ),
    );
  }
}
