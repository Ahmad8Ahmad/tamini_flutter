import 'package:flutter/foundation.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/owner_provider.dart';

/// UI state and actions for the owner home screen: which restaurant the owner
/// is currently managing and which bottom-navigation tab is active.
///
/// Keeping this out of the widget tree lets the screen stay a thin shell that
/// renders [OwnerHomeController] state and forwards user intents here.
class OwnerHomeController extends ChangeNotifier {
  OwnerHomeController(this._owner);

  final OwnerProvider _owner;

  int _currentIndex = 0;
  Restaurant? _selectedRestaurant;

  int get currentIndex => _currentIndex;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get hasSelectedRestaurant => _selectedRestaurant != null;

  Future<void> loadRestaurants() => _owner.loadMyRestaurants();

  void selectRestaurant(Restaurant restaurant) {
    _selectedRestaurant = restaurant;
    _currentIndex = 0;
    notifyListeners();
  }

  void clearRestaurant() {
    _selectedRestaurant = null;
    _currentIndex = 0;
    notifyListeners();
  }

  void selectTab(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// Flips the restaurant's open/closed state. Returns whether it was saved.
  Future<bool> toggleActive(Restaurant restaurant) async {
    final updated = await _owner.setRestaurantActive(
      id: restaurant.id,
      isActive: !restaurant.isActive,
    );
    return updated != null;
  }
}
