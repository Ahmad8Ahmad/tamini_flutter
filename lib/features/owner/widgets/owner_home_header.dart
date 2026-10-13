import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// Greeting banner shown above the owner's restaurant list.
class OwnerHomeHeader extends StatelessWidget {
  const OwnerHomeHeader({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceLg,
        AppTheme.spaceMd,
        AppTheme.spaceLg,
        AppTheme.spaceLg,
      ),
      color: context.colors.subtleFill,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.tint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppTheme.orange500,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.welcomeBackHello,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.username ?? user?.email ?? '',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.tint,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              loc.restaurantOwner,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.orange600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
