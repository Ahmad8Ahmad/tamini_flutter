import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TaminiBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  const TaminiBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderLight, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(context, 0, Icons.home_outlined, Icons.home, 'home'),
              _buildItem(context, 1, Icons.store_outlined, Icons.store, 'restaurants'),
              _buildCartNavItem(context, 2),
              _buildItem(context, 3, Icons.receipt_long_outlined, Icons.receipt_long, 'orders'),
              _buildItem(context, 4, Icons.person_outline, Icons.person, 'profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = currentIndex == index;
    final locLabel = _getLabel(context, label);
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.orange50 : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected ? AppTheme.orange600 : AppTheme.orange500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              locLabel,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.orange600 : AppTheme.orange500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartNavItem(BuildContext context, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.orange50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Icon(
                    isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                    size: 24,
                    color: isSelected ? AppTheme.orange600 : AppTheme.orange500,
                  ),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 6,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: const BoxDecoration(
                        color: AppTheme.orange500,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _getLabel(context, 'cart'),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.orange600 : AppTheme.orange500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(BuildContext context, String key) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    const ar = {'home': 'الوجبات', 'restaurants': 'المطاعم', 'cart': 'السلة', 'orders': 'طلباتي', 'profile': 'الحساب'};
    const en = {'home': 'Home', 'restaurants': 'Restaurants', 'cart': 'Cart', 'orders': 'Orders', 'profile': 'Profile'};
    return (isArabic ? ar : en)[key] ?? key;
  }
}
