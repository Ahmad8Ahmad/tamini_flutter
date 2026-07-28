import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TaminiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final bool elevated;
  final VoidCallback? onTap;

  const TaminiCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.elevated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: color ?? AppTheme.card,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: elevated ? AppTheme.shadowLg : AppTheme.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLg),
        child: Material(
          color: Colors.transparent,
          child: onTap != null
              ? InkWell(onTap: onTap, child: Padding(padding: padding ?? const EdgeInsets.all(AppTheme.spaceMd), child: child))
              : Padding(padding: padding ?? const EdgeInsets.all(AppTheme.spaceMd), child: child),
        ),
      ),
    );
    return card;
  }
}
