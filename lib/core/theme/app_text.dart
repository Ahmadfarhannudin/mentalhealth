import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppText {
  static const String fontFamily = 'Nunito';

  static TextStyle displayLarge = const TextStyle(
    fontSize: 32, height: 1.2, fontWeight: FontWeight.w800,
    color: AppColors.textDark, letterSpacing: -0.5,
  );
  static TextStyle displayMedium = const TextStyle(
    fontSize: 26, height: 1.25, fontWeight: FontWeight.w800,
    color: AppColors.textDark, letterSpacing: -0.3,
  );
  static TextStyle titleLarge = const TextStyle(
    fontSize: 20, height: 1.3, fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static TextStyle titleMedium = const TextStyle(
    fontSize: 17, height: 1.35, fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static TextStyle titleSmall = const TextStyle(
    fontSize: 15, height: 1.4, fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16, height: 1.55, fontWeight: FontWeight.w400,
    color: AppColors.textBody,
  );
  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14.5, height: 1.55, fontWeight: FontWeight.w400,
    color: AppColors.textBody,
  );
  static TextStyle bodySmall = const TextStyle(
    fontSize: 13, height: 1.5, fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
  static TextStyle labelLarge = const TextStyle(
    fontSize: 15, height: 1.4, fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static TextStyle labelSmall = const TextStyle(
    fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );
  static TextStyle caption = const TextStyle(
    fontSize: 12, height: 1.45, fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
}
