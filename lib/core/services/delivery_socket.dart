import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

/// Pushes delivery events from the backend to the delivery driver in real time.
///
/// Connects to the backend's `ws/driver-notifications/` broadcast route, which
/// is the only driver socket the server routes (there is no `ws/deliveries/`).
/// Authenticates with the user's SimpleJWT access token as a `token` query
/// parameter, resolved server-side by WebSocketSessionAuthMiddleware.
class DeliverySocketService {
  static const String wssBaseUrl = 'wss://tamini.onrender.com/ws/driver-notifications/';

  static const List<int> _retryDelays = [1, 2, 4, 8, 15, 30];

  /// Give up after this many consecutive failures instead of retrying forever
  /// against a socket the server will keep rejecting.
  static const int maxAttempts = 8;

  /// A connection that survives this long counts as "stable". Only then do we
  /// reset the backoff counter; otherwise a socket that opens and instantly
  /// drops (common on Render's free tier) would keep resetting to a 1s retry,
  /// hammering the server with reconnect timers forever.
  static const Duration _stableWindow = Duration(seconds: 30);

  final Future<String?> Function() getToken;

  DeliverySocketService({required this.getToken});

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _closing = false;
  int _attempts = 0;
  DateTime? _connectedAt;
  /// Guards against handling one physical disconnect twice.
  bool _disconnectHandled = false;

  /// Invoked with the decoded JSON of every event pushed by the backend.
  void Function(Map<String, dynamic> event)? onDeliveryEvent;

  /// Invoked when the connection opens (true) or drops (false).
  void Function(bool connected)? onConnectionChanged;

  bool get isConnected => _channel != null;

  /// True once the retry budget is spent, so the UI can offer a manual retry.
  bool get isExhausted => _attempts >= maxAttempts;

  Future<void> connect() async {
    _closing = false;
    // Re-arm the disconnect guard for this connection attempt, so a throw
    // below still schedules exactly one retry.
    _disconnectHandled = false;
    final token = await getToken();
    if (token == null || token.isEmpty || _closing) return;
    final uri = Uri.parse(
      wssBaseUrl,
    ).replace(queryParameters: {'token': token});
    try {
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      _subscription = channel.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (Object _) => _onDisconnected(),
      );
      _connectedAt = DateTime.now();
      debugPrint('DeliverySocketService: connected to $wssBaseUrl');
      onConnectionChanged?.call(true);
    } catch (e) {
      debugPrint('DeliverySocketService.connect failed: $e');
      _onDisconnected();
    }
  }

  void _onMessage(dynamic raw) {
    if (raw is! String || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        onDeliveryEvent?.call(decoded);
      } else if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) onDeliveryEvent?.call(item);
        }
      }
    } catch (e) {
      debugPrint('DeliverySocketService._onMessage: $e');
    }
  }

  void _onDisconnected() {
    // The stream can report a drop through both onDone and onError; without
    // this guard a single disconnect would burn two retry attempts.
    if (_disconnectHandled) return;
    _disconnectHandled = true;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    onConnectionChanged?.call(false);
    if (_closing) return;
    if (_attempts >= maxAttempts) {
      debugPrint(
        'DeliverySocketService: giving up after $maxAttempts attempts.',
      );
      return;
    }
    final wasConnected = _connectedAt != null;
    final wasStable =
        wasConnected && DateTime.now().difference(_connectedAt!) >= _stableWindow;
    _connectedAt = null;
    if (wasStable) _attempts = 0;
    final delayIndex = _attempts < _retryDelays.length
        ? _attempts
        : _retryDelays.length - 1;
    _attempts++;
    _reconnectTimer?.cancel();
    // Jitter (±0.5s) so multiple phones that dropped together don't all retry
    // at the same instant.
    final delay = Duration(seconds: _retryDelays[delayIndex]) +
        Duration(milliseconds: Random().nextInt(1000));
    _reconnectTimer = Timer(delay, connect);
  }

  void close() {
    _closing = true;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
  }
}
