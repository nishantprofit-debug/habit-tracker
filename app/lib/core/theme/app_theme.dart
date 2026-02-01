import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Theme - Minimalist Black, Grey, White Design
class AppTheme {
  AppTheme._();

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.black,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.black,
        secondary: AppColors.grey700,
        surface: AppColors.white,
        error: AppColors.grey800,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.grey900,
        onError: AppColors.white,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(
          color: AppColors.black,
          size: 24,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.grey900,
          fontFamily: 'Inter',
        ),
        displayMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppColors.grey900,
          fontFamily: 'Inter',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
          fontFamily: 'Inter',
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
          fontFamily: 'Inter',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
          fontFamily: 'Inter',
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.grey900,
          fontFamily: 'Inter',
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.grey800,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grey700,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.grey600,
          fontFamily: 'Inter',
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.grey900,
          fontFamily: 'Inter',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
          fontFamily: 'Inter',
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.grey600,
          fontFamily: 'Inter',
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey800),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey800, width: 2),
        ),
        hintStyle: const TextStyle(
          color: AppColors.grey500,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        labelStyle: const TextStyle(
          color: AppColors.grey700,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.grey300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Card Theme (removed for Flutter 3.24 compatibility)

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.black;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: AppColors.grey400, width: 1.5),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.black;
          }
          return AppColors.grey200;
        }),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // Dialog Theme (removed for Flutter 3.24 compatibility)

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: CircleBorder(),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey900,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.black,
        linearTrackColor: AppColors.grey200,
        circularTrackColor: AppColors.grey200,
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.white,
      scaffoldBackgroundColor: AppColors.grey900,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.white,
        secondary: AppColors.grey300,
        surface: AppColors.grey800,
        error: AppColors.grey400,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.grey100,
        onError: AppColors.black,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.grey900,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
