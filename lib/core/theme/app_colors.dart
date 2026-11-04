// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF5E17EB);
  static const Color primaryContainer = Color(0xFF5E17EB); // Deep Purple
  static const Color onPrimaryContainer = Color(0xFFFFFFFF); // White
  static const Color primaryFixed = Color(0xFFEDE9FE);
  static const Color primaryFixedDim = Color(0xFFDDD6FE);
  static const Color onPrimaryFixedVariant = Color(0xFF5E17EB);
  static const Color onPrimaryFixed = Color(0xFF3B0764);
  static const Color inversePrimary = Color(0xFFC4B5FD);

  // ── Secondary (Amber / Orange) ─────────────────────────────────────────
  static const Color secondary = Color(0xFF855300);
  static const Color secondaryContainer = Color(0xFFFEA619);
  static const Color onSecondaryContainer = Color(0xFF684000);
  static const Color secondaryFixed = Color(0xFFFFDDB8);
  static const Color secondaryFixedDim = Color(0xFFFFB95F);
  static const Color onSecondaryFixed = Color(0xFF2A1700);
  static const Color onSecondaryFixedVariant = Color(0xFF653E00);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── Tertiary ───────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF000000);
  static const Color tertiaryContainer = Color(0xFF161C22);
  static const Color onTertiaryContainer = Color(0xFF7E848C);
  static const Color tertiaryFixed = Color(0xFFDDE3EB);
  static const Color tertiaryFixedDim = Color(0xFFC1C7CF);
  static const Color onTertiaryFixed = Color(0xFF161C22);
  static const Color onTertiaryFixedVariant = Color(0xFF41474E);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // ── Surface ────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceBright = Color(0xFFF7F9FB);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceVariant = Color(0xFFE0E3E5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color surfaceTint = Color(0xFF565E74);

  // ── On Surface ────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF45464D);
  static const Color inverseSurface = Color(0xFF2D3133);
  static const Color inverseOnSurface = Color(0xFFEFF1F3);

  // ── Outline ────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF76777D);
  static const Color outlineVariant = Color(0xFFC6C6CD);

  // ── Background ────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF7F9FB);
  static const Color onBackground = Color(0xFF191C1E);

  // ── Error ──────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ── Customer Theme (Purple/Pink) ───────────────────────────────────────
  static const Color customerPrimary = Color(0xFF5E17EB); // Deep Purple
  static const Color customerSecondary = Color(0xFFF04C85); // Pink
  static const Color customerGradientStart = Color(0xFF8634A9);
  static const Color customerGradientEnd = Color(0xFFED457D);
  static const Color customerBackground = Color(0xFFF4F6F9);

  // ── Worker Theme (Unified Purple/Pink Scheme matching Customer) ───────
  static const Color workerBackground = Color(0xFFF4F6F9); // Light clean background
  static const Color workerSurface = Color(0xFFFFFFFF); // Clean white card surface
  static const Color workerPrimary = Color(0xFF5E17EB); // Deep Purple
  static const Color workerSecondary = Color(0xFFF04C85); // Pink
  static const Color workerGradientStart = Color(0xFF8634A9);
  static const Color workerGradientEnd = Color(0xFFED457D);
  static const Color workerPillBg = Color(0xFFEDE9FE); // Soft violet pill background
  static const Color workerPillText = Color(0xFF5E17EB); // Deep Purple text for pills

  // ── Service Categories Colors ──────────────────────────────────────────
  static const Color plumber = Color(0xFF0284C7);
  static const Color electrician = Color(0xFFD97706);
  static const Color carpenter = Color(0xFF7C3AED);
  static const Color cleaner = Color(0xFF059669);
  static const Color painter = Color(0xFFDC2626);
  static const Color mechanic = Color(0xFF4B5563);
  static const Color delivery = Color(0xFF0891B2);
  static const Color security = Color(0xFF2563EB);

  // ── Convenience ───────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color success = Color(0xFF2ECC71);
}
