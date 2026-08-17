import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class DeliveryEarningsScreen extends StatelessWidget {
  const DeliveryEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final p = context.watch<DeliveryProvider>();
    final done = p.completedDeliveries;

    if (done.isEmpty) {
      return _empty(loc);
    }

    return RefreshIndicator(
      color: AppTheme.orange500,
      onRefresh: p.loadMyDeliveries,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        children: [
          _buildTodayEarnings(done, loc),
          const SizedBox(height: AppTheme.spaceMd),
          _buildKpis(done, loc),
          const SizedBox(height: AppTheme.spaceMd),
          _buildWeeklyBar(done, loc),
          const SizedBox(height: AppTheme.spaceMd),
          _buildRecentTrips(done, loc),
        ],
      ),
    );
  }

  Widget _empty(AppLocalizations loc) {
    return Center(
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
                Icons.account_balance_wallet_outlined,
                size: 46,
                color: AppTheme.orange300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.noEarningsYet,
              textAlign: TextAlign.center,
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              loc.noEarningsHint,
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayEarnings(List<Delivery> done, AppLocalizations loc) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayDeliveries = done.where((d) {
      final deliveredAt = d.deliveredAt;
      if (deliveredAt == null) return false;
      return DateTime(deliveredAt.year, deliveredAt.month, deliveredAt.day) ==
          today;
    }).toList();
    final todayEarnings = todayDeliveries.fold<int>(
      0,
      (sum, d) => sum + (d.calculatedFee ?? 0),
    );
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Column(
        children: [
          Text(
            loc.dailyEarnings,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_formatPrice(todayEarnings)} SYP',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${todayDeliveries.length} ${loc.totalTrips.toLowerCase()}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpis(List<Delivery> done, AppLocalizations loc) {
    final totalEarnings = done.fold<int>(
      0,
      (sum, d) => sum + (d.calculatedFee ?? 0),
    );
    final avgPerTrip = done.isEmpty ? 0 : totalEarnings ~/ done.length;
    final thisWeek = _thisWeekDeliveries(done);
    final weekEarnings = thisWeek.fold<int>(
      0,
      (sum, d) => sum + (d.calculatedFee ?? 0),
    );
    return Column(
      children: [
        Row(
          children: [
            _kpiCard(
              value: '${done.length}',
              label: loc.totalTrips,
              icon: Icons.local_shipping_outlined,
              color: AppTheme.success,
            ),
            const SizedBox(width: AppTheme.spaceMd),
            _kpiCard(
              value: _formatPrice(avgPerTrip),
              label: loc.avgEarningPerTrip,
              icon: Icons.stacked_line_chart_outlined,
              color: AppTheme.info,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            _kpiCard(
              value: '${_formatPrice(totalEarnings)} SYP',
              label: loc.totalEarnings,
              icon: Icons.payments_outlined,
              color: AppTheme.orange600,
            ),
            const SizedBox(width: AppTheme.spaceMd),
            _kpiCard(
              value: '${_formatPrice(weekEarnings)} SYP',
              label: loc.weeklyEarnings,
              icon: Icons.date_range_outlined,
              color: const Color(0xFF8B5CF6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String value,
    required String label,
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
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

  Widget _buildWeeklyBar(List<Delivery> done, AppLocalizations loc) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = <MapEntry<String, int>>[];
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dayDeliveries = done.where((d) {
        final deliveredAt = d.deliveredAt;
        if (deliveredAt == null) return false;
        final dDay = DateTime(
          deliveredAt.year,
          deliveredAt.month,
          deliveredAt.day,
        );
        return dDay == day;
      }).toList();
      final earnings = dayDeliveries.fold<int>(
        0,
        (sum, d) => sum + (d.calculatedFee ?? 0),
      );
      days.add(MapEntry(dayNames[(day.weekday - 1) % 7], earnings));
    }
    final maxEarnings = days.fold<int>(0, (m, e) => e.value > m ? e.value : m);

    return _sectionCard(
      title: loc.weeklyEarnings,
      icon: Icons.bar_chart_outlined,
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final entry in days)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (entry.value > 0)
                        Text(
                          _formatPrice(entry.value),
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
                        height: 80,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: maxEarnings == 0
                              ? 2
                              : (entry.value / maxEarnings) * 80,
                          decoration: BoxDecoration(
                            color: entry.value > 0
                                ? AppTheme.orange500
                                : AppTheme.gray200,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
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

  Widget _buildRecentTrips(List<Delivery> done, AppLocalizations loc) {
    final recent = List<Delivery>.from(done)
      ..sort((a, b) => (b.deliveredAt ?? DateTime(0))
          .compareTo(a.deliveredAt ?? DateTime(0)));
    final items = recent.take(10).toList();

    return _sectionCard(
      title: loc.myDeliveries,
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _tripRow(items[i], loc),
            if (i != items.length - 1) const Divider(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _tripRow(Delivery d, AppLocalizations loc) {
    final fee = d.calculatedFee ?? 0;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppTheme.successBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppTheme.success,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.restaurantName,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${loc.orderNumber}${d.orderId}',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ),
        Text(
          '+${_formatPrice(fee)} SYP',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppTheme.success,
          ),
        ),
      ],
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

  List<Delivery> _thisWeekDeliveries(List<Delivery> done) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return done.where((d) {
      final deliveredAt = d.deliveredAt;
      if (deliveredAt == null) return false;
      return deliveredAt.isAfter(weekAgo);
    }).toList();
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
