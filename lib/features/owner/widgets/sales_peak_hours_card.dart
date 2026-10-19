import 'package:flutter/material.dart';

import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import 'sales_section_card.dart';

class SalesPeakHoursCard extends StatelessWidget {
  const SalesPeakHoursCard({super.key, required this.loc, required this.hours});

  final AppLocalizations loc;
  final List<({int hour, int count})> hours;

  String _hourLabel(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }

  @override
  Widget build(BuildContext context) {
    final maxCount = hours.fold<int>(0, (m, h) => h.count > m ? h.count : m);
    final peakHour = hours.reduce(
      (a, b) => a.count >= b.count ? a : b,
    );
    return SalesSectionCard(
      title: 'Peak Hours',
      icon: Icons.access_time_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceSm),
            decoration: BoxDecoration(
              color: context.colors.tint,
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
                                  : context.colors.subtleFill,
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
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 8,
                  color: context.colors.textMuted,
                ),
              ),
              Text(
                '12 PM',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 8,
                  color: context.colors.textMuted,
                ),
              ),
              Text(
                '11 PM',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 8,
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
