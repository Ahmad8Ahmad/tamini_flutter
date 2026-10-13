import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/delivery_settings_screen.dart';
import '../screens/my_restaurant_screen.dart';
import '../screens/restaurant_edit_screen.dart';
import '../screens/staff_management_screen.dart';

/// Home tab for a selected restaurant: a branded header plus quick-action
/// shortcuts into orders, the menu, sales, editing and delivery settings.
class RestaurantOverviewView extends StatelessWidget {
  const RestaurantOverviewView({
    super.key,
    required this.restaurant,
    required this.onSelectTab,
  });

  final Restaurant restaurant;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _OverviewHeader(restaurant: restaurant),
          const SizedBox(height: AppTheme.spaceMd),
          _QuickActions(restaurant: restaurant, onSelectTab: onSelectTab),
          const SizedBox(height: AppTheme.spaceMd),
        ],
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
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
                  : const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 32,
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.restaurant, required this.onSelectTab});

  final Restaurant restaurant;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final r = restaurant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.manage,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.receipt_long_outlined,
                  label: loc.orders,
                  onTap: () => onSelectTab(1),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: _ActionCard(
                  icon: Icons.restaurant_menu,
                  label: loc.menuItems,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyRestaurantScreen(restaurant: r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.insights_outlined,
                  label: loc.salesDashboard,
                  onTap: () => onSelectTab(3),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: _ActionCard(
                  icon: Icons.edit_outlined,
                  label: loc.editRestaurant,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantEditScreen(restaurant: r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.delivery_dining_outlined,
                  label: loc.deliverySettings,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliverySettingsScreen(restaurant: r),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: _ActionCard(
                  icon: Icons.people_outline,
                  label: loc.staffManagement,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StaffManagementScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppTheme.roundedLg,
        boxShadow: AppTheme.shadowSm,
      ),
      child: InkWell(
        borderRadius: AppTheme.roundedLg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
            vertical: AppTheme.spaceLg,
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.orange600, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
