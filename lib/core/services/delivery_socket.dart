import '../config/app_config.dart';
import 'reconnecting_socket.dart';

/// Pushes delivery events from the backend to the delivery driver in real time.
///
/// Connects to the backend's `ws/driver-notifications/` broadcast route, which
/// is the only driver socket the server routes (there is no `ws/deliveries/`).
/// Authentication and reconnect behavior live in [ReconnectingSocket].
class DeliverySocketService extends ReconnectingSocket {
  DeliverySocketService({required super.getToken});

  @override
  String get debugLabel => 'DeliverySocketService';

  @override
  Future<Uri?> resolveEndpoint() async =>
      Uri.parse('${AppConfig.wsBaseUrl}/driver-notifications/');
}
