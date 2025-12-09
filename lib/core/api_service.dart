import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
<<<<<<< HEAD
import 'auth_storage.dart';
=======
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import './storage_service.dart';
>>>>>>> 9d436a87c9325a311368247b8b2cbbdd1b0b2740

class ApiService {
  final StorageService _storage = StorageService();
  // Detecta automáticamente la plataforma y usa la URL correcta
  static String get baseUrl {
    if (kIsWeb) {
      // Para navegadores web (Chrome, Edge, Firefox, etc.)
      return 'http://localhost:4000/api';
    } else {
      try {
        if (Platform.isAndroid) {
          // Para dispositivo físico Android conectado por USB
          // Usa 'adb reverse tcp:4000 tcp:4000' para hacer port forwarding
          return 'http://localhost:4000/api';
        } else if (Platform.isIOS) {
          // Para dispositivo físico iOS
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
<<<<<<< HEAD
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http.get(url, headers: headers).timeout(timeout);
=======
      // Obtener token de autenticación
      final token = await _storage.getAccessToken();
      
      // Construir headers con token si existe
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http
          .get(url, headers: headers)
          .timeout(timeout);
>>>>>>> 9d436a87c9325a311368247b8b2cbbdd1b0b2740
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
<<<<<<< HEAD
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(timeout);
=======
      // Obtener token de autenticación
      final token = await _storage.getAccessToken();
      
      // Construir headers con token si existe
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
>>>>>>> 9d436a87c9325a311368247b8b2cbbdd1b0b2740
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
