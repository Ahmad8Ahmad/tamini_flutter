import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/language_selector.dart';
import 'meal_form_screen.dart';
import 'offer_form_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<RestaurantProvider>();
      provider.loadOwnerMenu(widget.restaurant.id);
      if (provider.categories.isEmpty) provider.loadHome();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await context.read<RestaurantProvider>().loadOwnerMenu(
      widget.restaurant.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.manageRestaurant),
        actions: const [LanguageSelector()],
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
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.orange600,
              unselectedLabelColor: AppTheme.textSecondary,
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

  Widget _buildHeader(RestaurantProvider provider, AppLocalizations loc) {
    final r = provider.restaurants.firstWhere(
      (e) => e.id == widget.restaurant.id,
      orElse: () => widget.restaurant,
    );
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
                  _badge(
                    loc.approved,
                    AppTheme.success.withValues(alpha: 0.9),
                  )
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
                icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
                tooltip: loc.orders,
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

  Future<void> _openEdit(Restaurant restaurant, AppLocalizations loc) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantEditScreen(restaurant: restaurant),
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

  Widget _buildMenuTab(RestaurantProvider provider, AppLocalizations loc) {
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
    RestaurantProvider provider,
    AppLocalizations loc,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: InkWell(
        borderRadius: AppTheme.roundedLg,
        onTap: () => _openMealForm(item),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceSm),
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
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
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
                              color: AppTheme.gray100,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Text(
                              loc.notAvailable,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.categoryName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.discountPrice != null) ...[
                          Text(
                            _price(item.discountPrice!),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.orange600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _price(item.price),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppTheme.gray400,
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
                            _price(item.price),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
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
    );
  }

  Widget _buildOffersTab(RestaurantProvider provider, AppLocalizations loc) {
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
    RestaurantProvider provider,
    AppLocalizations loc,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: AppTheme.orange200),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.orange50,
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
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _price(item.discountPrice!),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.orange600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _price(item.price),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppTheme.gray400,
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
    if (item == null && context.read<RestaurantProvider>().ownerMenu.isEmpty) {
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
    final provider = context.read<RestaurantProvider>();
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

  Future<void> _deleteMeal(MenuItem item, AppLocalizations loc) async {
    final provider = context.read<RestaurantProvider>();
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

  String _price(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
}
