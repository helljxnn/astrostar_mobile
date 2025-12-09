import 'user_model.dart';

class AuthResponse {
  final bool success;
  final AuthData? data;
  final String message;

  AuthResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}

class AuthData {
  final User user;
  final String accessToken;

  AuthData({
    required this.user,
    required this.accessToken,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: User.fromJson(json['user']),
      accessToken: json['accessToken'],
    );
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
    );
  }
}
