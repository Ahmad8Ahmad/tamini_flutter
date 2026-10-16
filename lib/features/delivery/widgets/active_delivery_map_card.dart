import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import 'delivery_route_row.dart';

class ActiveDeliveryMapCard extends StatelessWidget {
  const ActiveDeliveryMapCard({
    super.key,
    required this.delivery,
    required this.onOpenMaps,
  });

  final Delivery delivery;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final d = delivery;
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                loc.activeDelivery,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  loc.deliveryStatusText(d.status),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            d.restaurantName,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          DeliveryRouteRow(
            icon: Icons.location_on_outlined,
            color: Colors.white70,
            label: loc.toLabel,
            value: d.deliveryAddress ?? '\u2014',
            labelColor: Colors.white60,
            valueColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${formatThousands(d.calculatedFee ?? 0)} SYP',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: Text(loc.openInMaps),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // theme-guardrail: allow
                    foregroundColor: AppTheme.orange600,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusFull,
                      ),
                    ),
                  ),
                  onPressed: onOpenMaps,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
