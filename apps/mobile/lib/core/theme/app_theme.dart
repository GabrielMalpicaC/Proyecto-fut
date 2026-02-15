import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF10B981),
      primary: const Color(0xFF16A34A),
      secondary: const Color(0xFF22C55E),
      tertiary: const Color(0xFFFACC15),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF0FDF4),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF15803D),
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}
