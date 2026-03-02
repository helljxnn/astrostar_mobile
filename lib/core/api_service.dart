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

  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http.get(url, headers: headers).timeout(timeout);
      return response;
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
      return response;
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
      return response;
    } on TimeoutException {
      throw Exception(
        'Tiempo de espera agotado. Verifica que el servidor esté corriendo.',
      );
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
