import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import './storage_service.dart';

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

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
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
      return response;
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Verifica que el servidor esté corriendo.');
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
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
      return response;
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
