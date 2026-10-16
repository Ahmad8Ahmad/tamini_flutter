import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../restaurant/screens/restaurant_detail_screen.dart';

class TrendyRestaurantCard extends StatelessWidget {
  const TrendyRestaurantCard({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => RestaurantDetailScreen(restaurant: r),
          transitionsBuilder: (_, anim, _, child) => SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: child,
          ),
        ),
      ),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: context.colors.borderLight),
          boxShadow: AppTheme.shadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: r.coverImage != null
                  ? CachedNetworkImage(
                      imageUrl: r.coverImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, _) => Container(
                        color: context.colors.subtleFill,
                        child: const Icon(Icons.store, color: AppTheme.gray300),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: context.colors.subtleFill,
                        child: const Icon(Icons.store, color: AppTheme.gray300),
                      ),
                    )
                  : Container(
                      color: context.colors.subtleFill,
                      child: const Icon(
                        Icons.store,
                        color: AppTheme.gray300,
                        size: 32,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppTheme.orange500,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: r.logo != null
                        ? CachedNetworkImage(
                            imageUrl: r.logo!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, _) =>
                                Container(color: AppTheme.orange500),
                            errorWidget: (_, _, _) =>
                                Container(color: AppTheme.orange500),
                          )
                        : Center(
                            child: Text(
                              r.name.isNotEmpty ? r.name[0] : '؟',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (r.averageRating ?? 0).toStringAsFixed(1),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: context.colors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
