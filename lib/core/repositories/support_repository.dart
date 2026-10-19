import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/json.dart';

/// Data access for support tickets and the global site settings shown across
/// the app (contact info, welcome copy, banners).
///
/// Kept behind an interface so providers can be exercised in tests with an
/// in-memory fake rather than a live HTTP client.
abstract class SupportRepository {
  Future<void> submitTicket({
    required String name,
    required String email,
    String? phone,
    required String subject,
    required String description,
  });

  Future<SiteSettings> fetchSiteSettings();

  Future<List<SupportTicket>> fetchTickets();
}

class ApiSupportRepository implements SupportRepository {
  final ApiClient _api;

  ApiSupportRepository(this._api);

  @override
  Future<void> submitTicket({
    required String name,
    required String email,
    String? phone,
    required String subject,
    required String description,
  }) {
    return _api.post(
      '/support-tickets/',
      body: {
        'customer_name': name,
        'customer_email': email,
        if (phone != null && phone.isNotEmpty) 'customer_phone': phone,
        'subject': subject,
        'description': description,
      },
    );
  }

  @override
  Future<SiteSettings> fetchSiteSettings() async {
    final data = await _api.get(
      '/site-settings/',
      cacheTtl: const Duration(seconds: 60),
    );
    return SiteSettings.fromJson(data);
  }

  @override
  Future<List<SupportTicket>> fetchTickets() async {
    final data = await _api.get('/support-tickets/');
    return extractResults(data, SupportTicket.fromJson);
  }
}
