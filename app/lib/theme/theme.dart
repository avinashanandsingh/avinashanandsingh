import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF5A2A82);
  static const Color accentGold = Color(0xFFD6A054);
  static const Color primaryLight = Color(0xFF8E6E95);
  static const Color primaryDark = Color(0xFF240F47);

  // Background Gradients
  static const Color gradientTop = Color(0xFF4A2396);
  static const Color gradientBottom = Color(0xFF331464);
  static const Color gradientGold = Color(0xFFEBC77B);

  // Surfaces
  static const Color cardBackground = Color(0xFFF7F9FA);
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);

  // Typography
  static const Color textPrimary = Color(0xFF240F47);
  static const Color textSecondary = Color(0xFF7A8B99);
  static const Color textHint = Color(0xFF9AA5B1);

  static const Color textPrimaryDark = Color(0xFFF3D5B9);
  static const Color textSecondaryDark = Color(0xFFEDC8A6);
  static const Color error = Colors.red;
}

class AppTheme {
  static TextStyle get errorStyle => GoogleFonts.montserrat(
    color: AppColors.error,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.only(top: 8),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIconColor: AppColors.textHint,
        suffixIconColor: AppColors.textHint,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorStyle: GoogleFonts.montserrat(
          color: AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.cinzel(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.cinzel(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          fontSize: 28,
        ),
        headlineSmall: GoogleFonts.cinzel(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          fontSize: 24,
        ),
        displayLarge: GoogleFonts.cinzel(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          fontSize: 24,
        ),
        displayMedium: GoogleFonts.cinzel(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          fontSize: 20,
        ),
        displaySmall: GoogleFonts.cinzel(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          fontSize: 16,
        ),
        titleLarge: GoogleFonts.montserrat(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        titleMedium: GoogleFonts.montserrat(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        titleSmall: GoogleFonts.montserrat(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        bodyLarge: GoogleFonts.montserrat(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
        bodyMedium: GoogleFonts.montserrat(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodySmall: GoogleFonts.montserrat(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.montserrat(
          color: AppColors.textPrimary,
          fontSize: 24,
        ),
        labelMedium: GoogleFonts.montserrat(
          color: AppColors.textPrimary,
          fontSize: 18,
        ),
        labelSmall: GoogleFonts.montserrat(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary:
            AppColors.accentGold, // Accent looks better as primary in dark mode
        surface: AppColors.cardBackgroundDark,
        onSurface: AppColors.textPrimaryDark,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.accentGold),
        titleTextStyle: TextStyle(
          color: AppColors.accentGold,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIconColor: AppColors.textHint,
        suffixIconColor: AppColors.textHint,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withAlpha(100)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentGold),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.inter(
              color: AppColors.accentGold,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            titleMedium: GoogleFonts.inter(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: GoogleFonts.inter(color: AppColors.textSecondaryDark),
          ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }
}
