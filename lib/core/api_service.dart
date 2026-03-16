import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'storage_service.dart';
import '../config/environment.dart';

class ApiService {
  // URL base obtenida de la configuración centralizada
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Timeout dinámico según el ambiente
  static Duration get timeout => AppConfig.httpTimeout;

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

  // Intenta renovar el access token usando el refresh token del backend
  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refreshToken = await StorageService().getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await StorageService().clearAll();
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
        if (data['success'] == true && data['data']?['accessToken'] != null) {
          await StorageService().saveAccessToken(data['data']['accessToken']);
          return true;
        }
      }
      // Refresh falló — limpiar sesión
      await StorageService().clearAll();
      return false;
    } catch (_) {
      await StorageService().clearAll();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // Ejecuta la request y reintenta una vez si recibe 401
  Future<http.Response> _execute(
    Future<http.Response> Function(Map<String, String> headers) request, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      var response = await request(headers).timeout(timeout);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          final newHeaders = await _getHeaders(includeAuth: true);
          response = await request(newHeaders).timeout(timeout);
        } else {
          throw Exception('Token expirado. Por favor inicia sesión nuevamente.');
        }
      }

      return response;
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Verifica que el servidor esté corriendo.');
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return _execute((h) => http.get(url, headers: h), requiresAuth: requiresAuth);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return _execute((h) => http.post(url, headers: h, body: jsonEncode(body)), requiresAuth: requiresAuth);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return _execute((h) => http.put(url, headers: h, body: jsonEncode(body)), requiresAuth: requiresAuth);
  }

  Future<http.Response> delete(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return _execute((h) => http.delete(url, headers: h), requiresAuth: requiresAuth);
  }
}
