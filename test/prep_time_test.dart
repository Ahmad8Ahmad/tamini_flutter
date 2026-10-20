import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamini/core/api/api_client.dart';
import 'package:tamini/core/models/models.dart';
import 'package:tamini/core/repositories/order_repository.dart';
import 'package:tamini/core/utils/prep_time.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('Order.estimated_ready_at parsing', () {
    test('parses the estimate into a DateTime', () {
      final order = Order.fromJson({
        'id': 1,
        'total_price': '100',
        'status': 'Confirmed',
        'created_at': '2026-10-20T10:00:00Z',
        'estimated_ready_at': '2026-10-20T10:30:00Z',
      });
      expect(
        order.estimatedReadyAt,
        DateTime.parse('2026-10-20T10:30:00Z'),
      );
    });

    test('defaults to null when the field is absent', () {
      final order = Order.fromJson({
        'id': 1,
        'total_price': '100',
        'status': 'Pending',
        'created_at': '2026-10-20T10:00:00Z',
      });
      expect(order.estimatedReadyAt, isNull);
    });
  });

  group('OrderTracking prep-time parsing', () {
    test('parses estimate and server clock sample', () {
      final tracking = OrderTracking.fromJson({
        'id': 7,
        'status': 'Preparing',
        'estimated_ready_at': '2026-10-20T10:30:00Z',
        'server_time': '2026-10-20T10:05:00Z',
      });
      expect(
        tracking.estimatedReadyAt,
        DateTime.parse('2026-10-20T10:30:00Z'),
      );
      expect(tracking.serverTime, DateTime.parse('2026-10-20T10:05:00Z'));
    });

    test('defaults both fields to null when absent', () {
      final tracking = OrderTracking.fromJson({'id': 7, 'status': 'Pending'});
      expect(tracking.estimatedReadyAt, isNull);
      expect(tracking.serverTime, isNull);
    });
  });

  group('prep_time utils', () {
    test('serverClockOffset is zero without a server sample', () {
      final now = DateTime.utc(2026, 10, 20, 10);
      expect(
        serverClockOffset(serverTime: null, deviceNow: now),
        Duration.zero,
      );
    });

    test('serverClockOffset measures server minus device', () {
      final device = DateTime.utc(2026, 10, 20, 10);
      final server = device.add(const Duration(minutes: 5));
      expect(
        serverClockOffset(serverTime: server, deviceNow: device),
        const Duration(minutes: 5),
      );
    });

    test('prepRemaining uses the offset to correct the device clock', () {
      final device = DateTime.utc(2026, 10, 20, 10);
      final estimate = DateTime.utc(2026, 10, 20, 10, 30);
      // Device is 10 minutes behind the server, so only 20 minutes remain.
      final offset = const Duration(minutes: 10);
      expect(
        prepRemaining(
          estimatedReadyAt: estimate,
          offset: offset,
          deviceNow: device,
        ),
        const Duration(minutes: 20),
      );
    });

    test('prepRemaining goes negative after the estimate has passed', () {
      final device = DateTime.utc(2026, 10, 20, 10, 45);
      final estimate = DateTime.utc(2026, 10, 20, 10, 30);
      expect(
        prepRemaining(estimatedReadyAt: estimate, deviceNow: device),
        const Duration(minutes: -15),
      );
    });

    test('prepRemaining is null without an estimate', () {
      expect(prepRemaining(estimatedReadyAt: null), isNull);
    });

    test('formatReadyByTime renders local H:mm', () {
      final instant = DateTime.utc(2026, 10, 20, 17, 5).toLocal();
      final hour = instant.hour;
      expect(formatReadyByTime(instant), '$hour:05');
    });
  });

  group('ApiOrderRepository.updateStatus payload', () {
    late MockApiClient api;

    setUp(() {
      api = MockApiClient();
      when(() => api.patch(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => <String, dynamic>{'id': 1, 'status': 'Confirmed'},
      );
    });

    test('sends status and the UTC estimate together', () async {
      final repo = ApiOrderRepository(api);
      final estimate = DateTime.utc(2026, 10, 20, 10, 30);

      await repo.updateStatus(1, 'Confirmed', estimatedReadyAt: estimate);

      verify(
        () => api.patch(
          '/orders/1/update-status/',
          body: {
            'status': 'Confirmed',
            'estimated_ready_at': '2026-10-20T10:30:00.000Z',
          },
        ),
      ).called(1);
    });

    test('estimate-only edit omits the status key', () async {
      final repo = ApiOrderRepository(api);
      final estimate = DateTime.utc(2026, 10, 20, 10, 45);

      await repo.updateStatus(1, null, estimatedReadyAt: estimate);

      verify(
        () => api.patch(
          '/orders/1/update-status/',
          body: {'estimated_ready_at': '2026-10-20T10:45:00.000Z'},
        ),
      ).called(1);
    });

    test('status without estimate sends only the status', () async {
      final repo = ApiOrderRepository(api);

      await repo.updateStatus(1, 'Cancelled');

      verify(
        () => api.patch(
          '/orders/1/update-status/',
          body: {'status': 'Cancelled'},
        ),
      ).called(1);
    });
  });
}
