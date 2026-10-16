import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Native implementation: the JWT rides in the `Authorization` header instead
/// of the query string, so it cannot leak into access logs or crash reports
/// that record the connection URL.
WebSocketChannel connectWs(Uri uri, {String? token}) {
  if (token == null || token.isEmpty) return WebSocketChannel.connect(uri);
  return IOWebSocketChannel.connect(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );
}
