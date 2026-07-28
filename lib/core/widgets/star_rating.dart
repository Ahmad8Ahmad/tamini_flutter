import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool showText;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.showText = true,
    this.color = AppTheme.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, size: size, color: color);
          } else if (index < rating && rating % 1 != 0) {
            return Icon(Icons.star_half, size: size, color: color);
          }
          return Icon(Icons.star_outline, size: size, color: AppTheme.gray300);
        }),
        if (showText && rating > 0) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: size * 0.8,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
