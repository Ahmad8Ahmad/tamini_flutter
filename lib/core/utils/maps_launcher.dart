import 'package:url_launcher/url_launcher.dart';

/// Builds a Google Maps "search" deep link.
///
/// Coordinates win over [query] so a precise pin is preferred over an address
/// the geocoder might resolve somewhere else. When neither is provided the
/// link still opens (Google shows the user's current location).
Uri googleMapsSearchUri({double? lat, double? lng, String? query}) {
  if (lat != null && lng != null) {
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
  }
  return Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query ?? '')}',
  );
}

/// Opens [lat]/[lng] (or [query] as free text) in the external Google Maps
/// app, falling back to the browser when no maps app is registered.
Future<void> openInGoogleMaps({double? lat, double? lng, String? query}) async {
  final uri = googleMapsSearchUri(lat: lat, lng: lng, query: query);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Opens the phone dialer for [phone], stripping formatting characters but
/// keeping `+` for international numbers.
Future<void> dialNumber(String phone) async {
  final uri = Uri(
    scheme: 'tel',
    path: phone.replaceAll(RegExp(r'[^0-9+]'), ''),
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
