import 'package:flutter/material.dart';

import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/sales_analytics.dart';
import 'sales_section_card.dart';

class SalesTrendCard extends StatelessWidget {
  const SalesTrendCard({super.key, required this.loc, required this.days});

  final AppLocalizations loc;
  final List<({DateTime day, double revenue, int orders})> days;

  @override
  Widget build(BuildContext context) {
    final maxRev = days.fold<double>(
      0,
      (m, d) => d.revenue > m ? d.revenue : m,
    );
    final showLabel = days.length <= 10;
    return SalesSectionCard(
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
                          formatPrice(d.revenue),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textMuted,
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
                                : context.colors.subtleFill,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (showLabel)
                        Text(
                          SalesAnalytics.dayLabel(d.day),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textMuted,
                          ),
                        )
                      else
                        Text(
                          '${d.day.day}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textMuted,
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
}
