import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';

class RestaurantHeader extends StatelessWidget {
  const RestaurantHeader({
    super.key,
    required this.restaurant,
    required this.onOrders,
    required this.onDeliveries,
    required this.onDeliverySettings,
    required this.onEdit,
  });

  final Restaurant restaurant;
  final VoidCallback onOrders;
  final VoidCallback onDeliveries;
  final VoidCallback onDeliverySettings;
  final VoidCallback onEdit;

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final r = restaurant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceLg,
        AppTheme.spaceLg,
        AppTheme.spaceMd,
        AppTheme.spaceLg,
      ),
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppTheme.roundedLg,
            ),
            child: ClipRRect(
              borderRadius: AppTheme.roundedLg,
              child: r.logo != null
                  ? CachedNetworkImage(
                      imageUrl: r.logo!,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                    )
                  : const Icon(Icons.restaurant, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (r.address != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      r.address!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                if (r.isApproved)
                  _badge(loc.approved, AppTheme.success.withValues(alpha: 0.9))
                else
                  _badge(
                    loc.restaurantNotApproved,
                    AppTheme.warning.withValues(alpha: 0.9),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onOrders,
                icon: const Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white,
                ),
                tooltip: loc.orders,
              ),
              IconButton(
                onPressed: onDeliveries,
                icon: const Icon(
                  Icons.delivery_dining_outlined,
                  color: Colors.white,
                ),
                tooltip: loc.deliveries,
              ),
              IconButton(
                onPressed: onDeliverySettings,
                icon: const Icon(Icons.tune, color: Colors.white),
                tooltip: loc.deliverySettings,
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: loc.editRestaurant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
