import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/tamini_bottom_nav.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/tamini_shimmer.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/star_rating.dart';

import '../../restaurant/screens/restaurant_detail_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  final _pageController = PageController();
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    context.read<RestaurantProvider>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SizedBox(key: const ValueKey('home'), child: _buildHomeTab()),
          SizedBox(key: const ValueKey('cart'), child: const CartScreen()),
          SizedBox(key: const ValueKey('orders'), child: const OrdersScreen()),
          SizedBox(key: const ValueKey('profile'), child: ProfileScreen(user: auth.user)),
        ],
      ),
      bottomNavigationBar: TaminiBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        cartCount: cart.itemCount,
      ),
    );
  }

  Widget _buildHomeTab() {
    final provider = context.watch<RestaurantProvider>();
    final loc = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        // ── App Bar with Search ───────────────────────────────
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restaurant, color: AppTheme.orange500, size: 24),
              const SizedBox(width: 8),
              Text(
                loc.appName,
                style: const TextStyle(
                  fontFamily: 'Lalezar',
                  fontSize: 24,
                  color: AppTheme.orange600,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _searchController,
                onSubmitted: (v) => provider.loadMenuItems(search: v),
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14),
                decoration: InputDecoration(
                  hintText: loc.searchFood,
                  hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppTheme.gray400, fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.orange400, size: 20),
                  filled: true,
                  fillColor: AppTheme.orange50.withValues(alpha: 0.6),
                  border: OutlineInputBorder(
                    borderRadius: AppTheme.roundedXl,
                    borderSide: const BorderSide(color: AppTheme.orange100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppTheme.roundedXl,
                    borderSide: const BorderSide(color: AppTheme.orange100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppTheme.roundedXl,
                    borderSide: const BorderSide(color: AppTheme.orange400, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
        ),

        // ── Hero Banners ──────────────────────────────────────
        if (provider.banners.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 190,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: provider.banners.length,
                    onPageChanged: (i) => setState(() => _currentBanner = i),
                    itemBuilder: (ctx, i) => _buildBanner(provider.banners[i]),
                  ),
                ),
                const SizedBox(height: 10),
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    provider.banners.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentBanner == i ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _currentBanner == i ? AppTheme.orange500 : AppTheme.orange200,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── Restaurants Section ───────────────────────────────
        SliverToBoxAdapter(
          child: SectionHeader(title: loc.restaurants, actionText: loc.viewAll, onAction: () {}),
        ),

        if (provider.loading && provider.restaurants.isEmpty)
          SliverToBoxAdapter(child: TaminiShimmer.list(count: 5))
        else if (provider.restaurants.isEmpty)
          SliverToBoxAdapter(
            child: TaminiEmptyState(
              icon: Icons.store_outlined,
              title: loc.isArabic ? 'لا توجد مطاعم' : 'No restaurants found',
              subtitle: loc.isArabic ? 'جرّب البحث عن طعام' : 'Try searching for food',
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildRestaurantCard(provider.restaurants[i]),
              childCount: provider.restaurants.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildBanner(HeroBanner banner) {
    final baseUrl = ApiClient.baseUrl.replaceAll('/api', '');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        gradient: const LinearGradient(colors: [AppTheme.orange400, AppTheme.orange600]),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (banner.image != null)
              CachedNetworkImage(
                imageUrl: '$baseUrl${banner.image}',
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(),
                errorWidget: (_, __, ___) => const SizedBox(),
              ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (banner.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (banner.ctaText != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.roundedMd,
                      ),
                      child: Text(
                        banner.ctaText!,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.orange600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant r) {
    final baseUrl = ApiClient.baseUrl.replaceAll('/api', '');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: () => Navigator.push(context, PageRouteBuilder(
            pageBuilder: (_, __, ___) => RestaurantDetailScreen(restaurant: r),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          )),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Row(
              children: [
                // Restaurant Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: AppTheme.roundedMd,
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: ClipRRect(
                    borderRadius: AppTheme.roundedMd,
                    child: r.logo != null
                        ? CachedNetworkImage(
                            imageUrl: '$baseUrl${r.logo}',
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppTheme.orange50, child: const Icon(Icons.restaurant, color: AppTheme.orange300)),
                            errorWidget: (_, __, ___) => Container(color: AppTheme.orange50, child: const Icon(Icons.restaurant, color: AppTheme.orange300)),
                          )
                        : Container(color: AppTheme.orange50, child: const Icon(Icons.restaurant, color: AppTheme.orange300)),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.name,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (r.isTrendy)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: const Text(
                                '🔥',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (r.address != null)
                        Text(
                          r.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (r.averageRating != null) ...[
                            StarRating(rating: r.averageRating!, size: 14, showText: true),
                            const SizedBox(width: 8),
                          ],
                          if (r.isTrendy)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.orange50,
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: const Text(
                                'Trendy',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.orange600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppTheme.gray300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
