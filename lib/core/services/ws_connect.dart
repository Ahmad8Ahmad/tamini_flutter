import 'package:web_socket_channel/web_socket_channel.dart';

import 'ws_connect_io.dart'
    if (dart.library.js_interop) 'ws_connect_web.dart' as platform;

/// Opens a WebSocket to [uri], authenticating with [token].
///
/// On every native platform the token is sent as an `Authorization: Bearer`
/// header, so the JWT never appears in the connection URL and therefore never
/// reaches server/proxy access logs. The browser WebSocket API cannot set
/// headers on the handshake, so the web build falls back to the query-string
/// transport the backend has always accepted.
WebSocketChannel connectWs(Uri uri, {String? token}) =>
    platform.connectWs(uri, token: token);
