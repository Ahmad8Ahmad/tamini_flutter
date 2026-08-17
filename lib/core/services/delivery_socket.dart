import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

/// Pushes delivery events from the backend to the delivery driver in real time.
///
/// The socket authenticates with the user's JWT sent as a `token` query
/// parameter, which is the standard handshake for Django Channels.
class DeliverySocketService {
  static const String wssBaseUrl = 'wss://tamini.onrender.com/ws/deliveries/';

  static const List<int> _retryDelays = [1, 2, 4, 8, 15, 30];

  final Future<String?> Function() getToken;

  DeliverySocketService({required this.getToken});

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _closing = false;
  int _attempts = 0;

  /// Invoked with the decoded JSON of every event pushed by the backend.
  void Function(Map<String, dynamic> event)? onDeliveryEvent;

  /// Invoked when the connection opens (true) or drops (false).
  void Function(bool connected)? onConnectionChanged;

  bool get isConnected => _channel != null;

  Future<void> connect() async {
    _closing = false;
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
      _attempts = 0;
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
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    if (_closing) return;
    final delayIndex = _attempts < _retryDelays.length
        ? _attempts
        : _retryDelays.length - 1;
    _attempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: _retryDelays[delayIndex]),
      connect,
    );
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
