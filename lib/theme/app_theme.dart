// ============================================================
// app_theme.dart
// All colours, text styles, and reusable decoration styles
// live here so the entire app looks consistent.
// ============================================================

import 'package:flutter/material.dart';

class AppTheme {
  // --- Brand colours ---
  static const Color primaryBlue   = Color(0xFF4FC3F7);
  static const Color deepBlue      = Color(0xFF0288D1);
  static const Color accentYellow  = Color(0xFFFFD54F);
  static const Color backgroundLight = Color(0xFFF0F8FF);

  // --- Text colours ---
  static const Color textPrimary   = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF546E7A);

  // --- Card shadow ---
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.07),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  // --- The main app ThemeData ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Primary colour seed — Flutter will generate a full colour scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      // Cards have no elevation — we use boxShadow manually instead
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      // AppBars are transparent — each screen draws its own gradient
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
