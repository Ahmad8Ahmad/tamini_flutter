import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

import '../api/api_client.dart';
import '../models/models.dart';

class SupportProvider extends ChangeNotifier {
  final ApiClient _api;
  bool _loading = false;
  String? _error;
  SiteSettings? _siteSettings;

  SupportProvider(this._api);

  bool get loading => _loading;
  String? get error => _error;
  SiteSettings? get siteSettings => _siteSettings;

  Future<bool> submitTicket({
    required String name,
    required String email,
    String? phone,
    required String subject,
    required String description,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.post(
        '/support-tickets/',
        body: {
          'customer_name': name,
          'customer_email': email,
          if (phone != null && phone.isNotEmpty) 'customer_phone': phone,
          'subject': subject,
          'description': description,
        },
      );
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchSiteSettings() async {
    try {
      final data = await _api.get(
        '/site-settings/',
        cacheTtl: const Duration(seconds: 60),
      );
      _siteSettings = SiteSettings.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('SupportProvider.fetchSiteSettings: $e');
    }
  }

  List<SupportTicket> _tickets = [];
  bool _ticketsLoading = false;
  String? _ticketsError;

  List<SupportTicket> get tickets => _tickets;
  bool get ticketsLoading => _ticketsLoading;
  String? get ticketsError => _ticketsError;

  /// The signed-in user's own tickets (the API scopes them by customer).
  Future<void> fetchTickets() async {
    _ticketsLoading = true;
    _ticketsError = null;
    notifyListeners();
    try {
      final data = await _api.get('/support-tickets/');
      final raw = data['results'] ?? data;
      _tickets = [
        for (final item in raw as List) SupportTicket.fromJson(item),
      ];
    } catch (e) {
      _ticketsError = e is ApiException ? e.message : e.toString();
      debugPrint('SupportProvider.fetchTickets: $e');
    }
    _ticketsLoading = false;
    notifyListeners();
  }

  /// Clears the signed-in user's tickets on session end. Site settings are
  /// global content, not account data, so they are kept.
  void reset() {
    _tickets = [];
    _ticketsLoading = false;
    _ticketsError = null;
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
