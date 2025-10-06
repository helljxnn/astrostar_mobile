import 'package:flutter/material.dart';
import '../../../../core/alerts.dart';
import '../../auth/validators/auth_validators.dart';

/// Validadores específicos para el perfil de usuario
class EditProfileValidators {
  
  // =============================================================================
  // VALIDACIÓN DE NOMBRES
  // =============================================================================
  
  /// Valida el nombre del usuario
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    
    String name = value.trim();
    
    if (name.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (name.length > 50) {
      return 'El nombre no puede exceder 50 caracteres';
    }
    
    // No puede contener solo números
    if (RegExp(r'^[0-9]+$').hasMatch(name)) {
      return 'El nombre no puede contener solo números';
    }
    
    // No puede tener caracteres especiales excesivos
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]{2,}').hasMatch(name)) {
      return 'El nombre contiene caracteres no válidos';
    }
    
    return null;
  }
  
  /// Valida el apellido del usuario
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El apellido es requerido';
    }
    
    String lastName = value.trim();
    
    if (lastName.length < 2) {
      return 'El apellido debe tener al menos 2 caracteres';
    }
    
    if (lastName.length > 50) {
      return 'El apellido no puede exceder 50 caracteres';
    }
    
    // No puede contener solo números
    if (RegExp(r'^[0-9]+$').hasMatch(lastName)) {
      return 'El apellido no puede contener solo números';
    }
    
    // No puede tener caracteres especiales excesivos
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]{2,}').hasMatch(lastName)) {
      return 'El apellido contiene caracteres no válidos';
    }
    
    return null;
  }
  
  // =============================================================================
  // VALIDACIÓN COMPLETA DE PERFIL
  // =============================================================================
  
  /// Valida todo el formulario de edición de perfil
  static Future<bool> validateProfileForm(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required String name,
    required String lastName,
    required String initialName,
    required String initialLastName,
    required int colorIndex,
    required int initialColorIndex,
    required String? currentPassword,
    required String? newPassword,
    required String? confirmPassword,
  }) async {
    // Validar formulario
    if (!formKey.currentState!.validate()) {
      AppAlerts.showError(
        context,
        'Por favor corrige los errores en el formulario',
        icon: Icons.error_outline_rounded,
      );
      return false;
    }

    // Verificar que haya cambios
    bool hasNameChanges = name.trim() != initialName || lastName.trim() != initialLastName;
    bool hasColorChange = colorIndex != initialColorIndex;
    bool isChangingPassword = newPassword != null && newPassword.isNotEmpty;

    if (!hasNameChanges && !hasColorChange && !isChangingPassword) {
      AppAlerts.showInfo(
        context,
        'No hay cambios para guardar',
        icon: Icons.info_outline_rounded,
      );
      return false;
    }

    // Si está cambiando contraseña, validar
    if (isChangingPassword) {
      bool passwordValid = await _validatePasswordChange(
        context,
        currentPassword: currentPassword ?? '',
        newPassword: newPassword,
        confirmPassword: confirmPassword ?? '',
      );
      
      if (!passwordValid) return false;
    }

    return true;
  }
  
  // =============================================================================
  // VALIDACIÓN DE CAMBIO DE CONTRASEÑA
  // =============================================================================
  
  static Future<bool> _validatePasswordChange(
    BuildContext context, {
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validar que ingresó la contraseña actual
    if (currentPassword.isEmpty) {
      AppAlerts.showError(
        context,
        'Debes ingresar tu contraseña actual',
        icon: Icons.lock_outline_rounded,
      );
      return false;
    }

    // Validar contraseña actual con usuario demo
    if (currentPassword != MockAuthData.password) {
      AppAlerts.showError(
        context,
        'La contraseña actual es incorrecta',
        icon: Icons.lock_outline_rounded,
      );
      return false;
    }

    // Validar que la nueva contraseña sea diferente
    if (newPassword == currentPassword) {
      AppAlerts.showWarning(
        context,
        'La nueva contraseña debe ser diferente a la actual',
        icon: Icons.lock_reset_rounded,
      );
      return false;
    }

    // Validar fortaleza de nueva contraseña
    final result = PasswordValidator.validateNewPassword(newPassword);
    if (!result.isValid) {
      AppAlerts.showError(
        context,
        result.errorMessage!,
        icon: Icons.lock_outline_rounded,
      );
      return false;
    }

    // Validar coincidencia
    final matchResult = PasswordValidator.validatePasswordMatch(newPassword, confirmPassword);
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
  
  // =============================================================================
  // VALIDACIÓN DE CONTRASEÑA ACTUAL (en tiempo real)
  // =============================================================================
  
  static String? validateCurrentPassword(String? value, {required bool isChangingPassword}) {
    if (isChangingPassword) {
      if (value == null || value.isEmpty) {
        return 'Ingrese su contraseña actual';
      }
    }
    return null;
  }
}