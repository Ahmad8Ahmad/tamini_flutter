import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// Summary card for one of the owner's restaurants, with a cover image, status
/// chips, an open/closed switch and a manage affordance.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onSelect,
    required this.onToggleActive,
  });

  final Restaurant restaurant;
  final VoidCallback onSelect;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final r = restaurant;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceLg,
        vertical: AppTheme.spaceMd,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onSelect,
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
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spaceMd,
                      0,
                      AppTheme.spaceMd,
                      AppTheme.spaceSm,
                    ),
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
                                  color: context.colors.tint,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: r.logo != null
                                    ? CachedNetworkImage(
                                        imageUrl: r.logo!,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, _, _) => const Icon(
                                          Icons.restaurant,
                                          color: AppTheme.orange300,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.restaurant,
                                        color: AppTheme.orange300,
                                      ),
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
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: context.colors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (r.address != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: AppTheme.orange400,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                r.address!,
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  color: context
                                                      .colors
                                                      .textSecondary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
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
                            _StatusChip(
                              text: r.isApproved
                                  ? loc.approved
                                  : loc.restaurantNotApproved,
                              icon: r.isApproved
                                  ? Icons.verified
                                  : Icons.hourglass_top,
                              bg: r.isApproved
                                  ? context.colors.successBg
                                  : context.colors.warningBg,
                              fg: r.isApproved
                                  ? AppTheme.success
                                  : AppTheme.warning,
                            ),
                            if (r.isTrendy) ...[
                              const SizedBox(width: 8),
                              _StatusChip(
                                text: loc.trendy,
                                icon: Icons.local_fire_department,
                                bg: context.colors.tint,
                                fg: AppTheme.orange600,
                              ),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    loc.manage,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Directionality.of(context) ==
                                            TextDirection.rtl
                                        ? Icons.arrow_back
                                        : Icons.arrow_forward,
                                    size: 14,
                                    color: Colors.white,
                                  ),
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
            const Divider(
              height: 1,
              thickness: 1,
              indent: AppTheme.spaceMd,
              endIndent: AppTheme.spaceMd,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                AppTheme.spaceXs,
                AppTheme.spaceMd,
                AppTheme.spaceSm,
              ),
              child: Row(
                children: [
                  Icon(
                    r.isActive ? Icons.storefront : Icons.storefront_outlined,
                    size: 16,
                    color: r.isActive
                        ? AppTheme.success
                        : context.colors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    r.isActive ? loc.open : loc.closed,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: r.isActive
                          ? AppTheme.success
                          : context.colors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: r.isActive,
                    activeTrackColor: AppTheme.orange400,
                    onChanged: (_) => onToggleActive(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.text,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  final String text;
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
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
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
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
