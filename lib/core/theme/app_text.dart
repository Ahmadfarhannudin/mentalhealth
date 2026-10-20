import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale for Tenang. One family, six roles, no decorative variants.
class AppText {
  // ── Display ────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 30,
    height: 1.18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.7,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 25,
    height: 1.22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );

  // ── Titles ─────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.2,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.1,
  );

  // ── Body ───────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.5,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // ── Labels ─────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12.5,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.1,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  /// Section label. Sentence case; the product does not shout.
  static const TextStyle overline = TextStyle(
    fontSize: 12.5,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.forestMid,
    letterSpacing: 0.2,
  );

  static const TextStyle quote = TextStyle(
    fontSize: 17,
    height: 1.65,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.textBody,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15.5,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.1,
  );
}
