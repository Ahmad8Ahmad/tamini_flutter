import 'package:web_socket_channel/web_socket_channel.dart';

/// Web implementation: browsers forbid custom headers on a WebSocket
/// handshake, so the JWT is appended to the query string — the only transport
/// the platform allows. The backend accepts both transports.
WebSocketChannel connectWs(Uri uri, {String? token}) {
  if (token == null || token.isEmpty) return WebSocketChannel.connect(uri);
  return WebSocketChannel.connect(
    uri.replace(queryParameters: {...uri.queryParameters, 'token': token}),
  );
}
