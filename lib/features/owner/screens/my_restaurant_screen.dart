import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import 'meal_form_screen.dart';
import 'offer_form_screen.dart';
import 'delivery_settings_screen.dart';
import 'restaurant_delivery_screen.dart';
import 'restaurant_edit_screen.dart';
import 'restaurant_orders_screen.dart';
import '../widgets/owner_meal_card.dart';
import '../widgets/owner_offer_card.dart';
import '../widgets/restaurant_header.dart';

class MyRestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;

  const MyRestaurantScreen({super.key, required this.restaurant});

  @override
  State<MyRestaurantScreen> createState() => _MyRestaurantScreenState();
}

class _MyRestaurantScreenState extends State<MyRestaurantScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int? _togglingItemId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ownerProvider = context.read<OwnerProvider>();
      ownerProvider.loadOwnerMenu(widget.restaurant.id);
      final catalogProvider = context.read<CatalogProvider>();
      if (catalogProvider.categories.isEmpty) catalogProvider.loadHome();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await context.read<OwnerProvider>().loadOwnerMenu(
      widget.restaurant.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<OwnerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.manageRestaurant),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMealForm(),
        backgroundColor: AppTheme.orange500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          loc.addMeal,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          RestaurantHeader(
            restaurant: widget.restaurant,
            onOrders: _openOrders,
            onDeliveries: _openDeliveries,
            onDeliverySettings: _openDeliverySettings,
            onEdit: () => _openEdit(widget.restaurant, loc),
          ),
          Container(
            color: context.colors.card,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.orange600,
              unselectedLabelColor: context.colors.textSecondary,
              indicatorColor: AppTheme.orange500,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: loc.menuItems),
                Tab(text: loc.offers),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMenuTab(provider, loc),
                _buildOffersTab(provider, loc),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _openOrders() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RestaurantOrdersScreen()),
    );
  }

  Future<void> _openDeliveries() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDeliveryScreen(
          restaurantId: widget.restaurant.id,
          restaurantName: widget.restaurant.name,
        ),
      ),
    );
  }

  Future<void> _openEdit(Restaurant restaurant, AppLocalizations loc) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantEditScreen(restaurant: restaurant),
      ),
    );
    if (mounted) await _reload();
  }

  Future<void> _openDeliverySettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeliverySettingsScreen(restaurant: widget.restaurant),
      ),
    );
    if (mounted) await _reload();
  }


  Widget _buildMenuTab(OwnerProvider provider, AppLocalizations loc) {
    if (provider.ownerLoading && provider.ownerMenu.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.orange500),
      );
    }
    if (provider.ownerMenu.isEmpty) {
      return TaminiEmptyState(
        icon: Icons.restaurant_menu,
        title: loc.noItemsYet,
        subtitle: loc.noItemsYetHint,
      );
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        itemCount: provider.ownerMenu.length,
        itemBuilder: (ctx, i) {
          final item = provider.ownerMenu[i];
          return OwnerMealCard(
            item: item,
            isToggling: _togglingItemId == item.id,
            onEdit: () => _openMealForm(item),
            onDelete: () => _deleteMeal(item, loc),
            onToggleAvailability: (v) => _toggleAvailability(item, v, loc),
          );
        },
      ),
    );
  }


  Widget _buildOffersTab(OwnerProvider provider, AppLocalizations loc) {
    final offers = provider.ownerMenu
        .where((e) => e.discountPrice != null)
        .toList();
    if (offers.isEmpty) {
      return TaminiEmptyState(
        icon: Icons.local_fire_department_outlined,
        title: loc.noOffersYet,
        subtitle: loc.noOffersYetHint,
        actionText: loc.addOffer,
        onAction: _openOfferForm,
      );
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        itemCount: offers.length + 1,
        itemBuilder: (ctx, i) {
          if (i == offers.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
              child: OutlinedButton.icon(
                onPressed: _openOfferForm,
                icon: const Icon(Icons.add, color: AppTheme.orange600),
                label: Text(
                  loc.addOffer,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                    color: AppTheme.orange600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.orange300),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.roundedLg,
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            );
          }
          final item = offers[i];
          return OwnerOfferCard(
            item: item,
            onEdit: () => _openOfferForm(item),
            onRemove: () => _removeOffer(item, loc),
          );
        },
      ),
    );
  }


  Future<void> _openMealForm([MenuItem? item]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MealFormScreen(restaurantId: widget.restaurant.id, item: item),
      ),
    );
    if (mounted) await _reload();
  }

  Future<void> _openOfferForm([MenuItem? item]) async {
    if (item == null && context.read<OwnerProvider>().ownerMenu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noItemsYet),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OfferFormScreen(restaurantId: widget.restaurant.id, item: item),
      ),
    );
    if (mounted) await _reload();
  }

  Future<void> _removeOffer(MenuItem item, AppLocalizations loc) async {
    final provider = context.read<OwnerProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          loc.removeOffer,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          loc.removeOfferConfirm,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              loc.cancel,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              loc.confirm,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppTheme.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await provider.clearDiscount(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.offerRemoved : loc.errorOccurred),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
      ),
    );
  }

  Future<void> _toggleAvailability(
    MenuItem item,
    bool value,
    AppLocalizations loc,
  ) async {
    setState(() => _togglingItemId = item.id);
    final ok = await context.read<OwnerProvider>().setMenuItemAvailability(
      id: item.id,
      isAvailable: value,
    );
    if (!mounted) return;
    setState(() => _togglingItemId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.savedSuccessfully : loc.errorOccurred),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
      ),
    );
  }

  Future<void> _deleteMeal(MenuItem item, AppLocalizations loc) async {
    final provider = context.read<OwnerProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          loc.deleteConfirmTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          loc.deleteMealConfirm,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              loc.cancel,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              loc.confirm,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppTheme.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await provider.deleteMenuItem(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.deleted : loc.errorOccurred),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
      ),
    );
  }
}
