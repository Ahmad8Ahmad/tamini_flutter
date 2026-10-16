import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../screens/delivery_detail_screen.dart';
import 'delivery_route_row.dart';

class MyDeliveryCard extends StatelessWidget {
  const MyDeliveryCard({
    super.key,
    required this.delivery,
    required this.isActive,
    required this.onOpenMaps,
    required this.onComplete,
    required this.isCompleting,
  });

  final Delivery delivery;
  final bool isActive;
  final VoidCallback onOpenMaps;
  final VoidCallback onComplete;
  final bool isCompleting;

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
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: (isActive
                            ? context.colors.warningBg
                            : context.colors.successBg)
                        .withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    loc.deliveryStatusText(d.status),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isActive ? AppTheme.warning : AppTheme.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
            if (isActive) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${formatThousands(d.calculatedFee ?? 0)} SYP',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.orange600,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: Text(
                      loc.openInMaps,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.info,
                      side: BorderSide(color: context.colors.infoBg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: onOpenMaps,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                    ),
                    onPressed: isCompleting ? null : onComplete,
                    child: isCompleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(loc.completeDelivery),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
