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
    final colors = _colors;
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

  _StatusColors get _colors {
    switch (status) {
      case BadgeStatus.pending:
        return _StatusColors(AppTheme.orange600, AppTheme.orange50);
      case BadgeStatus.confirmed:
        return _StatusColors(AppTheme.info, AppTheme.infoBg);
      case BadgeStatus.preparing:
        return _StatusColors(const Color(0xFF8B5CF6), const Color(0xFFEDE9FE));
      case BadgeStatus.outForDelivery:
        return _StatusColors(AppTheme.success, AppTheme.successBg);
      case BadgeStatus.delivered:
        return _StatusColors(const Color(0xFF15803D), const Color(0xFFDCFCE7));
      case BadgeStatus.cancelled:
        return _StatusColors(AppTheme.danger, AppTheme.dangerBg);
      case BadgeStatus.info:
        return _StatusColors(AppTheme.gray500, AppTheme.gray100);
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
