import 'package:flutter/material.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../screens/delivery_detail_screen.dart';
import 'delivery_route_row.dart';

class AvailableDeliveryCard extends StatelessWidget {
  const AvailableDeliveryCard({
    super.key,
    required this.delivery,
    required this.onAccept,
    required this.onReject,
    required this.isAccepting,
  });

  final Delivery delivery;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isAccepting;

  @override
  Widget build(BuildContext context) {
    final d = delivery;
    final loc = AppLocalizations.of(context);
    final customer = [
      d.customerName,
      d.customerPhone,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' \u2022 ');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeliveryDetailScreen(delivery: d),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.restaurantName,
                        style: AppTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${loc.orderNumber}${d.orderId}',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.infoBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    '${d.distance?.toStringAsFixed(1) ?? '\u2014'} ${loc.km}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.info,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DeliveryRouteRow(
              icon: Icons.location_on_outlined,
              color: AppTheme.orange600,
              label: loc.toLabel,
              value: d.deliveryAddress ?? '\u2014',
            ),
            if (customer.isNotEmpty) ...[
              const SizedBox(height: 6),
              DeliveryRouteRow(
                icon: Icons.person_outline,
                color: context.colors.textSecondary,
                label: loc.customerLabel,
                value: customer,
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.tint,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text(
                    '${formatThousands(d.calculatedFee ?? 0)} SYP',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.orange600,
                    ),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    side: const BorderSide(color: AppTheme.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                  onPressed: onReject,
                  child: Text(
                    loc.reject,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.danger,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                  onPressed: isAccepting ? null : onAccept,
                  child: isAccepting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(loc.accept),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
