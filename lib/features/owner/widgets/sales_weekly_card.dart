import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import 'sales_section_card.dart';

class SalesWeeklyCard extends StatelessWidget {
  const SalesWeeklyCard({super.key, required this.loc, required this.weeks});

  final AppLocalizations loc;
  final List<({String label, double revenue, int orders})> weeks;

  @override
  Widget build(BuildContext context) {
    final maxRev = weeks.fold<double>(
      0,
      (m, w) => w.revenue > m ? w.revenue : m,
    );
    return SalesSectionCard(
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
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    child: LinearProgressIndicator(
                      value: maxRev == 0 ? 0 : weeks[i].revenue / maxRev,
                      minHeight: 10,
                      backgroundColor: context.colors.subtleFill,
                      color: AppTheme.orange500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    formatPrice(weeks[i].revenue),
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
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textSecondary,
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
}
