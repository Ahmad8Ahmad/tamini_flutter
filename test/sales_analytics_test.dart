import 'package:flutter_test/flutter_test.dart';
import 'package:tamini/core/models/models.dart';
import 'package:tamini/features/owner/controllers/sales_analytics.dart';

Order _order({
  required int id,
  required DateTime createdAt,
  double totalPrice = 0,
  String status = 'Delivered',
  List<OrderItem> items = const [],
}) =>
    Order(
      id: id,
      customerName: 'customer $id',
      customerPhone: '0900',
      customerEmail: 'c$id@test.com',
      restaurant: 1,
      restaurantName: 'Tamini',
      deliveryAddress: 'street',
      totalPrice: totalPrice,
      status: status,
      items: items,
      createdAt: createdAt,
    );

OrderItem _item(String name, int quantity) => OrderItem(
      id: 1,
      menuItem: 1,
      menuItemName: name,
      quantity: quantity,
      price: 10,
    );

void main() {
  final now = DateTime(2026, 10, 19, 15, 30);

  group('activeOrders / isCancelled', () {
    test('both cancelled spellings are excluded, everything else kept', () {
      final orders = [
        _order(id: 1, createdAt: now, status: 'Cancelled'),
        _order(id: 2, createdAt: now, status: 'Canceled'),
        _order(id: 3, createdAt: now, status: 'Pending'),
        _order(id: 4, createdAt: now, status: 'Delivered'),
      ];

      final active = SalesAnalytics.activeOrders(orders);

      expect(active.map((o) => o.id), [3, 4]);
      expect(SalesAnalytics.isCancelled(orders[0]), isTrue);
      expect(SalesAnalytics.isCancelled(orders[3]), isFalse);
    });
  });

  group('dailyData', () {
    test('buckets revenue per day over the period, oldest first', () {
      final orders = [
        _order(id: 1, createdAt: DateTime(2026, 10, 19, 9), totalPrice: 100),
        _order(id: 2, createdAt: DateTime(2026, 10, 19, 21), totalPrice: 50),
        _order(id: 3, createdAt: DateTime(2026, 10, 17, 12), totalPrice: 25),
        // Outside the 3-day window.
        _order(id: 4, createdAt: DateTime(2026, 10, 10, 12), totalPrice: 999),
      ];

      final rows = SalesAnalytics.dailyData(orders, 3, now: now);

      expect(rows, hasLength(3));
      expect(rows.first.day, DateTime(2026, 10, 17));
      expect(rows.last.day, DateTime(2026, 10, 19));
      expect(rows[0].revenue, 25);
      expect(rows[0].orders, 1);
      expect(rows[1].revenue, 0, reason: 'a quiet day still shows up');
      expect(rows[1].orders, 0);
      expect(rows[2].revenue, 150, reason: 'same-day orders add up');
      expect(rows[2].orders, 2);
    });
  });

  group('weeklyData', () {
    test('produces four labelled week buckets', () {
      final orders = [
        _order(id: 1, createdAt: DateTime(2026, 10, 19), totalPrice: 40),
        _order(id: 2, createdAt: DateTime(2026, 10, 5), totalPrice: 60),
      ];

      final rows = SalesAnalytics.weeklyData(orders, now: now);

      expect(rows, hasLength(4));
      expect(rows.last.revenue, 40, reason: 'the current week holds today');
      expect(rows.last.orders, 1);
      expect(rows.first.revenue, 0);
      expect(rows.map((r) => r.label).toSet(), hasLength(4),
          reason: 'each week gets its own date range label');
    });
  });

  group('peakHours', () {
    test('covers all 24 hours and counts by hour of day', () {
      final orders = [
        _order(id: 1, createdAt: DateTime(2026, 10, 19, 13, 5)),
        _order(id: 2, createdAt: DateTime(2026, 10, 18, 13, 55)),
        _order(id: 3, createdAt: DateTime(2026, 10, 17, 20)),
      ];

      final rows = SalesAnalytics.peakHours(orders);

      expect(rows, hasLength(24));
      expect(rows[13], (hour: 13, count: 2));
      expect(rows[20], (hour: 20, count: 1));
      expect(rows[0], (hour: 0, count: 0));
    });
  });

  group('statusCounts', () {
    test('counts every status sorted by frequency', () {
      final orders = [
        _order(id: 1, createdAt: now, status: 'Delivered'),
        _order(id: 2, createdAt: now, status: 'Delivered'),
        _order(id: 3, createdAt: now, status: 'Cancelled'),
        _order(id: 4, createdAt: now, status: 'Pending'),
      ];

      final rows = SalesAnalytics.statusCounts(orders);

      expect(rows.first, ('Delivered', 2),
          reason: 'the most frequent status leads');
      expect(rows.map((r) => r.$1).toSet(),
          {'Delivered', 'Cancelled', 'Pending'});
      expect(rows.fold<int>(0, (sum, r) => sum + r.$2), 4);
    });
  });

  group('topItems', () {
    test('aggregates quantities per item sorted by popularity', () {
      final orders = [
        _order(id: 1, createdAt: now, items: [_item('Shawarma', 2)]),
        _order(
          id: 2,
          createdAt: now,
          items: [_item('Shawarma', 1), _item('Falafel', 5)],
        ),
      ];

      final rows = SalesAnalytics.topItems(orders);

      expect(rows.first, ('Falafel', 5));
      expect(rows.map((r) => r.$1).toSet(), {'Falafel', 'Shawarma'});
    });
  });

  group('dayLabel', () {
    test('maps DateTime.weekday onto Sun-first names', () {
      expect(SalesAnalytics.dayLabel(DateTime(2026, 10, 18)), 'Sun');
      expect(SalesAnalytics.dayLabel(DateTime(2026, 10, 19)), 'Mon');
      expect(SalesAnalytics.dayLabel(DateTime(2026, 10, 24)), 'Sat');
    });
  });
}
