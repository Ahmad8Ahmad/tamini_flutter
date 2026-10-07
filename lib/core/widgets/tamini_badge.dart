import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeStatus { pending, confirmed, preparing, outForDelivery, delivered, cancelled, info }

class TaminiBadge extends StatelessWidget {
  final String text;
  final BadgeStatus status;
  final bool showDot;
  final bool compact;

  const TaminiBadge({
    super.key,
    required this.text,
    this.status = BadgeStatus.pending,
    this.showDot = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: compact ? 6 : 8,
              height: compact ? 6 : 8,
              decoration: BoxDecoration(
                color: colors.fg,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: colors.fg,
            ),
          ),
        ],
      ),
    );
  }

  _StatusColors _colors(BuildContext context) {
    final palette = context.colors;
    switch (status) {
      case BadgeStatus.pending:
        return _StatusColors(palette.tintText, palette.tint);
      case BadgeStatus.confirmed:
        return _StatusColors(AppTheme.info, palette.infoBg);
      case BadgeStatus.preparing:
        return palette.isDark
            ? _StatusColors(const Color(0xFFA78BFA), const Color(0x338B5CF6))
            : _StatusColors(
                const Color(0xFF8B5CF6),
                const Color(0xFFEDE9FE),
              );
      case BadgeStatus.outForDelivery:
        return _StatusColors(AppTheme.success, palette.successBg);
      case BadgeStatus.delivered:
        return palette.isDark
            ? _StatusColors(const Color(0xFF4ADE80), palette.successBg)
            : _StatusColors(const Color(0xFF15803D), const Color(0xFFDCFCE7));
      case BadgeStatus.cancelled:
        return _StatusColors(AppTheme.danger, palette.dangerBg);
      case BadgeStatus.info:
        return _StatusColors(palette.textSecondary, palette.subtleFill);
    }
  }

  static BadgeStatus fromString(String status) {
    switch (status) {
      case 'Pending': return BadgeStatus.pending;
      case 'Confirmed': return BadgeStatus.confirmed;
      case 'Preparing': return BadgeStatus.preparing;
      case 'In Progress': return BadgeStatus.preparing;
      case 'Out for Delivery': return BadgeStatus.outForDelivery;
      case 'Delivered': return BadgeStatus.delivered;
      case 'Completed': return BadgeStatus.delivered;
      case 'Cancelled': return BadgeStatus.cancelled;
      default: return BadgeStatus.info;
    }
  }
}

class _StatusColors {
  final Color fg;
  final Color bg;
  const _StatusColors(this.fg, this.bg);
}
