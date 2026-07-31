import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_bottom_nav.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/tamini_shimmer.dart';
import '../../../core/widgets/section_header.dart';

import '../../restaurants/screens/restaurants_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/screens/login_screen.dart';

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
    final rp = context.read<RestaurantProvider>();
    rp.loadHome();
    rp.loadFeaturedItems();
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
          SizedBox(key: const ValueKey('restaurants'), child: const RestaurantsScreen()),
          SizedBox(key: const ValueKey('cart'), child: const CartScreen()),
          SizedBox(key: const ValueKey('orders'), child: const OrdersScreen()),
          SizedBox(key: const ValueKey('profile'), child: ProfileScreen(user: auth.user)),
        ],
      ),
      bottomNavigationBar: TaminiBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) context.read<RestaurantProvider>().loadFeaturedItems();
        },
        cartCount: cart.itemCount,
      ),
    );
  }

  Widget _buildHomeTab() {
    final provider = context.watch<RestaurantProvider>();
    final loc = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
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
            preferredSize: const Size.fromHeight(140),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'أهلاً بك في طعميني',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'يَا أَيُّهَا الَّذِينَ آمَنُوا كُلُوا مِن طَيِّبَاتِ مَا رَزَقْنَاكُمْ وَاشْكُرُوا لِلَّهِ إِن كُنتُمْ إِيَّاهُ تَعْبُدُونَ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        height: 1.7,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onSubmitted: (v) => provider.loadFeaturedItems(search: v),
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
                ],
              ),
            ),
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
                    itemBuilder: (ctx, i) => _buildBanner(provider.banners[i]),
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
                        color: _currentBanner == i ? AppTheme.orange500 : AppTheme.orange200,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        SliverToBoxAdapter(
          child: SectionHeader(title: loc.isArabic ? 'الوجبات' : 'Meals', actionText: null),
        ),

        if (provider.featuredItems.isEmpty && _searchController.text.isNotEmpty)
          SliverToBoxAdapter(
            child: TaminiEmptyState(
              icon: Icons.search_off,
              title: loc.isArabic ? 'لا توجد وجبات' : 'No meals found',
              subtitle: loc.isArabic ? 'جرّب بحثاً آخر' : 'Try a different search',
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
                (ctx, i) => _buildMealCard(provider.featuredItems[i]),
                childCount: provider.featuredItems.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildMealCard(MenuItem item) {
    return Container(
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
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
                  child: item.image != null
                      ? CachedNetworkImage(
                          imageUrl: item.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, _) => Container(color: AppTheme.orange50, child: const Icon(Icons.fastfood, color: AppTheme.orange300)),
                          errorWidget: (_, _, _) => Container(color: AppTheme.orange50, child: const Icon(Icons.fastfood, color: AppTheme.orange300)),
                        )
                      : Container(color: AppTheme.orange50, child: const Icon(Icons.fastfood, color: AppTheme.orange300, size: 32)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.restaurantName,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.discountPrice != null) ...[
                          Text(
                            '${item.discountPrice!.toStringAsFixed(0)} SYP',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.orange600),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price.toStringAsFixed(0)} SYP',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.gray400, decoration: TextDecoration.lineThrough),
                          ),
                        ] else
                          Text(
                            '${item.price.toStringAsFixed(0)} SYP',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.orange600),
                          ),
                        const Spacer(),
                        Consumer<CartProvider>(
                          builder: (_, cart, _) => GestureDetector(
                            onTap: () async {
                              if (!context.read<AuthProvider>().isLoggedIn) {
                                if (mounted) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                }
                                return;
                              }
                              final ok = await cart.addItem(item.id);
                              if (!mounted) return;
                              final loc = AppLocalizations.of(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(ok ? loc.addedToCart : (loc.isArabic ? 'تعذر إضافة الطبق للسلة' : 'Failed to add to cart')),
                                backgroundColor: ok ? AppTheme.success : AppTheme.danger,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
                              ));
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(HeroBanner banner) {
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
                imageUrl: banner.image!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const SizedBox(),
                errorWidget: (_, _, _) => const SizedBox(),
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

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
