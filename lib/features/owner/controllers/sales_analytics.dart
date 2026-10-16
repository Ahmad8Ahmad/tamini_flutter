import '../../../core/models/models.dart';

/// Aggregations for the owner sales dashboard.
///
/// Pure functions over the order list, kept out of the widget so the
/// dashboard stays a thin renderer and the math can be reasoned about and
/// tested without a widget tree. [now] is injectable so date-bucketed results
/// are deterministic in tests.
class SalesAnalytics {
  SalesAnalytics._();

  static const Set<String> cancelledStatuses = {'Cancelled', 'Canceled'};

  static bool isCancelled(Order o) => cancelledStatuses.contains(o.status);

  static List<Order> activeOrders(List<Order> orders) =>
      orders.where((o) => !isCancelled(o)).toList();

  static List<({DateTime day, double revenue, int orders})> dailyData(
    List<Order> orders,
    int periodDays, {
    DateTime? now,
  }) {
    final today = _dayOnly(now ?? DateTime.now());
    final result = <({DateTime day, double revenue, int orders})>[];
    for (int i = periodDays - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      double rev = 0;
      int count = 0;
      for (final o in orders) {
        if (_dayOnly(o.createdAt) == day) {
          rev += o.totalPrice;
          count++;
        }
      }
      result.add((day: day, revenue: rev, orders: count));
    }
    return result;
  }

  static List<({String label, double revenue, int orders})> weeklyData(
    List<Order> orders, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final result = <({String label, double revenue, int orders})>[];
    for (int i = 3; i >= 0; i--) {
      final weekEnd = current.subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      double rev = 0;
      int count = 0;
      for (final o in orders) {
        if (o.createdAt.isAfter(
              weekStart.subtract(const Duration(days: 1)),
            ) &&
            o.createdAt.isBefore(weekEnd.add(const Duration(days: 1)))) {
          rev += o.totalPrice;
          count++;
        }
      }
      final startStr = '${weekStart.month}/${weekStart.day}';
      final endStr = '${weekEnd.month}/${weekEnd.day}';
      result.add((label: '$startStr-$endStr', revenue: rev, orders: count));
    }
    return result;
  }

  static List<({int hour, int count})> peakHours(List<Order> orders) {
    final counts = List.filled(24, 0);
    for (final o in orders) {
      counts[o.createdAt.hour]++;
    }
    return [
      for (int h = 0; h < 24; h++) (hour: h, count: counts[h]),
    ];
  }

  static List<(String, int)> statusCounts(List<Order> orders) {
    final counts = <String, int>{};
    for (final o in orders) {
      counts[o.status] = (counts[o.status] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => (e.key, e.value)).toList();
  }

  static List<(String, int)> topItems(List<Order> orders) {
    final map = <String, int>{};
    for (final o in orders) {
      for (final it in o.items) {
        map[it.menuItemName] = (map[it.menuItemName] ?? 0) + it.quantity;
      }
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => (e.key, e.value)).toList();
  }

  static String dayLabel(DateTime day) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[day.weekday % 7];
  }

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
