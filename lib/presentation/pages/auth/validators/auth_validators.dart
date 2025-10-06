// lib/presentation/pages/auth/auth_validators.dart
import 'package:flutter/material.dart';
import '../../../../core/alerts.dart';

// =============================================================================
// RESULTADO DE VALIDACIÓN
// =============================================================================
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? extra;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.extra,
  });

  factory ValidationResult.success([Map<String, dynamic>? extra]) {
    return ValidationResult(isValid: true, extra: extra);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult(isValid: false, errorMessage: message);
  }
}

// =============================================================================
// VALIDADORES DE EMAIL
// =============================================================================
class EmailValidator {
  static ValidationResult validate(String email, {String? contextType}) {
    // Verificar que no esté vacío
    if (email.isEmpty) {
      return ValidationResult.error(
        contextType == "reset"
            ? 'Ingrese un correo electrónico válido'
            : 'Las credenciales ingresadas no son válidas',
      );
    }

    // Sanitizar (limpiar espacios y pasar a minúsculas)
    email = email.trim().toLowerCase();

    // Validar longitud máxima
    if (email.length > 254) {
      return ValidationResult.error(
        contextType == "reset"
            ? 'Ingrese un correo electrónico válido'
            : 'Las credenciales ingresadas no son válidas',
      );
    }

    // Validar formato (regex)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.error(
        contextType == "reset"
            ? 'Ingrese un correo electrónico válido'
            : 'Las credenciales ingresadas no son válidas',
      );
    }

    // Validar dominios sospechosos (sin revelar al usuario)
    final suspiciousDomains = [
      'tempmail.org',
      '10minutemail.com',
      'guerrillamail.com',
    ];
    String domain = email.split('@').last;
    if (suspiciousDomains.contains(domain)) {
      return ValidationResult.error(
        contextType == "reset"
            ? 'Ingrese un correo electrónico válido'
            : 'Las credenciales ingresadas no son válidas',
      );
    }

    // Si pasa todas las validaciones
    return ValidationResult.success({'sanitizedEmail': email});
  }

  // Validación en tiempo real para UI
  static String? validateRealTime(String email) {
    if (email.isEmpty) return null;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Formato de correo inválido';
    }

    return null;
  }
}

// =============================================================================
// VALIDADORES DE CONTRASEÑA
// =============================================================================
class PasswordValidator {
  // Para login (menos estricto)
  static ValidationResult validateLogin(String password) {
    if (password.isEmpty || password.length < 6) {
      return ValidationResult.error(
        'Las credenciales ingresadas no son válidas',
      );
    }

    return ValidationResult.success();
  }

  // Para nueva contraseña (más estricto)
  static ValidationResult validateNewPassword(String password) {
    if (password.isEmpty) {
      return ValidationResult.error('La contraseña es requerida');
    }

    Map<String, bool> criteria = {
      'minLength': password.length >= 8,
      'maxLength': password.length <= 128,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumber': password.contains(RegExp(r'[0-9]')),
      'hasSpecialChar': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      'noCommonPatterns': !_isCommonPassword(password),
    };

    List<String> errors = [];
    if (!criteria['minLength']!) errors.add('Mínimo 8 caracteres');
    if (!criteria['maxLength']!) errors.add('Máximo 128 caracteres');
    if (!criteria['hasUppercase']!) errors.add('Al menos una letra mayúscula');
    if (!criteria['hasLowercase']!) errors.add('Al menos una letra minúscula');
    if (!criteria['hasNumber']!) errors.add('Al menos un número');
    if (!criteria['hasSpecialChar']!) {
      errors.add('Al menos un carácter especial');
    }
    if (!criteria['noCommonPatterns']!) {
      errors.add('Evite contraseñas muy comunes');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.error(errors.first);
    }

    int strength = criteria.values.where((v) => v).length;
    return ValidationResult.success({
      'criteria': criteria,
      'strength': strength,
      'strengthText': _getStrengthText(strength),
    });
  }

  static ValidationResult validatePasswordMatch(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return ValidationResult.error('Por favor confirme su contraseña');
    }

    if (password != confirmPassword) {
      return ValidationResult.error('Las contraseñas no coinciden');
    }

    return ValidationResult.success();
  }

  static bool _isCommonPassword(String password) {
    final commonPasswords = [
      'password',
      '12345678',
      'qwerty123',
      'abc12345',
      '11111111',
      '00000000',
      'password123',
      'admin123',
      '123456789',
      'welcome123',
      'letmein123',
    ];
    return commonPasswords.contains(password.toLowerCase());
  }

  static String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
      case 2:
        return "Muy débil";
      case 3:
      case 4:
        return "Débil";
      case 5:
        return "Regular";
      case 6:
        return "Fuerte";
      case 7:
        return "Muy fuerte";
      default:
        return "Muy débil";
    }
  }

  // Validación en tiempo real para UI
  static Map<String, dynamic> validateRealTime(String password) {
    final criteria = {
      'minLength': password.length >= 8,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumber': password.contains(RegExp(r'[0-9]')),
      'hasSpecialChar': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };

    final strength = criteria.values.where((v) => v).length;

    return {
      'criteria': criteria,
      'strength': strength,
      'strengthText': _getStrengthText(strength),
      'isValid': password.length >= 8,
    };
  }

  // Validación simple para coincidencia en tiempo real
  static String? validateMatchRealTime(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) return null;
    if (password != confirmPassword) return 'Las contraseñas no coinciden';
    return null;
  }
}

// =============================================================================
// VALIDADORES DE CÓDIGO
// =============================================================================
class CodeValidator {
  static ValidationResult validateSingleDigit(String digit) {
    if (digit.isEmpty) return ValidationResult.success();

    if (digit.length > 1) {
      return ValidationResult.error('Solo un dígito por campo');
    }

    if (!RegExp(r'^[0-9]$').hasMatch(digit)) {
      return ValidationResult.error('Solo se permiten números');
    }

    return ValidationResult.success();
  }

  static ValidationResult validateCompleteCode(List<String> codeDigits) {
    if (codeDigits.any((digit) => digit.isEmpty)) {
      return ValidationResult.error(
        'Por favor complete todos los campos del código',
      );
    }

    if (codeDigits.any((digit) => !RegExp(r'^[0-9]$').hasMatch(digit))) {
      return ValidationResult.error('El código solo debe contener números');
    }

    String completeCode = codeDigits.join();
    if (completeCode.length != 4) {
      return ValidationResult.error(
        'El código debe tener exactamente 4 dígitos',
      );
    }

    return ValidationResult.success({'code': completeCode});
  }

  // Para autofocus automático entre campos
  static bool shouldMoveNext(String digit, int currentIndex, int totalDigits) {
    return digit.isNotEmpty && currentIndex < totalDigits - 1;
  }

  static bool shouldMovePrevious(String digit, int currentIndex) {
    return digit.isEmpty && currentIndex > 0;
  }
}

// =============================================================================
// UTILIDADES GENERALES
// =============================================================================
class AuthUtils {
  // Sanitizar inputs
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Sanitizar email específico
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // Validar rate limiting
  static bool isRateLimited(DateTime? lastAttempt, int cooldownMinutes) {
    if (lastAttempt == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastAttempt).inMinutes;
    return difference < cooldownMinutes;
  }

  // Obtener minutos restantes
  static int getRemainingCooldown(DateTime? lastAttempt, int cooldownMinutes) {
    if (lastAttempt == null) return 0;

    final now = DateTime.now();
    final difference = now.difference(lastAttempt).inMinutes;
    final remaining = cooldownMinutes - difference;
    return remaining > 0 ? remaining : 0;
  }

  // Simular validación de conexión
  static Future<bool> hasInternetConnection() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // En producción usar connectivity_plus
  }
}

// =============================================================================
// VALIDADORES DE FORMULARIOS COMPLETOS
// =============================================================================
class AuthFormValidators {
  // Validar formulario de login
  static Future<bool> validateLoginForm(
    BuildContext context,
    String email,
    String password, {
    DateTime? lastAttempt,
  }) async {
    // Validar usuario quemado (temporal, sin backend)
    if (email != MockAuthData.email || password != MockAuthData.password) {
      AppAlerts.showError(
        context,
        'Las credenciales ingresadas no son válidas',
      );
      return false;
    }

    // Validar rate limiting
    if (AuthUtils.isRateLimited(lastAttempt, 5)) {
      final remaining = AuthUtils.getRemainingCooldown(lastAttempt, 5);
      AppAlerts.showRateLimit(context, remaining);
      return false;
    }

    // Validar conexión
    if (!await AuthUtils.hasInternetConnection()) {
      AppAlerts.showNoConnection(context);
      return false;
    }

    // Sanitizar inputs
    email = AuthUtils.sanitizeEmail(email);
    password = AuthUtils.sanitizeInput(password);

    // Validar email
    final emailResult = EmailValidator.validate(email);
    if (!emailResult.isValid) {
      AppAlerts.showError(context, emailResult.errorMessage!);
      return false;
    }

    // Validar password
    final passwordResult = PasswordValidator.validateLogin(password);
    if (!passwordResult.isValid) {
      AppAlerts.showError(context, passwordResult.errorMessage!);
      return false;
    }

    return true;
  }

  // Validar formulario de reset password
  static Future<bool> validateResetForm(
    BuildContext context,
    String email, {
    DateTime? lastAttempt,
  }) async {
    // Validar rate limiting
    if (AuthUtils.isRateLimited(lastAttempt, 2)) {
      final remaining = AuthUtils.getRemainingCooldown(lastAttempt, 2);
      AppAlerts.showRateLimit(context, remaining);
      return false;
    }

    // Validar conexión
    if (!await AuthUtils.hasInternetConnection()) {
      AppAlerts.showNoConnection(context);
      return false;
    }

    // Sanitizar input
    email = AuthUtils.sanitizeEmail(email);

    // Validar email
    final emailResult = EmailValidator.validate(email, contextType: "reset");
    if (!emailResult.isValid) {
      AppAlerts.showWarning(context, emailResult.errorMessage!);
      return false;
    }

    return true;
  }

  // Validar código
  static bool validateCodeForm(BuildContext context, List<String> codeDigits) {
    final codeResult = CodeValidator.validateCompleteCode(codeDigits);
    if (!codeResult.isValid) {
      AppAlerts.showError(
        context,
        codeResult.errorMessage!,
        icon: Icons.pin_rounded,
      );
      return false;
    }

    return true;
  }

  // Validar nueva contraseña
  static bool validateNewPasswordForm(
    BuildContext context,
    String newPassword,
    String confirmPassword,
  ) {
    // Sanitizar inputs
    newPassword = AuthUtils.sanitizeInput(newPassword);
    confirmPassword = AuthUtils.sanitizeInput(confirmPassword);

    // Validar nueva contraseña
    final passwordResult = PasswordValidator.validateNewPassword(newPassword);
    if (!passwordResult.isValid) {
      AppAlerts.showError(
        context,
        passwordResult.errorMessage!,
        icon: Icons.lock_outline_rounded,
      );
      return false;
    }

    // Validar coincidencia
    final matchResult = PasswordValidator.validatePasswordMatch(
      newPassword,
      confirmPassword,
    );
    if (!matchResult.isValid) {
      AppAlerts.showError(
        context,
        matchResult.errorMessage!,
        icon: Icons.lock_outline_rounded,
      );
      return false;
    }

    return true;
  }

  // Métodos para validación en tiempo real en UI
  static String? validateEmailRealTime(String email) {
    return EmailValidator.validateRealTime(email);
  }

  static Map<String, dynamic> validatePasswordRealTime(String password) {
    return PasswordValidator.validateRealTime(password);
  }

  static String? validatePasswordMatchRealTime(
    String password,
    String confirmPassword,
  ) {
    return PasswordValidator.validateMatchRealTime(password, confirmPassword);
  }

  // Verificar si un formulario está listo para enviar
  static bool isLoginFormReady(String email, String password) {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= 6 &&
        EmailValidator.validateRealTime(email) == null;
  }

  static bool isResetFormReady(String email) {
    return email.isNotEmpty && EmailValidator.validateRealTime(email) == null;
  }

  static bool isCodeFormReady(List<String> codeDigits) {
    return codeDigits.every((digit) => digit.isNotEmpty) &&
        codeDigits.length == 4;
  }

  static bool isNewPasswordFormReady(
    String newPassword,
    String confirmPassword,
  ) {
    final passwordValidation = PasswordValidator.validateRealTime(newPassword);
    return passwordValidation['isValid'] &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword;
  }
}

// =============================================================================
// DATOS QUEMADOS DE AUTENTICACIÓN (USUARIO DE DEMO)
// =============================================================================
class MockAuthData {
  static const String email = 'astrostarmovil@gmail.com';
  static const String password = 'Astrostar123!';
}
