import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/delivery_settings_screen.dart';
import '../screens/restaurant_edit_screen.dart';
import '../screens/staff_management_screen.dart';

/// Settings tab for a selected restaurant: edit, delivery settings and staff,
/// plus a shortcut back to the restaurant list.
class OwnerSettingsView extends StatelessWidget {
  const OwnerSettingsView({
    super.key,
    required this.restaurant,
    required this.onBackToRestaurants,
  });

  final Restaurant restaurant;
  final VoidCallback onBackToRestaurants;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final r = restaurant;

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      children: [
        _SettingsTile(
          icon: Icons.edit_outlined,
          title: loc.editRestaurant,
          subtitle: loc.restaurantDescription,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantEditScreen(restaurant: r),
            ),
          ),
        ),
        _SettingsTile(
          icon: Icons.delivery_dining_outlined,
          title: loc.deliverySettings,
          subtitle: loc.deliverySettingsHint,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeliverySettingsScreen(restaurant: r),
            ),
          ),
        ),
        _SettingsTile(
          icon: Icons.people_outline,
          title: loc.staffManagement,
          subtitle: '',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StaffManagementScreen()),
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),
        OutlinedButton.icon(
          onPressed: onBackToRestaurants,
          icon: const Icon(Icons.storefront_outlined, color: AppTheme.orange600),
          label: Text(
            loc.myRestaurants,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w800,
              color: AppTheme.orange600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.orange300),
            shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppTheme.roundedLg,
        boxShadow: AppTheme.shadowSm,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.tint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.orange600, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: context.colors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppTheme.gray400,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
      ),
    );
  }
}
