import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  // Detecta automáticamente la plataforma y usa la URL correcta
  static String get baseUrl {
    if (kIsWeb) {
      // Para navegadores web (Chrome, Edge, Firefox, etc.)
      return 'http://localhost:4000/api';
    } else {
      try {
        if (Platform.isAndroid) {
          // Para emulador de Android Studio - 10.0.2.2 apunta al localhost de tu PC
          // Para dispositivo físico Android - cambia a 'http://192.168.1.113:4000/api'
          return 'http://10.0.2.2:4000/api';
        } else if (Platform.isIOS) {
          // Para simulador iOS - localhost funciona directamente
          return 'http://localhost:4000/api';
        } else {
          // Fallback para otras plataformas
          return 'http://localhost:4000/api';
        }
      } catch (e) {
        // Si falla la detección, usar localhost
        return 'http://localhost:4000/api';
      }
    }
  }

  static const Duration timeout = Duration(seconds: 10);

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
