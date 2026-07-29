import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://tamini.onrender.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;

  Future<String?> get accessToken async {
    _accessToken ??= await _storage.read(key: 'access_token');
    return _accessToken;
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
    if (_refreshToken == null) throw Exception('No refresh token');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['access'], _refreshToken!);
      return data;
    } else {
      await clearTokens();
      throw Exception('Token refresh failed');
    }
  }

  Future<Map<String, String>> _headers() async {
    final token = await accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null) uri = uri.replace(queryParameters: queryParams);
    var response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 401) {
      await _refreshAccessToken();
      response = await http.get(uri, headers: await _headers());
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    var response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 401) {
      await _refreshAccessToken();
      response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
    }
    return _handleResponse(response);
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

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'detail': 'OK'};
      return jsonDecode(response.body);
    }
    final body = jsonDecode(response.body);
    throw ApiException(statusCode: response.statusCode, message: body['detail'] ?? body.toString());
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});
  @override
  String toString() => '$statusCode: $message';
}
