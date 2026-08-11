import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_bottom_nav.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/tamini_shimmer.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/language_selector.dart';

import '../../restaurants/screens/restaurants_screen.dart';
import '../../restaurant/screens/restaurant_detail_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../auth/screens/pending_approval_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int? _selectedCategoryId;
  final _searchController = TextEditingController();
  final _pageController = PageController();
  int _currentBanner = 0;

  void _selectCategory(int? id) {
    setState(() {
      _selectedCategoryId = id;
      if (id != null) _searchController.clear();
    });
    context.read<RestaurantProvider>().loadFeaturedItems(categoryId: id);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rp = context.read<RestaurantProvider>();
      rp.loadHome();
      rp.loadFeaturedItems();
    });
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
          SizedBox(
            key: const ValueKey('restaurants'),
            child: const RestaurantsScreen(),
          ),
          SizedBox(key: const ValueKey('cart'), child: const CartScreen()),
          SizedBox(key: const ValueKey('orders'), child: const OrdersScreen()),
          SizedBox(
            key: const ValueKey('profile'),
            child: ProfileScreen(user: auth.user),
          ),
        ],
      ),
      bottomNavigationBar: TaminiBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == _currentIndex) return;
          setState(() => _currentIndex = i);
          if (i == 0) context.read<RestaurantProvider>().loadFeaturedItems();
        },
        cartCount: cart.itemCount,
      ),
    );
  }

  Widget _buildHomeTab() {
    final provider = context.watch<RestaurantProvider>();
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);
    final content = provider.siteContent;
    final rawWelcomeTitle = content?.welcomeTitle;
    final welcomeTitle = loc.backendText(
      (rawWelcomeTitle == null || rawWelcomeTitle.isEmpty)
          ? 'أهلاً بك في طعميني'
          : rawWelcomeTitle,
    );
    final welcomeTitleColor =
        content?.welcomeTitleColor ?? AppTheme.textPrimary;
    final welcomeTitleSize = content?.welcomeTitleSize ?? 18;
    final rawWelcomeSubtitle = content?.welcomeSubtitle;
    final welcomeSubtitle = loc.backendText(
      (rawWelcomeSubtitle == null || rawWelcomeSubtitle.isEmpty)
          ? 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُلُوا مِن طَيِّبَاتِ مَا رَزَقْنَاكُمْ وَاشْكُرُوا لِلَّهِ إِن كُنتُمْ إِيَّاهُ تَعْبُدُونَ'
          : rawWelcomeSubtitle,
    );
    final welcomeSubtitleColor =
        content?.welcomeSubtitleColor ?? AppTheme.textSecondary;
    final welcomeSubtitleSize = content?.welcomeSubtitleSize ?? 12;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: const [LanguageSelector()],
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
                    hintStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppTheme.gray400,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.orange400,
                      size: 20,
                    ),
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

        if (auth.user?.role == 'restaurant' || auth.user?.role == 'delivery')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                clipBehavior: Clip.antiAlias,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.orange400.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -26,
                        left: -26,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -34,
                        right: 30,
                        child: Container(
                          width: 116,
                          height: 116,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -40,
                        right: -10,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => buildRoleDestination(auth.user),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusLg,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.dashboard_customize_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.myDashboard,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      loc.dashboardSubtitle,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Directionality.of(context) ==
                                          TextDirection.rtl
                                      ? Icons.arrow_back
                                      : Icons.arrow_forward,
                                  color: AppTheme.orange500,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
              child: _buildCategorySlider(),
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
                    itemBuilder: (ctx, i) =>
                        _buildTrendyCard(provider.trendyRestaurants[i]),
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
                (ctx, i) => _buildMealCard(provider.featuredItems[i]),
                childCount: provider.featuredItems.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildCategorySlider() {
    final provider = context.watch<RestaurantProvider>();
    final cats = provider.categories;
    if (cats.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 116,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        itemBuilder: (ctx, i) {
          final cat = cats[i];
          final selected = _selectedCategoryId == cat.id;
          return GestureDetector(
            onTap: () => _selectCategory(selected ? null : cat.id),
            child: Container(
              width: 92,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.orange50 : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: selected ? AppTheme.orange500 : AppTheme.borderLight,
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected ? null : AppTheme.shadowSm,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: cat.image != null
                          ? CachedNetworkImage(
                              imageUrl: cat.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (_, _) => Container(
                                color: AppTheme.orange50,
                                child: const Icon(
                                  Icons.restaurant,
                                  color: AppTheme.orange300,
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: AppTheme.orange50,
                                child: const Icon(
                                  Icons.restaurant,
                                  color: AppTheme.orange300,
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.orange50,
                              child: const Icon(
                                Icons.restaurant,
                                color: AppTheme.orange500,
                                size: 26,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppTheme.orange600
                          : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendyCard(Restaurant r) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => RestaurantDetailScreen(restaurant: r),
          transitionsBuilder: (_, anim, _, child) => SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: child,
          ),
        ),
      ),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.shadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: r.coverImage != null
                  ? CachedNetworkImage(
                      imageUrl: r.coverImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, _) => Container(
                        color: AppTheme.gray100,
                        child: const Icon(Icons.store, color: AppTheme.gray300),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppTheme.gray100,
                        child: const Icon(Icons.store, color: AppTheme.gray300),
                      ),
                    )
                  : Container(
                      color: AppTheme.gray100,
                      child: const Icon(
                        Icons.store,
                        color: AppTheme.gray300,
                        size: 32,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppTheme.orange500,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: r.logo != null
                        ? CachedNetworkImage(
                            imageUrl: r.logo!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, _) =>
                                Container(color: AppTheme.orange500),
                            errorWidget: (_, _, _) =>
                                Container(color: AppTheme.orange500),
                          )
                        : Center(
                            child: Text(
                              r.name.isNotEmpty ? r.name[0] : '؟',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (r.averageRating ?? 0).toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: AppTheme.gray400,
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLg),
                  ),
                  child: item.image != null
                      ? CachedNetworkImage(
                          imageUrl: item.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, _) => Container(
                            color: AppTheme.orange50,
                            child: const Icon(
                              Icons.fastfood,
                              color: AppTheme.orange300,
                            ),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: AppTheme.orange50,
                            child: const Icon(
                              Icons.fastfood,
                              color: AppTheme.orange300,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.orange50,
                          child: const Icon(
                            Icons.fastfood,
                            color: AppTheme.orange300,
                            size: 32,
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.restaurantName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.discountPrice != null) ...[
                          Text(
                            '${item.discountPrice!.toStringAsFixed(0)} SYP',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.orange600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price.toStringAsFixed(0)} SYP',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray400,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else
                          Text(
                            '${item.price.toStringAsFixed(0)} SYP',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.orange600,
                            ),
                          ),
                        const Spacer(),
                        Consumer<CartProvider>(
                          builder: (_, cart, _) => GestureDetector(
                            onTap: () async {
                              if (!context.read<AuthProvider>().isLoggedIn) {
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                }
                                return;
                              }
                              final ok = await cart.addItem(item.id);
                              if (!mounted) return;
                              final loc = AppLocalizations.of(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok ? loc.addedToCart : loc.addToCartFailed,
                                  ),
                                  backgroundColor: ok
                                      ? AppTheme.success
                                      : AppTheme.danger,
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppTheme.roundedLg,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
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
    final hasCta = banner.ctaUrl != null && banner.ctaUrl!.isNotEmpty;
    final loc = AppLocalizations.of(context);
    final bannerTitle = loc.backendText(banner.title);
    final bannerSubtitle = loc.backendText(banner.subtitle);
    final bannerCtaText = loc.backendText(banner.ctaText);

    final bannerWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        gradient: const LinearGradient(
          colors: [AppTheme.orange400, AppTheme.orange600],
        ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      bannerTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (bannerSubtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        bannerSubtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (bannerCtaText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bannerCtaText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.orange600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.arrow_back
                                  : Icons.arrow_forward,
                              size: 14,
                              color: AppTheme.orange600,
                            ),
                          ],
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

    if (!hasCta) return bannerWidget;
    return GestureDetector(
      onTap: () => _handleBannerCta(banner),
      child: bannerWidget,
    );
  }

  Future<void> _handleBannerCta(HeroBanner banner) async {
    final url = banner.ctaUrl?.trim().toLowerCase() ?? '';
    if (url.contains('register') ||
        url.contains('signup') ||
        url.contains('sign-up')) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
      return;
    }
    if (url.contains('login') ||
        url.contains('signin') ||
        url.contains('sign-in')) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    if (banner.ctaUrl != null && banner.ctaUrl!.isNotEmpty) {
      final uri = Uri.parse(banner.ctaUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
