import 'package:flutter/material.dart';
import 'api_service.dart';

/// Helper global para manejar token expirado
/// Uso: await TokenExpiredHandler.handle(context, () async { ... });
class TokenExpiredHandler {
  /// Ejecuta una función y maneja automáticamente TokenExpiredException
  ///
  /// Ejemplo:
  /// ```dart
  /// await TokenExpiredHandler.handle(context, () async {
  ///   final data = await _service.fetchData();
  ///   setState(() => _data = data);
  /// });
  /// ```
  static Future<T?> handle<T>(
    BuildContext context,
    Future<T> Function() action, {
    String? customMessage,
  }) async {
    try {
      return await action();
    } on TokenExpiredException {
      if (context.mounted) {
        // Redirigir al login
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);

        // Mostrar mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              customMessage ??
                  'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  /// Versión sin retorno para funciones void
  ///
  /// Ejemplo:
  /// ```dart
  /// await TokenExpiredHandler.handleVoid(context, () async {
  ///   await _service.updateData();
  /// });
  /// ```
  static Future<void> handleVoid(
    BuildContext context,
    Future<void> Function() action, {
    String? customMessage,
  }) async {
    await handle(context, action, customMessage: customMessage);
  }
}
