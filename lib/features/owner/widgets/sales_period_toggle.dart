import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SalesPeriodToggle extends StatelessWidget {
  const SalesPeriodToggle({
    super.key,
    required this.periodDays,
    required this.onChanged,
  });

  final int periodDays;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
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
              selected: periodDays == days,
              onSelected: (_) => onChanged(days),
              selectedColor: context.colors.tint,
              labelStyle: TextStyle(
                color: periodDays == days
                    ? AppTheme.orange600
                    : context.colors.textSecondary,
              ),
              side: BorderSide(
                color: periodDays == days
                    ? AppTheme.orange400
                    : context.colors.borderLight,
              ),
            ),
          ),
      ],
    );
  }
}
