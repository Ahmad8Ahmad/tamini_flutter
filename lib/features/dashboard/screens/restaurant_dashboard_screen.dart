import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../home/screens/home_screen.dart';
import 'my_restaurant_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});
  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RestaurantProvider>().loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<RestaurantProvider>();
    final loc = AppLocalizations.of(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appName, style: const TextStyle(fontFamily: 'Lalezar', fontSize: 22)),
        backgroundColor: AppTheme.orange500,
        foregroundColor: Colors.white,
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(loc, user)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceLg, AppTheme.spaceLg, AppTheme.spaceSm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.isArabic ? 'مطاعمي' : 'My Restaurants',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.orange600),
                  ),
                  if (provider.restaurants.isNotEmpty)
                    Text(
                      '${provider.restaurants.length}',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.orange500),
                    ),
                ],
              ),
            ),
          ),
          if (provider.loading && provider.restaurants.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppTheme.orange500),
                ),
              ),
            )
          else if (provider.restaurants.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.store_outlined, size: 64, color: AppTheme.gray300),
                    const SizedBox(height: 16),
                    Text(
                      loc.isArabic ? 'لا توجد مطاعم' : 'No restaurants found',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.isArabic ? 'لم يتم ربط مطعم بحسابك بعد' : 'No restaurant linked to your account',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.gray400),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildRestaurantCard(provider.restaurants[i], loc),
                childCount: provider.restaurants.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc, User? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceMd, AppTheme.spaceLg, AppTheme.spaceLg),
      color: AppTheme.gray100,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.orange50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant, color: AppTheme.orange500, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.isArabic ? 'مرحباً بك 👋' : 'Welcome back 👋',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.username ?? user?.email ?? '',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.orange50,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              loc.isArabic ? 'صاحب مطعم' : 'Restaurant Owner',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.orange600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant r, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MyRestaurantScreen(restaurant: r)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 140,
                child: r.coverImage != null
                    ? CachedNetworkImage(
                        imageUrl: r.coverImage!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const _CoverFallback(),
                        errorWidget: (_, _, _) => const _CoverFallback(),
                      )
                    : const _CoverFallback(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppTheme.spaceMd, 0, AppTheme.spaceMd, AppTheme.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -28),
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.orange50,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: r.logo != null
                                ? CachedNetworkImage(
                                    imageUrl: r.logo!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => const Icon(Icons.restaurant, color: AppTheme.orange300),
                                  )
                                : const Icon(Icons.restaurant, color: AppTheme.orange300),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (r.address != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.orange400),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            r.address!,
                                            style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _chip(
                          r.isApproved ? loc.isArabic ? 'مقبول' : 'Approved' : loc.restaurantNotApproved,
                          icon: r.isApproved ? Icons.verified : Icons.hourglass_top,
                          bg: r.isApproved ? AppTheme.successBg : AppTheme.warningBg,
                          fg: r.isApproved ? AppTheme.success : AppTheme.warning,
                        ),
                        if (r.isTrendy) ...[
                          const SizedBox(width: 8),
                          _chip(
                            loc.isArabic ? 'رائج' : 'Trendy',
                            icon: Icons.local_fire_department,
                            bg: AppTheme.orange50,
                            fg: AppTheme.orange600,
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loc.isArabic ? 'إدارة' : 'Manage',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                            ],
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

  Widget _chip(String text, {required IconData icon, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
        ],
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: const Center(
        child: Icon(Icons.restaurant, color: Colors.white54, size: 48),
      ),
    );
  }
}
