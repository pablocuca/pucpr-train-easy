import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF081613);
  static const surface = Color(0xFF0F2B22);
  static const surface2 = Color(0xFF173A30);
  static const accent = Color(0xFF00E676);
  static const accentVariant = Color(0xFF00C35A);
  static const textPrimary = Color(0xFFEAF8F2);
  static const textSecondary = Color(0xFF9DB9A8);
  static const muted = Color(0xFF2B6A55);
  static const error = Color(0xFFFF6B6B);
}

class AppSpacing {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 24.0;
  static const s6 = 32.0;
}

class AppRadius {
  static const r1 = 6.0;
  static const r2 = 12.0;
  static const r3 = 24.0;
}

class AppTypography {
  static const String fontFamily = 'Inter';
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}

ThemeData buildTrainEasyTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.muted,
      surface: AppColors.surface,
      onPrimary: AppColors.background,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: const TextTheme(
      headlineMedium: AppTypography.h1,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.caption,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r2)),
      ),
    ),
  );
}
