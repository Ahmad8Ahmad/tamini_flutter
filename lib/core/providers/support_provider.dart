import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

import '../api/api_client.dart';
import '../models/models.dart';
import '../repositories/support_repository.dart';

class SupportProvider extends ChangeNotifier {
  final SupportRepository _repo;
  bool _loading = false;
  String? _error;
  SiteSettings? _siteSettings;

  SupportProvider(this._repo);

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
      await _repo.submitTicket(
        name: name,
        email: email,
        phone: phone,
        subject: subject,
        description: description,
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
      _siteSettings = await _repo.fetchSiteSettings();
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
      _tickets = await _repo.fetchTickets();
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
