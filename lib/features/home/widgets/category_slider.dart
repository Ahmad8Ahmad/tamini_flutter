import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

class CategorySlider extends StatelessWidget {
  const CategorySlider({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    final cats = categories;
    if (cats.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 116,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        itemBuilder: (ctx, i) {
          final cat = cats[i];
          final selected = selectedCategoryId == cat.id;
          return GestureDetector(
            onTap: () => onSelect(selected ? null : cat.id),
            child: Container(
              width: 92,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? context.colors.tint : context.colors.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: selected
                      ? AppTheme.orange500
                      : context.colors.borderLight,
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
                                color: context.colors.tint,
                                child: const Icon(
                                  Icons.restaurant,
                                  color: AppTheme.orange300,
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: context.colors.tint,
                                child: const Icon(
                                  Icons.restaurant,
                                  color: AppTheme.orange300,
                                ),
                              ),
                            )
                          : Container(
                              color: context.colors.tint,
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
                          : context.colors.textPrimary,
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
}
