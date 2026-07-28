import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DiscountBadge extends StatelessWidget {
  final double originalPrice;
  final double discountPrice;

  const DiscountBadge({
    super.key,
    required this.originalPrice,
    required this.discountPrice,
  });

  double get percentage => ((originalPrice - discountPrice) / originalPrice * 100);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.danger,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        '-${percentage.round()}%',
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
