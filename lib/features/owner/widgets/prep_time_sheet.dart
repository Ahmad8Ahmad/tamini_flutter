import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tamini_button.dart';

/// Shows the preparation-time picker and returns the chosen number of minutes,
/// `-1` when the owner chose "confirm without estimate", or null when the
/// sheet was dismissed without deciding.
Future<int?> showPrepTimeSheet(
  BuildContext context, {
  DateTime? initial,
}) {
  final remaining = initial?.difference(DateTime.now());
  final initialMinutes = remaining != null && remaining.inMinutes > 0
      ? remaining.inMinutes
      : 20;
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
    ),
    builder: (_) => _PrepTimeSheet(initialMinutes: initialMinutes),
  );
}

class _PrepTimeSheet extends StatefulWidget {
  const _PrepTimeSheet({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_PrepTimeSheet> createState() => _PrepTimeSheetState();
}

class _PrepTimeSheetState extends State<_PrepTimeSheet> {
  static const _presets = [15, 20, 30, 45];

  late int _minutes = widget.initialMinutes;
  final _customController = TextEditingController();
  String? _customError;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _applyCustom(String raw) {
    final value = int.tryParse(raw.trim());
    if (value == null || value < 1 || value > 480) {
      setState(() => _customError = '1–480');
      return;
    }
    setState(() {
      _minutes = value;
      _customError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        AppTheme.spaceMd + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.prepTimeTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.prepTimeHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Wrap(
            spacing: AppTheme.spaceSm,
            runSpacing: AppTheme.spaceSm,
            alignment: WrapAlignment.center,
            children: [
              for (final preset in _presets)
                ChoiceChip(
                  label: Text(
                    '$preset ${loc.minutesUnit}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  selected: _minutes == preset && _customError == null,
                  onSelected: (_) => setState(() {
                    _minutes = preset;
                    _customController.clear();
                    _customError = null;
                  }),
                  selectedColor: context.colors.tint,
                  labelStyle: TextStyle(
                    color: _minutes == preset && _customError == null
                        ? AppTheme.orange600
                        : context.colors.textSecondary,
                  ),
                  side: BorderSide(
                    color: _minutes == preset && _customError == null
                        ? AppTheme.orange400
                        : context.colors.borderLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          TextField(
            controller: _customController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: _applyCustom,
            onChanged: _applyCustom,
            decoration: InputDecoration(
              labelText: '${loc.prepTimeTitle} (${loc.minutesUnit})',
              errorText: _customError,
              border: OutlineInputBorder(
                borderRadius: AppTheme.roundedMd,
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          TaminiButton(
            text: loc.confirm,
            onPressed: () => Navigator.of(context).pop(_minutes),
          ),
          TaminiButton(
            text: loc.confirmWithoutTime,
            style: TaminiButtonStyle.ghost,
            compact: true,
            // Sentinel the caller distinguishes from a dismissed sheet.
            onPressed: () => Navigator.of(context).pop(-1),
          ),
        ],
      ),
    );
  }
}
