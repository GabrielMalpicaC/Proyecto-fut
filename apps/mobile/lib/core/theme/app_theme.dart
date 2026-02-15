import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF78FFB1),
      secondary: Color(0xFF58D68D),
      surface: Color(0xFF121526),
      onSurface: Colors.white,
      onPrimary: Color(0xFF09101C),
    ),
    scaffoldBackgroundColor: const Color(0xFF0A0D1A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F1324),
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0F1324),
      indicatorColor: const Color(0xFF78FFB1).withOpacity(0.16),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? const Color(0xFF78FFB1) : Colors.white70,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF151A30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: const BorderSide(color: Color(0xFF2B335B)),
      backgroundColor: const Color(0xFF11162A),
      selectedColor: const Color(0xFF78FFB1).withOpacity(0.18),
      labelStyle: const TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2B335B)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2B335B)),
      ),
      filled: true,
      fillColor: const Color(0xFF12182E),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF4D67),
      foregroundColor: Colors.white,
    ),
  );
}
