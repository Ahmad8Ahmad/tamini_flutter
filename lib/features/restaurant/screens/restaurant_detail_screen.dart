import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/tamini_shimmer.dart';
import '../../../core/widgets/discount_badge.dart';

import '../../../core/widgets/star_rating.dart';
import '../../cart/screens/cart_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantDetailScreen({super.key, required this.restaurant});
  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantProvider>().loadMenuItems(restaurantId: widget.restaurant.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final cart = context.watch<CartProvider>();
    final loc = AppLocalizations.of(context);
    final baseUrl = ApiClient.baseUrl.replaceAll('/api', '');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Cover Image SliverAppBar ─────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.restaurant.name,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.restaurant.coverImage != null)
                    CachedNetworkImage(
                      imageUrl: '$baseUrl${widget.restaurant.coverImage}',
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: AppTheme.orange200),
                      errorWidget: (_, _, _) => _coverPlaceholder(),
                    )
                  else
                    _coverPlaceholder(),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black45],
                        stops: [0.6, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: const BoxDecoration(color: AppTheme.orange500, shape: BoxShape.circle),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── Restaurant Info ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo + Info Row
                  Row(
                    children: [
                      // Floating Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(color: AppTheme.borderLight, width: 3),
                          boxShadow: AppTheme.shadowLg,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: widget.restaurant.logo != null
                              ? CachedNetworkImage(
                                  imageUrl: '$baseUrl${widget.restaurant.logo}',
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => const Icon(Icons.restaurant, color: AppTheme.orange300),
                                )
                              : const Icon(Icons.restaurant, color: AppTheme.orange300),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.restaurant.name, style: AppTheme.headlineMedium),
                            if (widget.restaurant.averageRating != null) ...[
                              const SizedBox(height: 4),
                              StarRating(rating: widget.restaurant.averageRating!, size: 16),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.restaurant.description != null) ...[
                    const SizedBox(height: AppTheme.spaceMd),
                    Text(widget.restaurant.description!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                  ],
                  const SizedBox(height: AppTheme.spaceLg),
                  Text(loc.menu, style: AppTheme.headlineSmall),
                ],
              ),
            ),
          ),

          // ── Menu Items ───────────────────────────────────────
          if (provider.loading)
            SliverToBoxAdapter(child: TaminiShimmer.list(count: 5))
          else if (provider.menuItems.isEmpty)
            SliverToBoxAdapter(
              child: TaminiEmptyState(
                icon: Icons.fastfood_outlined,
                title: loc.isArabic ? 'القائمة فارغة' : 'Menu is empty',
                subtitle: loc.isArabic ? 'لم نتمكن من إيجاد أي عناصر' : 'No menu items available',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildMenuItem(provider.menuItems[i]),
                childCount: provider.menuItems.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    final baseUrl = ApiClient.baseUrl.replaceAll('/api', '');
    final loc = AppLocalizations.of(context);
    final hasDiscount = item.discountPrice != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Row(
          children: [
            // Image
            if (item.image != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppTheme.roundedMd,
                    child: CachedNetworkImage(
                      imageUrl: '$baseUrl${item.image}',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        width: 88,
                        height: 88,
                        color: AppTheme.orange50,
                        child: const Icon(Icons.fastfood, color: AppTheme.orange300),
                      ),
                      errorWidget: (_, _, _) => Container(
                        width: 88,
                        height: 88,
                        color: AppTheme.orange50,
                        child: const Icon(Icons.fastfood, color: AppTheme.orange300),
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: DiscountBadge(originalPrice: item.price, discountPrice: item.discountPrice!),
                    ),
                ],
              ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textPrimary)),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${item.effectivePrice.toStringAsFixed(0)} SYP', style: AppTheme.priceSmall),
                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        item.price.toStringAsFixed(0),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          decoration: TextDecoration.lineThrough,
                          color: AppTheme.gray400,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Add to Cart Button
          Consumer<CartProvider>(
            builder: (_, cart, _) => GestureDetector(
              onTap: () async {
                await cart.addItem(item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(loc.addedToCart),
                    backgroundColor: AppTheme.success,
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
                  ));
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x33F97316), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.orange300, AppTheme.orange500],
        ),
      ),
      child: const Center(child: Icon(Icons.restaurant, size: 64, color: Colors.white)),
    );
  }
}
