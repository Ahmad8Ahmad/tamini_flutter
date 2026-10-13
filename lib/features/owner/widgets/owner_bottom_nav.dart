import 'package:flutter/material.dart';

import '../../../core/theme/app_localizations.dart';

/// Bottom navigation for the selected-restaurant workspace.
class OwnerBottomNav extends StatelessWidget {
  const OwnerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined, size: 22),
          activeIcon: const Icon(Icons.home, size: 22),
          label: loc.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined, size: 22),
          activeIcon: const Icon(Icons.receipt_long, size: 22),
          label: loc.orders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.restaurant_menu, size: 22),
          activeIcon: const Icon(Icons.restaurant_menu, size: 22),
          label: loc.menu,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.insights_outlined, size: 22),
          activeIcon: const Icon(Icons.insights, size: 22),
          label: loc.salesDashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined, size: 22),
          activeIcon: const Icon(Icons.settings, size: 22),
          label: loc.deliverySettings,
        ),
      ],
    );
  }
}
