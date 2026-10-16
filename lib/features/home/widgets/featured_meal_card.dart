import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../restaurant/screens/restaurant_detail_screen.dart';

class FeaturedMealCard extends StatelessWidget {
  const FeaturedMealCard({super.key, required this.item, required this.onAdd});

  final MenuItem item;
  final Future<void> Function() onAdd;

  void _openRestaurant(BuildContext context) {
    final catalog = context.read<CatalogProvider>();
    final restaurant =
        catalog.restaurantById(item.restaurant) ??
        Restaurant(id: item.restaurant, name: item.restaurantName);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            RestaurantDetailScreen(restaurant: restaurant),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.colors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: () => _openRestaurant(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLg),
                  ),
                  child: item.image != null
                      ? CachedNetworkImage(
                          imageUrl: item.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, _) => Container(
                            color: context.colors.tint,
                            child: const Icon(
                              Icons.fastfood,
                              color: AppTheme.orange300,
                            ),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: context.colors.tint,
                            child: const Icon(
                              Icons.fastfood,
                              color: AppTheme.orange300,
                            ),
                          ),
                        )
                      : Container(
                          color: context.colors.tint,
                          child: const Icon(
                            Icons.fastfood,
                            color: AppTheme.orange300,
                            size: 32,
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: context.colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.restaurantName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.discountPrice != null) ...[
                          Text(
                            '${item.discountPrice!.toStringAsFixed(0)} SYP',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.orange600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price.toStringAsFixed(0)} SYP',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else
                          Text(
                            '${item.price.toStringAsFixed(0)} SYP',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.orange600,
                            ),
                          ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
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
      ),
    );
  }
}
