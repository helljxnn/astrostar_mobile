import 'dart:convert';
import 'api_service.dart';
import 'auth_storage.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        {'email': email, 'password': password},
        requiresAuth: false, // Login no requiere autenticación previa
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Guardar token y datos del usuario
        final userData = data['data']['user'];
        final token = data['data']['token'];

        // Extraer el nombre del rol del objeto role
        final roleData = userData['role'];
        final roleName = roleData is Map
            ? (roleData['name'] ?? 'user')
            : 'user';

        await AuthStorage.saveAuthData(
          token: token,
          userId: userData['id'],
          email: userData['email'],
          name: '${userData['firstName']} ${userData['lastName']}',
          role: roleName,
        );

        return {
          'success': true,
          'message': data['message'] ?? 'Login exitoso',
          'user': userData,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Credenciales inválidas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al conectar con el servidor: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthStorage.clearAuthData();
  }

  // Verificar si está autenticado
  Future<bool> isAuthenticated() async {
    return await AuthStorage.isAuthenticated();
  }

  // Obtener datos del usuario actual
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await AuthStorage.getUserData();
  }
}
