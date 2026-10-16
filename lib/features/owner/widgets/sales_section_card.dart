import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SalesSectionCard extends StatelessWidget {
  const SalesSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.card,
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
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: context.colors.textPrimary,
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
