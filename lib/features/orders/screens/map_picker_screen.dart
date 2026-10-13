import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tamini_button.dart';

/// Full-screen map used by checkout to capture the customer's delivery
/// coordinates. The picked [LatLng] is returned to the caller so the delivery
/// fee can be quoted with the real distance instead of the flat fallback.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    required this.initialCenter,
    this.initialPoint,
  });

  final LatLng initialCenter;
  final LatLng? initialPoint;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _mapController = MapController();
  LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPoint;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.setLocationOnMap,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selected ?? widget.initialCenter,
              initialZoom: 15,
              onTap: (_, point) => setState(() => _selected = point),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tamini.app',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_pin,
                        color: AppTheme.orange600,
                        size: 44,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: AppTheme.spaceMd,
            left: AppTheme.spaceMd,
            right: AppTheme.spaceMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: AppTheme.roundedLg,
                border: Border.all(color: context.colors.borderLight),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app_outlined,
                    color: AppTheme.orange500,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.tapMapToSelectLocation,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppTheme.spaceMd,
            right: AppTheme.spaceMd,
            bottom: AppTheme.spaceLg,
            child: TaminiButton(
              text: loc.confirm,
              icon: Icons.check_circle_outline,
              onPressed: _selected == null
                  ? null
                  : () => Navigator.of(context).pop(_selected),
            ),
          ),
        ],
      ),
    );
  }
}
