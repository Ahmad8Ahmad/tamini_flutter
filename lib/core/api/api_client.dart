import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiClient {
  /// Configured via `--dart-define=API_BASE_URL=...` (see [AppConfig]).
  static const String baseUrl = AppConfig.apiBaseUrl;

  static String? resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = baseUrl.replaceAll('/api', '');
    return '$base$path';
  }

  /// [client] and [storage] are injectable so tests can drive the auth,
  /// retry and cache paths with an in-process fake instead of real sockets
  /// and the secure-storage plugin. Production uses the defaults.
  ApiClient({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _storage;
  String? _accessToken;
  String? _refreshToken;

  /// Called when the session is permanently invalid (no refresh token, or the
  /// refresh itself is rejected). Listeners should log the user out.
  void Function()? onAuthExpired;

  Future<String?> get accessToken async {
    _accessToken ??= await _storage.read(key: 'access_token');
    return _accessToken;
  }

  Future<String?> get _refreshTokenFromStorage async {
    _refreshToken ??= await _storage.read(key: 'refresh_token');
    return _refreshToken;
  }

  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    // Cached GET responses were fetched under the session that just ended and
    // may be account-scoped (e.g. `/restaurants/my/`), so they must not be
    // served to whoever signs in next. The cache key is path-only, so nothing
    // else distinguishes one account's entry from another's.
    _getCache.clear();
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_data');
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: 'user_data', value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: 'user_data');
    if (data != null) return jsonDecode(data);
    return null;
  }

  Future<bool> hasTokens() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  Future<void> saveTokens(String access, String refresh) =>
      _saveTokens(access, refresh);

  Future<Map<String, dynamic>>? _refreshInFlight;

  /// Refreshes the access token, collapsing concurrent 401s into a single
  /// network call. SimpleJWT can rotate refresh tokens, so two parallel
  /// refreshes using the same token could invalidate each other; sharing one
  /// in-flight future avoids that and the resulting forced logout.
  Future<Map<String, dynamic>> _refreshAccessToken() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;
    final future = _performRefresh();
    _refreshInFlight = future;
    void clear() {
      if (identical(_refreshInFlight, future)) _refreshInFlight = null;
    }

    // `then` with an onError handler swallows the cleanup future's error so a
    // failed refresh isn't reported as an unhandled async error; the caller
    // still receives (and handles) the error from the returned [future].
    future.then((_) => clear(), onError: (_) => clear());
    return future;
  }

  Future<Map<String, dynamic>> _performRefresh() async {
    final refreshToken = await _refreshTokenFromStorage;
    if (refreshToken == null) {
      await clearTokens();
      onAuthExpired?.call();
      throw ApiException(statusCode: 401, message: 'Session expired, please log in again');
    }
    final uri = Uri.parse('$baseUrl/auth/token/refresh/');
    final response = await _retryOnHtml(() async {
      return await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
    }, maxAttempts: 2);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['access'], refreshToken);
      return data;
    }
    await clearTokens();
    onAuthExpired?.call();
    throw ApiException(statusCode: response.statusCode, message: 'Token refresh failed');
  }

  Future<Map<String, String>> _headers() async {
    final token = await accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  final Map<String, _CachedResponse> _getCache = {};

  /// Clears the in-memory GET cache so the next request hits the network.
  void clearCatalogCache() {
    _getCache.clear();
  }

  /// Fetches [path] over HTTP. When [cacheTtl] is provided, the parsed result
  /// is cached in memory for that duration, keyed by path + query, so repeated
  /// reads of the same catalog data avoid extra network round-trips. Set
  /// [forceRefresh] to bypass any cached copy and always hit the network.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cacheKey(path, queryParams);
    if (cacheTtl != null && !forceRefresh) {
      final hit = _getCache[cacheKey];
      if (hit != null && !hit.isExpired) {
        debugPrint('GET $path → cache hit');
        return hit.data;
      }
    }
    return _retryOnHtml(() async {
      var uri = Uri.parse('$baseUrl$path');
      if (queryParams != null) uri = uri.replace(queryParameters: queryParams);
      final data = await _send(
        () async => _client.get(uri, headers: await _headers()),
        label: 'GET $uri',
      );
      if (cacheTtl != null) {
        _getCache[cacheKey] = _CachedResponse(data, DateTime.now().add(cacheTtl));
      }
      return data;
    });
  }

  String _cacheKey(String path, Map<String, String>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) return path;
    final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$path?$query';
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) {
    final uri = Uri.parse('$baseUrl$path');
    return _send(
      () async => _client.post(
        uri,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
      label: 'POST $uri',
    );
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) {
    final uri = Uri.parse('$baseUrl$path');
    return _send(
      () async => _client.patch(
        uri,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
      label: 'PATCH $uri',
    );
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) {
    final uri = Uri.parse('$baseUrl$path');
    return _send(
      () async => _client.put(
        uri,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
      label: 'PUT $uri',
    );
  }

  Future<Map<String, dynamic>> delete(String path) {
    final uri = Uri.parse('$baseUrl$path');
    return _send(
      () async => _client.delete(uri, headers: await _headers()),
      label: 'DELETE $uri',
    );
  }

  Future<Map<String, dynamic>> postMultipart(String path, {Map<String, String>? fields, List<http.MultipartFile>? files}) {
    final uri = Uri.parse('$baseUrl$path');
    return _send(
      () => _multipartRequest('POST', uri, fields: fields, files: files),
      label: 'POST (multipart) $uri',
    );
  }

  Future<Map<String, dynamic>> patchMultipart(String path, {Map<String, String>? fields, List<http.MultipartFile>? files}) {
    final uri = Uri.parse('$baseUrl$path');
    return _send(
      () => _multipartRequest('PATCH', uri, fields: fields, files: files),
      label: 'PATCH (multipart) $uri',
    );
  }

  /// Single choke point every HTTP verb goes through: cold-start retry wraps
  /// auth-and-refresh which wraps the raw send, then the response is parsed.
  /// Keeping all verbs here means PATCH/PUT/DELETE/multipart get the same
  /// Render cold-start resilience and 401 refresh as GET/POST.
  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() send, {
    String? label,
  }) {
    return _retryOnHtml(() async {
      final response = await _sendWithAuth(send, label: label);
      return _handleResponse(response);
    });
  }

  /// Runs [send] once; if it returns 401 (expired access token), refreshes the
  /// token and retries once. Centralizes the refresh-and-retry block that each
  /// HTTP verb used to duplicate. [send] re-reads the current token on each
  /// call, so the retry uses the freshly refreshed token.
  Future<http.Response> _sendWithAuth(
    Future<http.Response> Function() send, {
    String? label,
  }) async {
    var response = await send();
    if (response.statusCode == 401) {
      if (label != null) debugPrint('$label → 401, refreshing token...');
      await _refreshAccessToken();
      response = await send();
      if (label != null) debugPrint('$label (retry) → ${response.statusCode}');
    }
    return response;
  }

  Future<http.Response> _multipartRequest(String method, Uri uri, {Map<String, String>? fields, List<http.MultipartFile>? files}) async {
    final request = http.MultipartRequest(method, uri);
    final token = await accessToken;
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (fields != null) request.fields.addAll(fields);
    if (files != null) request.files.addAll(files);
    return http.Response.fromStream(await _client.send(request));
  }

  static bool _isHtmlResponse(http.Response response) {
    final ct = response.headers['content-type'] ?? '';
    if (ct.contains('text/html')) return true;
    final body = response.body.trimLeft();
    return body.startsWith('<!DOCTYPE') || body.startsWith('<!doctype') || body.startsWith('<html');
  }

  /// A cold Render.com instance can take 30-60s to boot. Waiting `attempt * 2`
  /// seconds between attempts only stacks growing delays on top of an already
  /// slow first request, so perceived latency gets worse instead of better.
  /// Use a short fixed delay to keep the whole retry cycle fast.
  static const Duration _coldStartRetryDelay = Duration(seconds: 1);

  /// Retries [fn] up to [maxAttempts] times when the server returns an HTML
  /// page (typical of Render.com cold starts).
  Future<T> _retryOnHtml<T>(Future<T> Function() fn, {int maxAttempts = 3}) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await fn();
      } on ApiException catch (e) {
        final isHtml = e.statusCode == 503 ||
            e.message.contains('Retrying') ||
            e.message.contains('error page');
        if (attempt < maxAttempts && isHtml) {
          debugPrint('Retry $attempt/$maxAttempts after HTML response...');
          await Future.delayed(_coldStartRetryDelay);
          continue;
        }
        rethrow;
      }
    }
    throw ApiException(statusCode: 503, message: 'Server is temporarily unavailable. Please try again later.');
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'detail': 'OK'};
      if (_isHtmlResponse(response)) {
        throw ApiException(statusCode: 503, message: 'error page');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'results': decoded};
      return decoded;
    }
    if (_isHtmlResponse(response)) {
      debugPrint('API error ${response.statusCode}: HTML response (server may be waking up)');
      throw ApiException(statusCode: 503, message: 'Retrying');
    }
    final body = jsonDecode(response.body);
    final msg = body is Map ? (body['detail'] ?? body.toString()) : body.toString();
    debugPrint('API error ${response.statusCode}: $msg');
    throw ApiException(statusCode: response.statusCode, message: msg);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});
  @override
  String toString() => '$statusCode: $message';
}

class _CachedResponse {
  final Map<String, dynamic> data;
  final DateTime expiresAt;
  _CachedResponse(this.data, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
