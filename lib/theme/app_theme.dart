import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales de la aplicación
  static const Color primaryAppColor = Color(0xFF2D3748);
  static const Color accentColor = Color(0xFF4FD1C5);
  static const Color mainBackgroundColor = Colors.white;
  static const Color cardBackgroundColor = Colors.white;
  static const Color onPrimaryColor = Colors.white;
  static const Color darkText = Color(0xFF1A202C);
  static const Color lightText = Color(0xFF718096);
  static const String preferredFontFamily = '.SF UI Text';

  // Nuevos colores para el FAB
  static const Color fabBackgroundColor = Color(0xFF1A202C);
  static const Color fabForegroundColor = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: preferredFontFamily,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryAppColor,
        onPrimary: onPrimaryColor,
        secondary: accentColor,
        onSecondary: Colors.black,
        error: Colors.red.shade700,
        onError: Colors.white,
        background: mainBackgroundColor,
        onBackground: darkText,
        surface: cardBackgroundColor,
        onSurface: darkText,
        primaryContainer: primaryAppColor.withAlpha((255 * 0.1).round()),
        onPrimaryContainer: primaryAppColor,
        secondaryContainer: accentColor.withAlpha((255 * 0.15).round()),
        onSecondaryContainer: accentColor,
        tertiaryContainer: Colors.blueGrey.shade50,
        onTertiaryContainer: Colors.blueGrey.shade900,
        surfaceVariant: Colors.grey.shade100,
        onSurfaceVariant: lightText,
        outline: Colors.grey.shade400,
        outlineVariant: Colors.grey.shade300,
        shadow: Colors.black.withAlpha((255 * 0.05).round()),
        scrim: Colors.black.withAlpha((255 * 0.3).round()),
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: mainBackgroundColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: mainBackgroundColor,
        foregroundColor: darkText,
        iconTheme: IconThemeData(color: primaryAppColor, size: 24.0),
        actionsIconTheme: IconThemeData(color: primaryAppColor, size: 24.0),
        titleTextStyle: TextStyle(
          fontFamily: preferredFontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: CardThemeData(
        elevation: 1.5,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: cardBackgroundColor,
        shadowColor: Colors.black.withAlpha((255 * 0.03).round()),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: fabBackgroundColor,
          foregroundColor: fabForegroundColor,
          elevation: 4.0,
          hoverElevation: 6.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          extendedTextStyle: const TextStyle(
              fontFamily: preferredFontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: fabForegroundColor)),
    );
  }
}
