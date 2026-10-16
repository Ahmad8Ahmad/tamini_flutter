import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/utils/formatters.dart';

class OwnerMealCard extends StatelessWidget {
  const OwnerMealCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
    required this.isToggling,
  });

  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleAvailability;
  final bool isToggling;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: context.colors.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: AppTheme.roundedLg,
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceSm,
                AppTheme.spaceSm,
                AppTheme.spaceSm,
                AppTheme.spaceXs,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: AppTheme.roundedMd,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: item.image != null
                          ? CachedNetworkImage(
                              imageUrl: item.image!,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => const Icon(
                                Icons.restaurant_menu,
                                color: AppTheme.orange300,
                              ),
                            )
                          : const Icon(
                              Icons.restaurant_menu,
                              color: AppTheme.orange300,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: context.colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!item.isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.subtleFill,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  loc.notAvailable,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.categoryName,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (item.discountPrice != null) ...[
                              Text(
                                formatPrice(item.discountPrice!),
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.orange600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formatPrice(item.price),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: context.colors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: AppTheme.orange500,
                              ),
                            ] else
                              Text(
                                formatPrice(item.price),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.danger,
                      size: 20,
                    ),
                    tooltip: loc.deleteMeal,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceSm,
              0,
              AppTheme.spaceSm,
              AppTheme.spaceSm,
            ),
            child: Row(
              children: [
                if (isToggling)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.orange500,
                    ),
                  )
                else
                  Switch(
                    value: item.isAvailable,
                    activeTrackColor: AppTheme.orange400,
                    onChanged: onToggleAvailability,
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.isAvailable ? loc.availableForOrder : loc.notAvailable,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: item.isAvailable
                          ? AppTheme.success
                          : context.colors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  item.isAvailable ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                  color: item.isAvailable ? AppTheme.success : AppTheme.gray300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
