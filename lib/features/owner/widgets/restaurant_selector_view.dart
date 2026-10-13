import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/owner_provider.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/owner_home_header.dart';
import '../widgets/restaurant_card.dart';

/// The owner's "pick a restaurant" landing view: greeting header followed by
/// the list of owned restaurants with loading/error/empty states.
class RestaurantSelectorView extends StatelessWidget {
  const RestaurantSelectorView({
    super.key,
    required this.user,
    required this.onSelect,
    required this.onToggleActive,
  });

  final User? user;
  final ValueChanged<Restaurant> onSelect;
  final ValueChanged<Restaurant> onToggleActive;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final owner = context.watch<OwnerProvider>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: OwnerHomeHeader(user: user)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceLg,
              AppTheme.spaceLg,
              AppTheme.spaceLg,
              AppTheme.spaceSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.myRestaurants,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.orange600,
                  ),
                ),
                if (owner.myRestaurants.isNotEmpty)
                  Text(
                    '${owner.myRestaurants.length}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.orange500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (owner.myRestaurantsLoading && owner.myRestaurants.isEmpty)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppTheme.orange500),
              ),
            ),
          )
        else if (owner.myRestaurantsError != null && owner.myRestaurants.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.errorOccurred,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    owner.myRestaurantsError!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: context.colors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _RetryButton(
                    onPressed: () =>
                        owner.loadMyRestaurants(forceRefresh: true),
                  ),
                ],
              ),
            ),
          )
        else if (owner.myRestaurants.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: AppTheme.gray300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.noRestaurants,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.noRestaurantLinked,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: context.colors.textMuted,
                    ),
                  ),
                  if (owner.myRestaurantsRawResponse != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.subtleFill,
                        borderRadius: AppTheme.roundedLg,
                      ),
                      child: Text(
                        'API response: ${owner.myRestaurantsRawResponse}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _RetryButton(
                    onPressed: () =>
                        owner.loadMyRestaurants(forceRefresh: true),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final restaurant = owner.myRestaurants[i];
                return RestaurantCard(
                  restaurant: restaurant,
                  onSelect: () => onSelect(restaurant),
                  onToggleActive: () => onToggleActive(restaurant),
                );
              },
              childCount: owner.myRestaurants.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh, size: 18),
      label: Text(
        loc.retry,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.orange500,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
      ),
    );
  }
}
