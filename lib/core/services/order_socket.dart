import '../config/app_config.dart';
import 'reconnecting_socket.dart';

/// Pushes order events from the backend to the restaurant owner in real time.
///
/// Connects to the backend's `ws/notifications/<user_id>/` route, which is
/// the only order-notification socket the server actually routes (there is no
/// `ws/orders/`). Authentication and reconnect behavior live in
/// [ReconnectingSocket].
class OrderSocketService extends ReconnectingSocket {
  OrderSocketService({
    required super.getToken,
    required this.getUserId,
  });

  final Future<int?> Function() getUserId;

  @override
  String get debugLabel => 'OrderSocketService';

  @override
  Future<Uri?> resolveEndpoint() async {
    final userId = await getUserId();
    if (userId == null) return null;
    return Uri.parse('${AppConfig.wsBaseUrl}/notifications/$userId/');
  }
}
