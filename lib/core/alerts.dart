// lib/core/alerts.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistema de alertas global para toda la aplicación AstroStar
/// 
/// Uso básico:
/// ```dart
/// AppAlerts.showSuccess(context, '¡Operación exitosa!');
/// AppAlerts.showError(context, 'Algo salió mal');
/// AppAlerts.showWarning(context, 'Ten cuidado');
/// AppAlerts.showInfo(context, 'Información importante');
/// ```
class AppAlerts {
  // ============================================================================
  // COLORES ESPECÍFICOS PARA ALERTAS (referenciados desde AppColors)
  // ============================================================================
  static const Color successColor = AppColors.alertSuccessColor; // Verde pastel
  static const Color errorColor = AppColors.alertErrorColor;     // Rojo pastel
  static const Color warningColor = AppColors.alertWarningColor; // Amarillo pastel
  static const Color infoColor = AppColors.alertInfoColor;       // Gris/azul pastel

  // ============================================================================
  // SNACKBAR BASE (PRIVADO)
  // ============================================================================
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: AppColors.alertTextColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.alertTextColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: duration,
      ),
    );
  }

  // ============================================================================
  // ALERTAS BÁSICAS
  // ============================================================================

  /// Muestra una alerta de ERROR (rojo pastel)
  static void showError(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: errorColor,
      icon: icon ?? Icons.error_outline_rounded,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Muestra una alerta de ADVERTENCIA (amarillo pastel)
  static void showWarning(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: warningColor,
      icon: icon ?? Icons.warning_rounded,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Muestra una alerta de ÉXITO (verde pastel)
  static void showSuccess(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: successColor,
      icon: icon ?? Icons.check_circle_rounded,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Muestra una alerta de INFORMACIÓN (gris/azul pastel)
  static void showInfo(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: infoColor,
      icon: icon ?? Icons.info_outline_rounded,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // ============================================================================
  // ALERTAS ESPECÍFICAS - AUTENTICACIÓN
  // ============================================================================

  /// Alerta de bienvenida al iniciar sesión
  static void showLoginSuccess(BuildContext context) {
    showSuccess(
      context,
      '¡Bienvenido a AstroStar!',
      icon: Icons.rocket_launch_rounded,
    );
  }

  /// Alerta de contraseña actualizada
  static void showPasswordUpdated(BuildContext context) {
    showSuccess(
      context,
      'Contraseña actualizada exitosamente',
      icon: Icons.lock_reset_rounded,
    );
  }

  /// Alerta de código enviado
  static void showCodeSent(BuildContext context, String maskedEmail) {
    showInfo(
      context,
      'Código enviado a $maskedEmail',
      icon: Icons.email_rounded,
    );
  }

  /// Alerta de código verificado
  static void showCodeVerified(BuildContext context) {
    showSuccess(
      context,
      'Código verificado correctamente',
      icon: Icons.verified_rounded,
    );
  }

  /// Alerta de código reenviado
  static void showCodeResent(BuildContext context) {
    showInfo(
      context,
      'Nuevo código enviado exitosamente',
      icon: Icons.refresh_rounded,
    );
  }

  /// Alerta de sin conexión a internet
  static void showNoConnection(BuildContext context) {
    showError(
      context,
      'Sin conexión a internet',
      icon: Icons.wifi_off_rounded,
    );
  }

  /// Alerta de rate limiting (demasiados intentos)
  static void showRateLimit(BuildContext context, int minutesLeft) {
    showWarning(
      context,
      'Demasiados intentos. Intente en $minutesLeft minuto(s)',
      icon: Icons.timer_rounded,
    );
  }

  // ============================================================================
  // ALERTAS ESPECÍFICAS - EVENTOS
  // ============================================================================

  /// Alerta de evento guardado
  static void showEventSaved(BuildContext context) {
    showSuccess(
      context,
      'Evento guardado exitosamente',
      icon: Icons.event_available_rounded,
    );
  }

  /// Alerta de evento eliminado
  static void showEventDeleted(BuildContext context) {
    showSuccess(
      context,
      'Evento eliminado',
      icon: Icons.delete_outline_rounded,
    );
  }

  /// Alerta de evento actualizado
  static void showEventUpdated(BuildContext context) {
    showSuccess(
      context,
      'Evento actualizado correctamente',
      icon: Icons.update_rounded,
    );
  }

  // ============================================================================
  // ALERTAS GENÉRICAS REUTILIZABLES
  // ============================================================================

  /// Alerta de operación exitosa genérica
  static void showOperationSuccess(BuildContext context, String operation) {
    showSuccess(
      context,
      '$operation exitoso',
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Alerta de error de operación genérica
  static void showOperationError(BuildContext context, String operation) {
    showError(
      context,
      'Error al $operation',
      icon: Icons.error_outline_rounded,
    );
  }

  /// Alerta de función no disponible
  static void showNotAvailable(BuildContext context) {
    showInfo(
      context,
      'Esta función estará disponible pronto',
      icon: Icons.construction_rounded,
    );
  }

  /// Alerta de carga en progreso
  static void showLoading(BuildContext context, String message) {
    showInfo(
      context,
      message,
      icon: Icons.hourglass_empty_rounded,
    );
  }

  // ============================================================================
  // UTILIDAD PARA FORMATEAR EMAILS (útil para alertas)
  // ============================================================================

  /// Formatea un email para mostrarlo enmascarado
  /// Ejemplo: 'astrostarmovil@gmail.com' -> 'a***l@gmail.com'
  static String formatEmailForDisplay(String email) {
    try {
      final parts = email.split('@');
      if (parts.length != 2) return email;

      final username = parts[0];
      final domain = parts[1];

      if (username.length <= 2) return email;

      final maskedUsername =
          username[0] + '***' + username[username.length - 1];
      return '$maskedUsername@$domain';
    } catch (e) {
      return email;
    }
  }
}