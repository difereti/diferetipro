import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

class BrandColors {
  static const primary = Color(0xFFFC7B03); // Orange
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const darkGrey = Color(0xFF1A1A1A);
  static const lightGrey = Color(0xFFF5F5F5);
}

class LightModeColors {
  static const primary = BrandColors.primary;
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFFFFDCC2);
  static const onPrimaryContainer = Color(0xFF3E1C00);

  static const secondary = Color(0xFF1A1A1A);
  static const onSecondary = Colors.white;

  static const background = Color(0xFFF8F9FA);
  static const surface = Colors.white;
  static const onSurface = Colors.black87;
  
  static const error = Color(0xFFBA1A1A);
  static const outline = Color(0xFF79747E);
}

class DarkModeColors {
  static const primary = BrandColors.primary;
  static const onPrimary = Colors.black;
  static const primaryContainer = Color(0xFF5C2B00);
  static const onPrimaryContainer = Color(0xFFFFDCC2);

  static const secondary = Colors.white;
  static const onSecondary = Colors.black;

  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const onSurface = Color(0xFFE2E2E2);
  
  static const error = Color(0xFFFFB4AB);
  static const outline = Color(0xFF938F99);
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: LightModeColors.primary,
    onPrimary: LightModeColors.onPrimary,
    primaryContainer: LightModeColors.primaryContainer,
    onPrimaryContainer: LightModeColors.onPrimaryContainer,
    secondary: LightModeColors.secondary,
    onSecondary: LightModeColors.onSecondary,
    surface: LightModeColors.surface,
    onSurface: LightModeColors.onSurface,
    error: LightModeColors.error,
    outline: LightModeColors.outline,
  ),
  scaffoldBackgroundColor: LightModeColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    foregroundColor: Colors.black,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
    ),
    color: LightModeColors.surface,
  ),
  textTheme: _buildTextTheme(Brightness.light),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BrandColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: BrandColors.primary),
    ),
    contentPadding: const EdgeInsets.all(16),
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: DarkModeColors.primary,
    onPrimary: DarkModeColors.onPrimary,
    primaryContainer: DarkModeColors.primaryContainer,
    onPrimaryContainer: DarkModeColors.onPrimaryContainer,
    secondary: DarkModeColors.secondary,
    onSecondary: DarkModeColors.onSecondary,
    surface: DarkModeColors.surface,
    onSurface: DarkModeColors.onSurface,
    error: DarkModeColors.error,
    outline: DarkModeColors.outline,
  ),
  scaffoldBackgroundColor: DarkModeColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
    ),
    color: DarkModeColors.surface,
  ),
  textTheme: _buildTextTheme(Brightness.dark),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BrandColors.primary,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: BrandColors.primary),
    ),
    contentPadding: const EdgeInsets.all(16),
  ),
);

TextTheme _buildTextTheme(Brightness brightness) {
  return TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600),
    headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
  );
}
