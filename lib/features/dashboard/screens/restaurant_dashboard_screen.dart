import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/api/api_client.dart';
import '../../auth/screens/login_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});
  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantProvider>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<RestaurantProvider>();
    final loc = AppLocalizations.of(context);
    final baseUrl = ApiClient.baseUrl.replaceAll('/api', '');
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appName, style: const TextStyle(fontFamily: 'Lalezar', fontSize: 22)),
        backgroundColor: AppTheme.orange500,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    loc.isArabic ? 'مرحباً بك' : 'Welcome',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.username ?? user?.email ?? '',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      loc.isArabic ? 'صاحب مطعم' : 'Restaurant Owner',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceLg, AppTheme.spaceLg, AppTheme.spaceMd),
              child: Text(
                loc.isArabic ? 'مطاعمي' : 'My Restaurants',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
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
                (ctx, i) => _buildRestaurantCard(provider.restaurants[i], baseUrl, loc),
                childCount: provider.restaurants.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant r, String baseUrl, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceSm),
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
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    color: AppTheme.orange50,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: r.logo != null
                        ? CachedNetworkImage(
                            imageUrl: r.logo!.startsWith('http') ? r.logo! : '$baseUrl${r.logo}',
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(Icons.restaurant, color: AppTheme.orange300),
                          )
                        : const Icon(Icons.restaurant, color: AppTheme.orange300),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textPrimary)),
                      if (r.address != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(r.address!, style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.gray300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
