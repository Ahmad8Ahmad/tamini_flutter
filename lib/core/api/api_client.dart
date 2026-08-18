import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://tamini.onrender.com/api';

  static String? resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = baseUrl.replaceAll('/api', '');
    return '$base$path';
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
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

  Future<void> saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<Map<String, dynamic>> _refreshAccessToken() async {
    final refreshToken = await _refreshTokenFromStorage;
    if (refreshToken == null) {
      await clearTokens();
      onAuthExpired?.call();
      throw ApiException(statusCode: 401, message: 'Session expired, please log in again');
    }
    final uri = Uri.parse('$baseUrl/auth/token/refresh/');
    final response = await _retryOnHtml(() async {
      return await http.post(
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
      var response = await http.get(uri, headers: await _headers());
      if (response.statusCode == 401) {
        debugPrint('GET $uri → 401, refreshing token...');
        await _refreshAccessToken();
        response = await http.get(uri, headers: await _headers());
        debugPrint('GET $uri (retry) → ${response.statusCode}');
      }
      final data = _handleResponse(response);
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

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    return _retryOnHtml(() async {
      final uri = Uri.parse('$baseUrl$path');
      var response = await http.post(
        uri,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      if (response.statusCode == 401) {
        debugPrint('POST $uri → 401, refreshing token...');
        await _refreshAccessToken();
        response = await http.post(
          uri,
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        );
        debugPrint('POST $uri (retry) → ${response.statusCode}');
      }
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) async {
    var response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 401) {
      await _refreshAccessToken();
      response = await http.patch(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    var response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 401) {
      await _refreshAccessToken();
      response = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    var response = await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers());
    if (response.statusCode == 401) {
      await _refreshAccessToken();
      response = await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers());
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(String path, {Map<String, String>? fields, List<http.MultipartFile>? files}) async {
    final uri = Uri.parse('$baseUrl$path');
    var response = await _multipartRequest('POST', uri, fields: fields, files: files);
    if (response.statusCode == 401) {
      debugPrint('POST (multipart) $uri → 401, refreshing token...');
      await _refreshAccessToken();
      response = await _multipartRequest('POST', uri, fields: fields, files: files);
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patchMultipart(String path, {Map<String, String>? fields, List<http.MultipartFile>? files}) async {
    final uri = Uri.parse('$baseUrl$path');
    var response = await _multipartRequest('PATCH', uri, fields: fields, files: files);
    if (response.statusCode == 401) {
      await _refreshAccessToken();
      response = await _multipartRequest('PATCH', uri, fields: fields, files: files);
    }
    return _handleResponse(response);
  }

  Future<http.Response> _multipartRequest(String method, Uri uri, {Map<String, String>? fields, List<http.MultipartFile>? files}) async {
    final request = http.MultipartRequest(method, uri);
    final token = await accessToken;
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (fields != null) request.fields.addAll(fields);
    if (files != null) request.files.addAll(files);
    return http.Response.fromStream(await request.send());
  }

  static bool _isHtmlResponse(http.Response response) {
    final ct = response.headers['content-type'] ?? '';
    if (ct.contains('text/html')) return true;
    final body = response.body.trimLeft();
    return body.startsWith('<!DOCTYPE') || body.startsWith('<!doctype') || body.startsWith('<html');
  }

  /// Retries [fn] up to [maxAttempts] times with a delay when the server
  /// returns an HTML page (typical of Render.com cold starts).
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
          await Future.delayed(Duration(seconds: attempt * 2));
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
