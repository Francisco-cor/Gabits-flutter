import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color primaryAppColor = Color(0xFF2D3748);
  static const Color accentColor = Color(0xFF4FD1C5);
  static const Color mainBackgroundColor = Colors.white;
  static const Color cardBackgroundColor = Colors.white;
  static const Color onPrimaryColor = Colors.white;
  static const Color darkText = Color(0xFF1A202C);
  static const Color lightText = Color(0xFF718096);
  static const String preferredFontFamily = '.SF UI Text';

  static const Color fabBackgroundColor = Color(0xFF1A202C);
  static const Color fabForegroundColor = Colors.white;

  // Dark theme colors — charcoal and white/gray emphasis
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkPrimary = Colors.white;
  static const Color darkOnPrimary = Color(0xFF121212);
  static const Color darkOnBg = Color(0xFFE2E8F0);
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF334155);
  static const Color darkFabBg = Colors.white;
  static const Color darkFabFg = Color(0xFF121212);

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

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: preferredFontFamily,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        secondary: Colors.grey.shade300,
        onSecondary: darkOnPrimary,
        error: const Color(0xFFFC8181),
        onError: darkBg,
        background: darkBg,
        onBackground: darkOnBg,
        surface: darkSurface,
        onSurface: darkOnBg,
        primaryContainer: darkPrimary.withAlpha((255 * 0.1).round()),
        onPrimaryContainer: darkPrimary,
        secondaryContainer: Colors.grey.shade400.withAlpha((255 * 0.1).round()),
        onSecondaryContainer: Colors.grey.shade300,
        tertiaryContainer: darkSurfaceVariant,
        onTertiaryContainer: darkOnBg,
        surfaceVariant: darkSurfaceVariant,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkOutline,
        outlineVariant: darkSurfaceVariant,
        shadow: Colors.black.withAlpha((255 * 0.5).round()),
        scrim: Colors.black.withAlpha((255 * 0.7).round()),
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: darkBg,
        foregroundColor: darkOnBg,
        iconTheme: const IconThemeData(color: darkPrimary, size: 24.0),
        actionsIconTheme: const IconThemeData(color: darkPrimary, size: 24.0),
        titleTextStyle: TextStyle(
          fontFamily: preferredFontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkOnBg,
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: CardThemeData(
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: darkSurface,
        shadowColor: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkFabBg,
          foregroundColor: darkFabFg,
          elevation: 4.0,
          hoverElevation: 6.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          extendedTextStyle: const TextStyle(
              fontFamily: preferredFontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: darkFabFg)),
      dividerColor: darkSurfaceVariant,
      dialogBackgroundColor: darkSurface,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: darkOnSurfaceVariant),
        hintStyle: TextStyle(color: darkOnSurfaceVariant.withAlpha(150)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkPrimary;
          return darkOnSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimary.withAlpha((255 * 0.3).round());
          }
          return darkSurfaceVariant;
        }),
      ),
    );
  }
}
