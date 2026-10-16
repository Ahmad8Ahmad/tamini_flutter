import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';

class DeliveryEmptyState extends StatelessWidget {
  const DeliveryEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.hint,
    required this.onRefresh,
  });

  final IconData icon;
  final String title;
  final String hint;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return RefreshIndicator(
      color: AppTheme.orange500,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceXl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.tint,
                      ),
                      child: Icon(
                        icon,
                        size: 46,
                        color: AppTheme.orange300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hint,
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(localizations.refresh),
                      onPressed: onRefresh,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
