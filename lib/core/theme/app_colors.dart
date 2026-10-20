import 'package:flutter/material.dart';

/// Colour tokens for Tenang.
///
/// Warm paper, forest ink, one clay accent. Every text token below meets
/// WCAG AA on [canvas] and [surface]; mood colours are always paired with a label.
class AppColors {
  // ── Surfaces ───────────────────────────────────────────────
  static const canvas = Color(0xFFF6F4EF);
  static const cream = canvas;
  static const creamDark = Color(0xFFEFEDE6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF3F1EA);
  static const surfaceSunken = Color(0xFFEBE8DF);

  // ── Primary: forest ────────────────────────────────────────
  static const forest = Color(0xFF3F6B57);
  static const forestDeep = Color(0xFF2C4F40);
  static const forestMid = Color(0xFF5C8370);
  static const forestPale = Color(0xFFDDE9E0);
  static const forestMist = Color(0xFFEEF4F0);

  /// Legacy aliases kept so older widgets keep their meaning.
  static const sage = forest;
  static const sageDark = forestDeep;
  static const sageDeep = forestDeep;
  static const sageLight = forestMid;
  static const sagePale = forestPale;

  // ── Accent: clay ───────────────────────────────────────────
  static const clay = Color(0xFFB07D62);
  static const clayDeep = Color(0xFF8A5A44);
  static const clayPale = Color(0xFFF4E7E0);

  static const sand = Color(0xFFE4D9C4);
  static const sandLight = Color(0xFFF0E9D9);
  static const peach = clay;
  static const peachLight = Color(0xFFD9A98F);
  static const peachPale = clayPale;
  static const terracotta = clayDeep;

  static const lavender = Color(0xFF9C9AAE);
  static const lavenderLight = Color(0xFFD8D6E2);
  static const lavenderPale = Color(0xFFEFEEF5);
  static const lavenderDark = Color(0xFF6F6D82);

  static const mint = Color(0xFF8FB8A4);
  static const mintLight = Color(0xFFC9E0D4);
  static const mintPale = Color(0xFFEAF3EE);

  // ── Text ───────────────────────────────────────────────────
  static const textDark = Color(0xFF1E2A25);
  static const textBody = Color(0xFF4C5A54);
  static const textMuted = Color(0xFF5E6B65);
  static const textLight = Color(0xFF8B968F);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Mood scale ─────────────────────────────────────────────
  static const moodGreat = Color(0xFF4F7D63);
  static const moodGood = Color(0xFF7FA588);
  static const moodOkay = Color(0xFFC9B98F);
  static const moodLow = Color(0xFFD9A183);
  static const moodBad = Color(0xFFC08476);

  static const moodGreatTint = Color(0xFFE3EEE7);
  static const moodGoodTint = Color(0xFFEBF2EC);
  static const moodOkayTint = Color(0xFFF3EFE4);
  static const moodLowTint = Color(0xFFF7ECE5);
  static const moodBadTint = Color(0xFFF6E9E5);

  // ── Semantic ───────────────────────────────────────────────
  static const success = forest;
  static const warning = Color(0xFFA9853F);
  static const errorSoft = Color(0xFF9E5B4C);
  static const info = Color(0xFF4F6F80);

  static const successBg = Color(0xFFEAF2EC);
  static const warningBg = Color(0xFFF8F1E1);
  static const errorBg = Color(0xFFF8EBE7);
  static const infoBg = Color(0xFFEBF1F4);

  // ── Lines ──────────────────────────────────────────────────
  static const border = Color(0xFFDCD8CE);
  static const borderLight = Color(0xFFE8E4DA);
  static const divider = Color(0xFFE3DFD5);

  // ── Depth ──────────────────────────────────────────────────
  static const shadow = Color(0x142C4F40);
  static const shadowLight = Color(0x0A2C4F40);
  static const shadowMedium = Color(0x242C4F40);

  static const shimmerBase = Color(0xFFEDEAE2);
  static const shimmerHighlight = Color(0xFFF7F5F0);

  // ── Overlays ───────────────────────────────────────────────
  static const overlayDark = Color(0x661E2A25);
  static const overlayLight = Color(0x33F6F4EF);
  static const scrim = Color(0x521E2A25);

  // ── Interaction ────────────────────────────────────────────
  static const pressed = Color(0x143F6B57);
  static const hovered = Color(0x0A3F6B57);
  static const focused = Color(0x263F6B57);
  static const disabled = Color(0xFFDCD8CE);
  static const disabledText = Color(0xFF8B968F);
}
