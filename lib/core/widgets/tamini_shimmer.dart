import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class TaminiShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const TaminiShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.gray100,
      highlightColor: AppTheme.gray50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget card() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          TaminiShimmer(width: 70, height: 70, borderRadius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaminiShimmer(width: 120, height: 16, borderRadius: 8),
                SizedBox(height: 8),
                TaminiShimmer(width: 80, height: 12, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget banner() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TaminiShimmer(width: double.infinity, height: 180, borderRadius: 16),
    );
  }

  static Widget list({int count = 5}) {
    return Column(
      children: List.generate(count, (_) => card()),
    );
  }
}
