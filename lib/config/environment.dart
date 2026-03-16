import 'dart:io';
import 'package:flutter/foundation.dart';

/// Enumeracion de ambientes disponibles
enum Environment { development, staging, production }

/// Configuracion centralizada de la aplicacion
/// Maneja URLs del API segun el ambiente y plataforma
class AppConfig {
  // Ambiente actual (por defecto desarrollo)
  static Environment _environment = Environment.development;

  /// Configura el ambiente de la aplicacion
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  /// URL base del API - Prioriza dart-define sobre configuracion por ambiente
  static String get apiBaseUrl {
    // PRIORIDAD 1: Usar --dart-define si esta disponible
    // Ejemplo: flutter run --dart-define=API_URL=http://192.168.1.100:4000/api
    const apiUrl = String.fromEnvironment('API_URL');
    if (apiUrl.isNotEmpty) {
      return apiUrl;
    }

    // PRIORIDAD 2: Usar configuracion segun ambiente
    return _getUrlByEnvironment();
  }

  /// Obtiene la URL segun el ambiente configurado
  static String _getUrlByEnvironment() {
    switch (_environment) {
      case Environment.development:
        return _getDevelopmentUrl();
      case Environment.staging:
        return 'https://staging-api.astrostar.com/api';
      case Environment.production:
        return 'https://api.astrostar.com/api';
    }
  }

  /// URL de desarrollo - Detecta automaticamente la plataforma
  static String _getDevelopmentUrl() {
    if (kIsWeb) {
      return 'http://localhost:4000/api';
    }

    try {
      if (Platform.isAndroid) {
        // Emulator Android usa 10.0.2.2 hacia localhost del host.
        // En dispositivo fisico, usar --dart-define=API_URL=http://TU_IP:4000/api
        return const String.fromEnvironment(
          'ANDROID_API_URL',
          defaultValue: 'http://10.0.2.2:4000/api',
        );
      }

      if (Platform.isIOS) {
        // Simulador iOS usa localhost.
        // En dispositivo fisico, usar --dart-define=API_URL=http://TU_IP:4000/api
        return const String.fromEnvironment(
          'IOS_API_URL',
          defaultValue: 'http://localhost:4000/api',
        );
      }
    } catch (_) {
      // Fallback si falla la deteccion de plataforma.
    }

    return const String.fromEnvironment(
      'LOCAL_API_URL',
      defaultValue: 'http://localhost:4000/api',
    );
  }

  // ========== HELPERS ==========

  /// Verifica si estamos en produccion
  static bool get isProduction => _environment == Environment.production;

  /// Verifica si estamos en desarrollo
  static bool get isDevelopment => _environment == Environment.development;

  /// Verifica si estamos en staging
  static bool get isStaging => _environment == Environment.staging;

  /// Nombre del ambiente actual
  static String get environmentName => _environment.name;

  /// Timeout para peticiones HTTP (mas largo en desarrollo para debugging)
  static Duration get httpTimeout {
    return isDevelopment
        ? const Duration(seconds: 30)
        : const Duration(seconds: 10);
  }
}
