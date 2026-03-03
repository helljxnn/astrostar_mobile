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

  // Obtener headers con autenticación
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

  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http.get(url, headers: headers).timeout(timeout);
      return await _handleResponse(response);
    } on TokenExpiredException {
      rethrow; // Re-lanzar para que la UI lo maneje
    } on TimeoutException {
      throw Exception(
        'Tiempo de espera agotado. Verifica que el servidor esté corriendo.',
      );
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(timeout);
      return await _handleResponse(response);
    } on TokenExpiredException {
      rethrow;
    } on TimeoutException {
      throw Exception(
        'Tiempo de espera agotado. Verifica que el servidor esté corriendo.',
      );
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(timeout);
      return await _handleResponse(response);
    } on TokenExpiredException {
      rethrow;
    } on TimeoutException {
      throw Exception(
        'Tiempo de espera agotado. Verifica que el servidor esté corriendo.',
      );
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}

// Excepción personalizada para token expirado
class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException(this.message);

  @override
  String toString() => message;
}
