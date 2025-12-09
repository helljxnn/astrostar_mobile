import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

class ApiService {
  // Detecta automáticamente la plataforma y usa la URL correcta
  static String get baseUrl {
    if (kIsWeb) {
      // Para navegadores web (Chrome, Edge, Firefox, etc.)
      return 'http://localhost:4000/api';
    } else {
      try {
        if (Platform.isAndroid) {
          // Para dispositivo físico Android - usa la IP de tu computadora
          return 'http://192.168.1.113:4000/api';
        } else if (Platform.isIOS) {
          // Para dispositivo físico iOS - usa la IP de tu computadora
          return 'http://192.168.1.113:4000/api';
        } else {
          // Fallback para otras plataformas
          return 'http://192.168.1.113:4000/api';
        }
      } catch (e) {
        // Si falla la detección, usar IP local
        return 'http://192.168.1.113:4000/api';
      }
    }
  }
  
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
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
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
          .put(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
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
