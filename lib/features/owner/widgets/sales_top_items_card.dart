import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import 'sales_section_card.dart';

class SalesTopItemsCard extends StatelessWidget {
  const SalesTopItemsCard({super.key, required this.loc, required this.items});

  final AppLocalizations loc;
  final List<(String, int)> items;

  @override
  Widget build(BuildContext context) {
    return SalesSectionCard(
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
                    color: i < 3
                        ? context.colors.tint
                        : context.colors.subtleFill,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: i < 3
                          ? AppTheme.orange600
                          : context.colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i].$1,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
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
}
