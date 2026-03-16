import 'dart:io';
import 'package:flutter/foundation.dart';

/// Enumeración de ambientes disponibles
enum Environment { development, staging, production }

/// Configuración centralizada de la aplicación
/// Maneja URLs del API según el ambiente y plataforma
class AppConfig {
  // Ambiente actual (por defecto desarrollo)
  static Environment _environment = Environment.development;

  /// Configura el ambiente de la aplicación
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  /// URL base del API - Prioriza dart-define sobre configuración por ambiente
  static String get apiBaseUrl {
    // PRIORIDAD 1: Usar --dart-define si está disponible
    // Ejemplo: flutter run --dart-define=API_URL=http://192.168.1.100:4000
    const apiUrl = String.fromEnvironment('API_URL');
    if (apiUrl.isNotEmpty) {
      return apiUrl;
    }

    // PRIORIDAD 2: Usar configuración según ambiente
    return _getUrlByEnvironment();
  }

  /// Obtiene la URL según el ambiente configurado
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

  /// URL de desarrollo - Detecta automáticamente la plataforma
  static String _getDevelopmentUrl() {
    if (kIsWeb) {
      // Web siempre usa localhost
      return 'http://localhost:4000/api';
    }

    try {
      if (Platform.isAndroid) {
        // Para dispositivos físicos Android, usar IP de la red local
        // Para emuladores, usar 10.0.2.2
        // IMPORTANTE: Cambia esta IP por la de tu computadora
        return 'http://192.168.1.66:4000/api'; // IP de tu PC
      } else if (Platform.isIOS) {
        // Para dispositivos físicos iOS, usar IP de la red local
        // Para simuladores, usar localhost
        return 'http://192.168.1.66:4000/api'; // IP de tu PC
      }
    } catch (e) {
      // Fallback si falla la detección de plataforma
    }

    // Fallback general
    return 'http://192.168.1.66:4000/api';
  }

  // ========== HELPERS ==========

  /// Verifica si estamos en producción
  static bool get isProduction => _environment == Environment.production;

  /// Verifica si estamos en desarrollo
  static bool get isDevelopment => _environment == Environment.development;

  /// Verifica si estamos en staging
  static bool get isStaging => _environment == Environment.staging;

  /// Nombre del ambiente actual
  static String get environmentName => _environment.name;

  /// Timeout para peticiones HTTP (más largo en desarrollo para debugging)
  static Duration get httpTimeout {
    return isDevelopment
        ? const Duration(seconds: 30)
        : const Duration(seconds: 10);
  }
}
