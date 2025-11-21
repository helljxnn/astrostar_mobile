import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class ApiService {
  // Para Android Emulator usa: http://10.0.2.2:4000/api
  // Para iOS Simulator usa: http://localhost:4000/api
  // Para dispositivo físico usa tu IP local: http://192.168.x.x:4000/api
  static const String baseUrl = 'http://10.0.2.2:4000/api';
  static const Duration timeout = Duration(seconds: 10);

  // Obtener headers con autenticación
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};

    if (includeAuth) {
      final token = await AuthStorage.getToken();
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

  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http
          .delete(url, headers: headers)
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
