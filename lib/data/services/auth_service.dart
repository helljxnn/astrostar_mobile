import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../../core/storage_service.dart';

class AuthService {
  // Cambiar según el entorno
  // Emulador Android: http://10.0.2.2:4000/api
  // Dispositivo físico: http://TU_IP_LOCAL:4000/api
  // Producción: https://tu-dominio.com/api
  static const String baseUrl = 'http://10.0.2.2:4000/api';
  static const Duration timeout = Duration(seconds: 15);

  final StorageService _storage = StorageService();

  // ========== LOGIN ==========
  Future<AuthResponse> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(responseData);
        
        if (authResponse.success && authResponse.data != null) {
          // Guardar token y usuario
          await _storage.saveAccessToken(authResponse.data!.accessToken);
          await _storage.saveUser(authResponse.data!.user);
        }
        
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Error al iniciar sesión',
        );
      }
    } on TimeoutException {
      return AuthResponse(
        success: false,
        message: 'Tiempo de espera agotado. Verifica tu conexión.',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // ========== GET CURRENT USER ==========
  Future<User?> getCurrentUser() async {
    final url = Uri.parse('$baseUrl/auth/me');
    final token = await _storage.getAccessToken();

    if (token == null) return null;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final user = User.fromJson(responseData['data']);
          await _storage.saveUser(user);
          return user;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // ========== LOGOUT ==========
  Future<bool> logout() async {
    final url = Uri.parse('$baseUrl/auth/logout');
    final token = await _storage.getAccessToken();

    try {
      if (token != null) {
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(timeout);
      }
    } catch (e) {
      // Continuar con logout local aunque falle el servidor
    }

    // Limpiar almacenamiento local
    await _storage.clearAll();
    return true;
  }

  // ========== FORGOT PASSWORD ==========
  Future<ApiResponse> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim().toLowerCase()}),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);

      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Error al enviar código',
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Tiempo de espera agotado',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error de conexión',
      );
    }
  }

  // ========== VERIFY RESET TOKEN ==========
  Future<ApiResponse> verifyResetToken(String token) async {
    final url = Uri.parse('$baseUrl/auth/verify-reset-token');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);

      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Código inválido',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al verificar código',
      );
    }
  }

  // ========== RESET PASSWORD ==========
  Future<ApiResponse> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);

      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Error al cambiar contraseña',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al cambiar contraseña',
      );
    }
  }

  // ========== CHANGE PASSWORD ==========
  Future<ApiResponse> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/auth/change-password');
    final token = await _storage.getAccessToken();

    if (token == null) {
      return ApiResponse(
        success: false,
        message: 'No autenticado',
      );
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(timeout);

      final responseData = jsonDecode(response.body);

      return ApiResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Error al cambiar contraseña',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error al cambiar contraseña',
      );
    }
  }

  // ========== HELPERS ==========
  Future<bool> isAuthenticated() async {
    return await _storage.isAuthenticated();
  }

  Future<User?> getStoredUser() async {
    return await _storage.getUser();
  }
}
