import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DeliveryRouteRow extends StatelessWidget {
  const DeliveryRouteRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: AppTheme.labelSmall.copyWith(
            color: labelColor ?? context.colors.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              color: valueColor ?? context.colors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
