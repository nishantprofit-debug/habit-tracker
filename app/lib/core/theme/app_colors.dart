import 'package:flutter/material.dart';

/// App Colors - Minimalist Black, Grey, White Palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Grey Scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Semantic Colors (using greys)
  static const Color background = white;
  static const Color surface = grey50;
  static const Color surfaceVariant = grey100;
  static const Color border = grey300;
  static const Color divider = grey200;

  // Text Colors
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey700;
  static const Color textTertiary = grey600;
  static const Color textDisabled = grey400;
  static const Color textOnPrimary = white;

  // State Colors
  static const Color hover = grey100;
  static const Color pressed = grey200;
  static const Color focus = black;
  static const Color selected = grey100;

  // Status Colors (subtle greys)
  static const Color success = grey700;
  static const Color warning = grey600;
  static const Color error = grey800;
  static const Color info = grey600;

  // Chart/Progress Colors (gradient greys)
  static const List<Color> progressGradient = [
    grey800,
    grey600,
    grey400,
  ];

  // Category Colors (different grey shades for distinction)
  static const Color categoryLearning = grey800;
  static const Color categoryHealth = grey700;
  static const Color categoryProductivity = grey600;
  static const Color categoryPersonal = grey500;

  // Gamification & Accents
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color xpBarBackground = grey200;
  static const Color xpBarProgress = black;

  // Shadows
  static const Color shadowLight = Color(0x0D000000); // 5% opacity
  static const Color shadowMedium = Color(0x12000000); // 7% opacity
  static const Color shadowDark = Color(0x1A000000); // 10% opacity
  static const Color shadowExtraDark = Color(0x26000000); // 15% opacity
}
