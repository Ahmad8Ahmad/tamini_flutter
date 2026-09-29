import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

/// Pushes order events from the backend to the restaurant owner in real time.
///
/// Connects to the backend's `ws/notifications/<user_id>/` route, which is
/// the only order-notification socket the server actually routes (there is no
/// `ws/orders/`). It authenticates with the user's SimpleJWT access token as
/// a `token` query parameter; the server's WebSocketSessionAuthMiddleware
/// resolves that claim to a user.
class OrderSocketService {
  static const String wsBaseUrl = 'wss://tamini.onrender.com/ws/notifications';

  static const List<int> _retryDelays = [1, 2, 4, 8, 15, 30];

  /// Give up after this many consecutive failures. Without a cap a socket that
  /// the server always rejects reconnects forever, which just burns server
  /// capacity and never succeeds.
  static const int maxAttempts = 8;

  /// A connection that survives this long counts as "stable". Only then do we
  /// reset the backoff counter; otherwise a socket that opens and instantly
  /// drops (common on Render's free tier) would keep resetting to a 1s retry,
  /// hammering the server with reconnect timers forever.
  static const Duration _stableWindow = Duration(seconds: 30);

  final Future<String?> Function() getToken;
  final Future<int?> Function() getUserId;

  OrderSocketService({
    required this.getToken,
    required this.getUserId,
  });

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _closing = false;
  int _attempts = 0;
  DateTime? _connectedAt;
  /// Guards against handling one physical disconnect twice.
  bool _disconnectHandled = false;

  /// True once the retry budget is spent, so the UI can show a "reconnect"
  /// affordance rather than a permanently dead spinner.
  bool get isExhausted => _attempts >= maxAttempts;

  /// Invoked with the decoded JSON of every event pushed by the backend.
  void Function(Map<String, dynamic> event)? onOrderEvent;

  /// Invoked when the connection opens (true) or drops (false).
  void Function(bool connected)? onConnectionChanged;

  Future<void> connect() async {
    _closing = false;
    // Re-arm the disconnect guard for this connection attempt, so a throw
    // below still schedules exactly one retry.
    _disconnectHandled = false;
    final token = await getToken();
    if (token == null || token.isEmpty || _closing) return;
    final userId = await getUserId();
    if (userId == null || _closing) return;
    final uri = Uri.parse(
      '$wsBaseUrl/$userId/',
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
      debugPrint('OrderSocketService: connected to $uri');
      onConnectionChanged?.call(true);
    } catch (e) {
      debugPrint('OrderSocketService.connect failed: $e');
      _onDisconnected();
    }
  }

  void _onMessage(dynamic raw) {
    if (raw is! String || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        onOrderEvent?.call(decoded);
      } else if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) onOrderEvent?.call(item);
        }
      }
    } catch (e) {
      debugPrint('OrderSocketService._onMessage: $e');
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
        'OrderSocketService: giving up after $maxAttempts attempts.',
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
