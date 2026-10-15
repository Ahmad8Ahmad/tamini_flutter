import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/screens/home_screen.dart';
import '../controllers/owner_home_controller.dart';
import '../widgets/owner_bottom_nav.dart';
import '../widgets/owner_settings_view.dart';
import '../widgets/restaurant_overview_view.dart';
import '../widgets/restaurant_selector_view.dart';
import 'my_restaurant_screen.dart';
import 'restaurant_orders_screen.dart';
import 'sales_dashboard_screen.dart';

/// Owner workspace shell. Owns a single [OwnerHomeController] that holds the
/// selected restaurant and active tab; the heavy lifting is delegated to the
/// widgets under `widgets/`.
class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  late final OwnerHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OwnerHomeController(context.read<OwnerProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.loadRestaurants();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleActive(Restaurant restaurant) async {
    final loc = AppLocalizations.of(context);
    final saved = await _controller.toggleActive(restaurant);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? loc.savedSuccessfully : loc.errorOccurred),
        backgroundColor: saved ? AppTheme.success : AppTheme.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            loc.appName,
            style: const TextStyle(
              fontFamily: 'Lalezar',
              fontSize: 22,
              color: AppTheme.orange600,
            ),
          ),
          foregroundColor: AppTheme.orange600,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.storefront_outlined),
              tooltip: loc.backToHome,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
        body: _buildBody(auth.user),
        bottomNavigationBar: _controller.hasSelectedRestaurant
            ? OwnerBottomNav(
                currentIndex: _controller.currentIndex,
                onTap: _controller.selectTab,
              )
            : null,
      ),
    );
  }

  Widget _buildBody(User? user) {
    final restaurant = _controller.selectedRestaurant;
    if (restaurant == null) {
      return RestaurantSelectorView(
        user: user,
        onSelect: _controller.selectRestaurant,
        onToggleActive: _toggleActive,
      );
    }

    return IndexedStack(
      index: _controller.currentIndex,
      children: [
        RestaurantOverviewView(
          restaurant: restaurant,
          onSelectTab: _controller.selectTab,
        ),
        const RestaurantOrdersScreen(),
        MyRestaurantScreen(restaurant: restaurant),
        const SalesDashboardScreen(),
        OwnerSettingsView(
          restaurant: restaurant,
          onBackToRestaurants: _controller.clearRestaurant,
        ),
      ],
    );
  }
}
