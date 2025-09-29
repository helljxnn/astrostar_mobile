// lib/core/app_colors.dart
import 'package:flutter/material.dart';

/// Paleta de colores centralizada para toda la aplicación AstroStar
class AppColors {
  // ============================================================================
  // COLORES PRINCIPALES DE LA APP (originales)
  // ============================================================================
  static const primaryPurple = Color(0xFFB595FF);
  static const primaryPurpleLight = Color(0xFFD0BFFF);
  static const primaryBlue = Color(0xFF9BE9FF);
  static const primaryGreen = Color(0xFF95FFA7);
  static const primaryRed = Color(0xFFFC6D6D);
  static const primaryPink = Color(0xFFFF95D1);
  static const primaryYellow = Color(0xFFEDEB85);

  static const bg = Colors.white;
  static const textDark = Color(0xFF212121);
  static const muted = Color(0xFF9E9E9E);

  // ============================================================================
  // COLORES PARA MÓDULO DE AUTENTICACIÓN (Auth/Login)
  // ============================================================================
  static const authPrimaryColor = Color(0xFF8B5CF6);
  static const authPrimaryLight = Color(0xFFA78BFA);
  static const authAccentColor = Color(0xFFF3F4F6);
  static const authBackgroundColor = Color(0xFFFCFCFD);
  static const authTextColor = Color(0xFF1F2937);
  static const authTextLight = Color(0xFF9CA3AF);
  static const authSurfaceColor = Color(0xFFFFFFFF);

  // ============================================================================
  // COLORES PARA ALERTAS GLOBALES (Sistema de SnackBars)
  // ============================================================================
  static const alertSuccessColor = Color(0xFF86EFAC); // Verde pastel claro
  static const alertErrorColor = Color(0xFFFCA5A5);   // Rojo pastel claro
  static const alertWarningColor = Color(0xFFFFEBA1); // Amarillo pastel
  static const alertInfoColor = Color(0xFFB0B6C2);    // Gris/azul pastel
  static const alertTextColor = Color(0xFF1F2937);    // Texto oscuro para alertas

  // ============================================================================
  // COLORES PARA AVATARS DE USUARIO
  // ============================================================================
  static const avatarColors = [
    Color(0xFF6C5CE7), // Púrpura
    Color(0xFF74B9FF), // Azul
    Color(0xFFFF6B95), // Rosa
    Color(0xFFFDCB6E), // Amarillo
    Color(0xFF00B894), // Verde
    Color(0xFFFD79A8), // Rosa fuerte
  ];
}