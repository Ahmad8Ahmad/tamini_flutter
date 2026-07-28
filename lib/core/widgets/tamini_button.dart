import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TaminiButtonStyle { primary, secondary, ghost, danger, success }

class TaminiButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TaminiButtonStyle style;
  final bool loading;
  final bool compact;
  final IconData? icon;
  final double? width;

  const TaminiButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = TaminiButtonStyle.primary,
    this.loading = false,
    this.compact = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final height = compact ? 44.0 : 52.0;
    final fontSize = compact ? 14.0 : 16.0;

    if (style == TaminiButtonStyle.ghost) {
      return TextButton(
        onPressed: loading ? null : onPressed,
        child: Text(text, style: TextStyle(fontSize: fontSize)),
      );
    }

    if (style == TaminiButtonStyle.secondary) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: _buildChild(fontSize),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _bgColor,
          foregroundColor: _fgColor,
          disabledBackgroundColor: AppTheme.gray300,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
          elevation: 0,
        ),
        child: _buildChild(fontSize),
      ),
    );
  }

  Color get _bgColor {
    switch (style) {
      case TaminiButtonStyle.primary:
        return AppTheme.orange500;
      case TaminiButtonStyle.danger:
        return AppTheme.danger;
      case TaminiButtonStyle.success:
        return AppTheme.success;
      default:
        return AppTheme.orange500;
    }
  }

  Color get _fgColor {
    switch (style) {
      case TaminiButtonStyle.primary:
        return Colors.white;
      case TaminiButtonStyle.danger:
        return Colors.white;
      case TaminiButtonStyle.success:
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  Widget _buildChild(double fontSize) {
    if (loading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: fontSize + 2),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800)),
        ],
      );
    }

    return Text(text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800));
  }
}
