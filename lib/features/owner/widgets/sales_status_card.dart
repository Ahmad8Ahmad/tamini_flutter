import 'package:flutter/material.dart';

import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import 'sales_section_card.dart';

class SalesStatusCard extends StatelessWidget {
  const SalesStatusCard({super.key, required this.loc, required this.counts});

  final AppLocalizations loc;
  final List<(String, int)> counts;

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

  @override
  Widget build(BuildContext context) {
    final total = counts.fold<int>(0, (s, c) => s + c.$2);
    return SalesSectionCard(
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
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textSecondary,
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
                backgroundColor: context.colors.subtleFill,
                color: _statusColor(status),
              ),
            ),
            if (status != counts.last.$1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
