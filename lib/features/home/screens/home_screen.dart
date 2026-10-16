import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_bottom_nav.dart';
import '../../../core/widgets/lazy_indexed_stack.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/tamini_shimmer.dart';
import '../../../core/widgets/section_header.dart';

import '../../restaurants/screens/restaurants_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../controllers/home_controller.dart';
import '../widgets/category_slider.dart';
import '../widgets/featured_meal_card.dart';
import '../widgets/hero_banner_card.dart';
import '../widgets/home_dashboard_banner.dart';
import '../widgets/trendy_restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int? _selectedCategoryId;
  final _searchController = TextEditingController();
  final _pageController = PageController();
  int _currentBanner = 0;
  late final HomeController _controller;

  void _selectCategory(int? id) {
    setState(() {
      _selectedCategoryId = id;
      if (id != null) _searchController.clear();
    });
    context.read<CatalogProvider>().loadFeaturedItems(categoryId: id);
  }

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      context.read<CartProvider>(),
      context.read<AuthProvider>(),
    );
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rp = context.read<CatalogProvider>();
      rp.loadHome();
      rp.loadFeaturedItems();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // No forceRefresh here: the provider keeps a 60s freshness window, so a
    // quick background/foreground cycle is a no-op and only genuinely stale
    // data triggers a re-fetch. Force-refreshing on every resume would send a
    // burst of parallel HTTP calls to a server that may be cold/slow.
    if (state == AppLifecycleState.resumed && mounted) {
      final rp = context.read<CatalogProvider>();
      rp.loadHome();
      rp.loadFeaturedItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LazyIndexedStack(
        index: _currentIndex,
        children: [
          SizedBox(key: const ValueKey('home'), child: _buildHomeTab()),
          const SizedBox(
            key: ValueKey('restaurants'),
            child: RestaurantsScreen(),
          ),
          const SizedBox(key: ValueKey('cart'), child: CartScreen()),
          const SizedBox(key: ValueKey('orders'), child: OrdersScreen()),
          const SizedBox(key: ValueKey('profile'), child: ProfileScreen()),
        ],
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (_, cart, _) => TaminiBottomNav(
          currentIndex: _currentIndex,
          onTap: (i) {
            if (i == _currentIndex) return;
            setState(() => _currentIndex = i);
          },
          cartCount: cart.itemCount,
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final provider = context.watch<CatalogProvider>();
    final loc = AppLocalizations.of(context);
    final content = provider.siteContent;
    final rawWelcomeTitle = content?.welcomeTitle;
    final welcomeTitle = loc.backendText(
      (rawWelcomeTitle == null || rawWelcomeTitle.isEmpty)
          ? 'أهلاً بك في طعميني'
          : rawWelcomeTitle,
    );
    final welcomeTitleColor =
        content?.welcomeTitleColor ?? context.colors.textPrimary;
    final welcomeTitleSize = content?.welcomeTitleSize ?? 18;
    final rawWelcomeSubtitle = content?.welcomeSubtitle;
    final welcomeSubtitle = loc.backendText(
      (rawWelcomeSubtitle == null || rawWelcomeSubtitle.isEmpty)
          ? 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُلُوا مِن طَيِّبَاتِ مَا رَزَقْنَاكُمْ وَاشْكُرُوا لِلَّهِ إِن كُنتُمْ إِيَّاهُ تَعْبُدُونَ'
          : rawWelcomeSubtitle,
    );
    final welcomeSubtitleColor =
        content?.welcomeSubtitleColor ?? context.colors.textSecondary;
    final welcomeSubtitleSize = content?.welcomeSubtitleSize ?? 12;

    return RefreshIndicator(
      onRefresh: _refreshHome,
      color: AppTheme.orange500,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        SliverAppBar(
          floating: true,
          elevation: 0,
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  welcomeTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: welcomeTitleSize,
                    fontWeight: FontWeight.w800,
                    color: welcomeTitleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: welcomeSubtitleSize,
                      height: 1.7,
                      color: welcomeSubtitleColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  onSubmitted: (v) {
                    setState(() => _selectedCategoryId = null);
                    provider.loadFeaturedItems(search: v);
                  },
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: loc.searchFood,
                    hintStyle: TextStyle(
                      fontFamily: 'Cairo',
                      color: context.colors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.orange400,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: context.colors.isDark
                        ? context.colors.tint
                        : AppTheme.orange50.withValues(alpha: 0.6),
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
                      borderSide: const BorderSide(
                        color: AppTheme.orange400,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Consumer<AuthProvider>(
            builder: (_, auth, _) {
              final showBanner = auth.user?.role == 'restaurant' ||
                  auth.user?.role == 'delivery';
              if (!showBanner) return const SizedBox.shrink();
              return HomeDashboardBanner(user: auth.user);
            },
          ),
        ),

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
                    itemBuilder: (ctx, i) =>
                        HeroBannerCard(banner: provider.banners[i]),
                  ),
                ),
                const SizedBox(height: 10),
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
                        color: _currentBanner == i
                            ? AppTheme.orange500
                            : AppTheme.orange200,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (provider.categories.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CategorySlider(
                categories: provider.categories,
                selectedCategoryId: _selectedCategoryId,
                onSelect: _selectCategory,
              ),
            ),
          ),

        if (provider.trendyRestaurants.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: loc.trendyRestaurants, actionText: null),
                SizedBox(
                  height: 168,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceMd,
                    ),
                    itemCount: provider.trendyRestaurants.length,
                    itemBuilder: (ctx, i) => TrendyRestaurantCard(
                      restaurant: provider.trendyRestaurants[i],
                    ),
                  ),
                ),
              ],
            ),
          ),

        SliverToBoxAdapter(
          child: SectionHeader(title: loc.meals, actionText: null),
        ),

        if (provider.featuredItems.isEmpty &&
            (_searchController.text.isNotEmpty || _selectedCategoryId != null))
          SliverToBoxAdapter(
            child: TaminiEmptyState(
              icon: Icons.search_off,
              title: loc.noMealsFound,
              subtitle: loc.tryDifferentSearch,
            ),
          )
        else if (provider.featuredItems.isEmpty)
          SliverToBoxAdapter(child: TaminiShimmer.list(count: 5))
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => FeaturedMealCard(
                  item: provider.featuredItems[i],
                  onAdd: () => _addToCart(provider.featuredItems[i]),
                ),
                childCount: provider.featuredItems.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
      ),
    );
  }

  Future<void> _refreshHome() async {
    final rp = context.read<CatalogProvider>();
    await rp.loadHome(forceRefresh: true);
    await rp.loadFeaturedItems(forceRefresh: true);
  }

  Future<void> _addToCart(MenuItem item) async {
    final result = await _controller.addToCart(item.id);
    if (!mounted) return;
    if (result == AddToCartResult.needsAuth) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    final loc = AppLocalizations.of(context);
    final ok = result == AddToCartResult.added;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.addedToCart : loc.addToCartFailed),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
