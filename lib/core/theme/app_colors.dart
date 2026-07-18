import 'package:flutter/material.dart';

/// Traqio's color system.
/// Designed for a premium SaaS "business command center" feel —
/// deliberately restrained, not colorful/playful like e-commerce apps.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5); // Indigo — trust, focus
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFFEEF2FF);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFF0F9FF);

  // Neutrals — Light theme
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF4F4F5);
  static const Color lightBorder = Color(0xFFE4E4E7);
  static const Color lightTextPrimary = Color(0xFF18181B);
  static const Color lightTextSecondary = Color(0xFF71717A);
  static const Color lightTextTertiary = Color(0xFFA1A1AA);

  // Neutrals — Dark theme
  static const Color darkBackground = Color(0xFF09090B);
  static const Color darkSurface = Color(0xFF18181B);
  static const Color darkSurfaceVariant = Color(0xFF27272A);
  static const Color darkBorder = Color(0xFF3F3F46);
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextTertiary = Color(0xFF71717A);
}
