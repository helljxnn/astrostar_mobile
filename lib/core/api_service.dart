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

  // Variable para controlar el estado de refresh
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

  // Maneja respuestas y detecta token expirado
  Future<http.Response> _handleResponse(http.Response response) async {
    // Si el token expiró (401), limpiar sesión
    if (response.statusCode == 401) {
      try {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? '';

        // Detectar si es un error de token expirado
        if (message.toLowerCase().contains('token') &&
            (message.toLowerCase().contains('expirado') ||
                message.toLowerCase().contains('expired') ||
                message.toLowerCase().contains('inválido') ||
                message.toLowerCase().contains('invalid'))) {
          // Limpiar sesión local
          await StorageService().clearAll();
          throw TokenExpiredException(message);
        }
      } catch (e) {
        if (e is TokenExpiredException) rethrow;
        // Si falla el parseo, continuar con la respuesta normal
      }
    }

    return response;
  }

  // Intenta renovar el access token usando el refresh token del backend
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
    } catch (e) {
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
      final response = await request(headers).timeout(timeout);

      // Manejar respuesta y detectar token expirado
      final handledResponse = await _handleResponse(response);

      // Si recibimos 401 y requiere auth, intentar refresh token
      if (handledResponse.statusCode == 401 && requiresAuth) {
        final refreshSuccess = await _tryRefreshToken();
        if (refreshSuccess) {
          // Reintentar con el nuevo token
          final newHeaders = await _getHeaders(includeAuth: requiresAuth);
          final retryResponse = await request(newHeaders).timeout(timeout);
          return await _handleResponse(retryResponse);
        }
      }

      return handledResponse;
    } on TimeoutException {
      throw Exception(
        'Tiempo de espera agotado. Verifica que el servidor esté corriendo.',
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

// Excepción personalizada para token expirado
class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException(this.message);

  @override
  String toString() => message;
}
