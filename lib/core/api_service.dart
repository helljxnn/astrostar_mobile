import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  // Para Android Emulator usa: http://10.0.2.2:4000/api
  // Para iOS Simulator usa: http://localhost:4000/api
  // Para dispositivo físico usa tu IP local: http://192.168.x.x:4000/api
  static const String baseUrl = 'http://10.0.2.2:4000/api';
  static const Duration timeout = Duration(seconds: 10);

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .get(
            url,
            headers: {'Content-Type': 'application/json'},
          )
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
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
