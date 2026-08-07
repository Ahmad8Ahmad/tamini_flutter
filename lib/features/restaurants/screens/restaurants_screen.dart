import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/tamini_shimmer.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/dashboard_button.dart';
import '../../restaurant/screens/restaurant_detail_screen.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});
  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.restaurants,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [DashboardButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: (v) => provider.loadHome(),
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14),
              decoration: InputDecoration(
                hintText: loc.searchRestaurants,
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
          Expanded(
            child: _buildBody(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(RestaurantProvider provider) {
    final loc = AppLocalizations.of(context);
    if (provider.loading && provider.restaurants.isEmpty) {
      return TaminiShimmer.list(count: 5);
    }
    if (provider.restaurants.isEmpty) {
      return TaminiEmptyState(
        icon: Icons.store_outlined,
        title: loc.noRestaurants,
        subtitle: loc.trySearchingForFood,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: provider.restaurants.length,
      itemBuilder: (ctx, i) => _buildRestaurantCard(provider.restaurants[i]),
    );
  }

  Widget _buildRestaurantCard(Restaurant r) {
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
            pageBuilder: (_, _, _) => RestaurantDetailScreen(restaurant: r),
            transitionsBuilder: (_, anim, _, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          )),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Row(
              children: [
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
                            imageUrl: r.logo!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(color: AppTheme.orange50, child: const Icon(Icons.restaurant, color: AppTheme.orange300)),
                            errorWidget: (_, _, _) => Container(color: AppTheme.orange50, child: const Icon(Icons.restaurant, color: AppTheme.orange300)),
                          )
                        : Container(color: AppTheme.orange50, child: const Icon(Icons.restaurant, color: AppTheme.orange300)),
                  ),
                ),
                const SizedBox(width: 14),
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
                              child: const Icon(
                                Icons.local_fire_department,
                                size: 12,
                                color: Colors.white,
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
                              child: Text(
                                AppLocalizations.of(context).trendy,
                                style: const TextStyle(
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
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: AppTheme.gray300,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
