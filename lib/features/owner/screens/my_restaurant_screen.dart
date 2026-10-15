import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import 'meal_form_screen.dart';
import 'offer_form_screen.dart';
import 'delivery_settings_screen.dart';
import 'restaurant_delivery_screen.dart';
import 'restaurant_edit_screen.dart';
import 'restaurant_orders_screen.dart';

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
          _buildHeader(provider, loc),
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

  Widget _buildHeader(OwnerProvider provider, AppLocalizations loc) {
    final r = widget.restaurant;
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
                onPressed: () => _openOrders(),
                icon: const Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white,
                ),
                tooltip: loc.orders,
              ),
              IconButton(
                onPressed: () => _openDeliveries(),
                icon: const Icon(
                  Icons.delivery_dining_outlined,
                  color: Colors.white,
                ),
                tooltip: loc.deliveries,
              ),
              IconButton(
                onPressed: () => _openDeliverySettings(),
                icon: const Icon(Icons.tune, color: Colors.white),
                tooltip: loc.deliverySettings,
              ),
              IconButton(
                onPressed: () => _openEdit(r, loc),
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: loc.editRestaurant,
              ),
            ],
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
        itemBuilder: (ctx, i) =>
            _buildMealCard(provider.ownerMenu[i], provider, loc),
      ),
    );
  }

  Widget _buildMealCard(
    MenuItem item,
    OwnerProvider provider,
    AppLocalizations loc,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: context.colors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: AppTheme.roundedLg,
            onTap: () => _openMealForm(item),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceSm,
                AppTheme.spaceSm,
                AppTheme.spaceSm,
                AppTheme.spaceXs,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: AppTheme.roundedMd,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: item.image != null
                          ? CachedNetworkImage(
                              imageUrl: item.image!,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => const Icon(
                                Icons.restaurant_menu,
                                color: AppTheme.orange300,
                              ),
                            )
                          : const Icon(
                              Icons.restaurant_menu,
                              color: AppTheme.orange300,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: context.colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!item.isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.subtleFill,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  loc.notAvailable,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.categoryName,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (item.discountPrice != null) ...[
                              Text(
                                formatPrice(item.discountPrice!),
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.orange600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formatPrice(item.price),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: context.colors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: AppTheme.orange500,
                              ),
                            ] else
                              Text(
                                formatPrice(item.price),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteMeal(item, loc),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.danger,
                      size: 20,
                    ),
                    tooltip: loc.deleteMeal,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceSm,
              0,
              AppTheme.spaceSm,
              AppTheme.spaceSm,
            ),
            child: Row(
              children: [
                if (_togglingItemId == item.id)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.orange500,
                    ),
                  )
                else
                  Switch(
                    value: item.isAvailable,
                    activeTrackColor: AppTheme.orange400,
                    onChanged: (v) => _toggleAvailability(item, v, loc),
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.isAvailable ? loc.availableForOrder : loc.notAvailable,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: item.isAvailable
                          ? AppTheme.success
                          : context.colors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  item.isAvailable ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                  color: item.isAvailable ? AppTheme.success : AppTheme.gray300,
                ),
              ],
            ),
          ),
        ],
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
          return _buildOfferCard(offers[i], provider, loc);
        },
      ),
    );
  }

  Widget _buildOfferCard(
    MenuItem item,
    OwnerProvider provider,
    AppLocalizations loc,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: AppTheme.orange200),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.tint,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: AppTheme.orange500,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatPrice(item.discountPrice!),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.orange600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatPrice(item.price),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: context.colors.textMuted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openOfferForm(item),
            icon: const Icon(
              Icons.edit_outlined,
              color: AppTheme.orange600,
              size: 20,
            ),
            tooltip: loc.editOffer,
          ),
          IconButton(
            onPressed: () => _removeOffer(item, loc),
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.danger,
              size: 20,
            ),
            tooltip: loc.removeOffer,
          ),
        ],
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
        backgroundColor: ok ? AppTheme.danger : AppTheme.danger,
      ),
    );
  }
}
