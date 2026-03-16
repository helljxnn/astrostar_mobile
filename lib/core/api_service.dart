import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/environment.dart';
import 'storage_service.dart';

class ApiService {
  // Base URL from centralized configuration.
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Dynamic timeout based on environment.
  static Duration get timeout => AppConfig.httpTimeout;

  bool _isRefreshing = false;

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};

    if (includeAuth) {
      final token = await StorageService().getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      try {
        final responseData = jsonDecode(response.body);
        final message = (responseData['message'] ?? '')
            .toString()
            .toLowerCase();

        final looksLikeTokenError =
            message.contains('token') &&
            (message.contains('expirado') ||
                message.contains('expired') ||
                message.contains('invalido') ||
                message.contains('inv\u00E1lido') ||
                message.contains('invalid'));

        if (looksLikeTokenError) {
          await StorageService().clearAll();
          throw TokenExpiredException(message);
        }
      } catch (e) {
        if (e is TokenExpiredException) rethrow;
      }
    }

    return response;
  }

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await StorageService().getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final url = Uri.parse('$baseUrl/auth/refresh');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];

        if (newAccessToken != null) {
          await StorageService().saveAccessToken(newAccessToken);
          return true;
        }
      }

      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<http.Response> _execute(
    Future<http.Response> Function(Map<String, String> headers) request, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await request(headers).timeout(timeout);

      final handledResponse = await _handleResponse(response);

      if (handledResponse.statusCode == 401 && requiresAuth) {
        final refreshSuccess = await _tryRefreshToken();

        if (refreshSuccess) {
          final newHeaders = await _getHeaders(includeAuth: requiresAuth);
          final retryResponse = await request(newHeaders).timeout(timeout);
          return _handleResponse(retryResponse);
        }
      }

      return handledResponse;
    } on TimeoutException {
      throw Exception(
        'Tiempo de espera agotado. Verifica que la API este corriendo en $baseUrl.',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return _execute(
      (headers) => http.get(url, headers: headers),
      requiresAuth: requiresAuth,
    );
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return _execute(
      (headers) => http.post(url, headers: headers, body: jsonEncode(body)),
      requiresAuth: requiresAuth,
    );
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return _execute(
      (headers) => http.put(url, headers: headers, body: jsonEncode(body)),
      requiresAuth: requiresAuth,
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return _execute(
      (headers) => http.delete(url, headers: headers),
      requiresAuth: requiresAuth,
    );
  }
}

class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException(this.message);

  @override
  String toString() => message;
}
