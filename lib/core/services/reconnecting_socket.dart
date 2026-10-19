import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'ws_connect.dart';

/// Shared reconnect logic for the app's authenticated WebSocket channels
/// (owner order notifications, driver delivery notifications).
///
/// Subclasses only resolve their endpoint; connecting, backoff, close and
/// event dispatch are identical and live here. Authenticates with the user's
/// SimpleJWT access token via [connectWs]: sent as an `Authorization` header
/// on native platforms (keeping the JWT out of the URL and out of access
/// logs) and as a `token` query parameter on the web, where the browser
/// handshake API forbids custom headers.
abstract class ReconnectingSocket {
  ReconnectingSocket({required this.getToken});

  final Future<String?> Function() getToken;

  /// Label used in debug logs (e.g. `OrderSocketService`).
  String get debugLabel;

  /// Resolves the WebSocket endpoint to connect to, or null to skip this
  /// attempt (e.g. a required user id isn't available yet).
  Future<Uri?> resolveEndpoint();

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

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _closing = false;
  int _attempts = 0;
  DateTime? _connectedAt;

  /// Guards against handling one physical disconnect twice.
  bool _disconnectHandled = false;

  /// Invoked with the decoded JSON of every event pushed by the backend.
  void Function(Map<String, dynamic> event)? onEvent;

  /// Invoked when the connection opens (true) or drops (false).
  void Function(bool connected)? onConnectionChanged;

  bool get isConnected => _channel != null;

  /// True once the retry budget is spent, so the UI can show a "reconnect"
  /// affordance rather than a permanently dead spinner.
  bool get isExhausted => _attempts >= maxAttempts;

  Future<void> connect() async {
    _closing = false;
    // Re-arm the disconnect guard for this connection attempt, so a throw
    // below still schedules exactly one retry.
    _disconnectHandled = false;
    final token = await getToken();
    if (token == null || token.isEmpty || _closing) return;
    final endpoint = await resolveEndpoint();
    if (endpoint == null || _closing) return;
    try {
      // The token goes through connectWs (header on native), never into the
      // URI — a logged URL must not carry credentials.
      final channel = connectWs(endpoint, token: token);
      _channel = channel;
      _subscription = channel.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (Object _) => _onDisconnected(),
      );
      _connectedAt = DateTime.now();
      debugPrint('$debugLabel: connected to $endpoint');
      onConnectionChanged?.call(true);
    } catch (e) {
      debugPrint('$debugLabel.connect failed: $e');
      _onDisconnected();
    }
  }

  void _onMessage(dynamic raw) {
    if (raw is! String || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        onEvent?.call(decoded);
      } else if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) onEvent?.call(item);
        }
      }
    } catch (e) {
      debugPrint('$debugLabel._onMessage: $e');
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
      debugPrint('$debugLabel: giving up after $maxAttempts attempts.');
      return;
    }
    final wasConnected = _connectedAt != null;
    final wasStable =
        wasConnected && DateTime.now().difference(_connectedAt!) >= _stableWindow;
    _connectedAt = null;
    if (wasStable) _attempts = 0;
    final delayIndex =
        _attempts < _retryDelays.length ? _attempts : _retryDelays.length - 1;
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
