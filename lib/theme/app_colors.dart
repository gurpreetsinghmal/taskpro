import 'package:flutter/material.dart';

/// =======================================================
/// App Colors
/// TaskPro - Citizen Manager Worker App
/// =======================================================

class AppColors {
  AppColors._();

  //=======================================================
  // Brand Colors
  //=======================================================

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);

  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF93C5FD);

  //=======================================================
  // Background
  //=======================================================

  static const Color background = Color(0xFFF8FAFC);
  static const Color scaffold = Color(0xFFF1F5F9);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  //=======================================================
  // Borders
  //=======================================================

  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE5E7EB);

  //=======================================================
  // Text
  //=======================================================

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  //=======================================================
  // Status Colors
  //=======================================================

  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  //=======================================================
  // Dashboard Cards
  //=======================================================

  static const Color pending = Color(0xFFF59E0B);
  static const Color inProgress = Color(0xFF3B82F6);
  static const Color completed = Color(0xFF22C55E);
  static const Color rejected = Color(0xFFEF4444);

  //=======================================================
  // User Roles
  //=======================================================

  static const Color citizen = Color(0xFF2563EB);
  static const Color manager = Color(0xFF1E40AF);
  static const Color worker = Color(0xFF3B82F6);

  //=======================================================
  // Wallet
  //=======================================================

  static const Color income = Color(0xFF0B5A26);
  static const Color expense = Color(0xFFDC2626);

  //=======================================================
  // Charts
  //=======================================================

  static const Color chartBlue = Color(0xFF2563EB);
  static const Color chartGreen = Color(0xFF22C55E);
  static const Color chartOrange = Color(0xFFF59E0B);
  static const Color chartRed = Color(0xFFEF4444);
  static const Color chartPurple = Color(0xFF7C3AED);
  static const Color chartCyan = Color(0xFF06B6D4);

  //=======================================================
  // Button Colors
  //=======================================================

  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFFCBD5E1);

  //=======================================================
  // Icon Colors
  //=======================================================

  static const Color iconPrimary = primary;
  static const Color iconSecondary = Color(0xFF64748B);

  //=======================================================
  // Shadows
  //=======================================================

  static const Color shadow = Color(0x14000000);

  //=======================================================
  // Gradients
  //=======================================================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
    ],
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFC),
      Color(0xFFDBEAFE),
    ],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [
      Color(0xFF34D399),
      Color(0xFF16A34A),
    ],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [
      Color(0xFFFBBF24),
      Color(0xFFF59E0B),
    ],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [
      Color(0xFFF87171),
      Color(0xFFDC2626),
    ],
  );
}