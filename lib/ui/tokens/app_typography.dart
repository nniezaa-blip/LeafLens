import 'package:flutter/widgets.dart';

/// Lextari's display and text roles.
///
/// Figures use tabular digits where callers need them; the sizes stay close to
/// Prism's Dynamic Type scale so FlClash components keep their proportions.
class AppTypography {
  AppTypography._();

  static const TextStyle displayLarge = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 56,
    height: 1.1,
    letterSpacing: -1.2,
  );
  static const TextStyle displayMedium = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 40,
    height: 1.15,
    letterSpacing: -0.8,
  );
  static const TextStyle displaySmall = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 32,
    height: 1.2,
    letterSpacing: -0.4,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 1.18,
    letterSpacing: -0.4,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.2,
    letterSpacing: -0.2,
  );
  static const TextStyle titleLarge = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.25,
  );
  static const TextStyle titleMedium = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.3,
  );
  static const TextStyle labelLarge = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.3,
  );
  static const TextStyle labelMedium = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.3,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
  );
  static const TextStyle bodyExtraLarge = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 28,
    height: 1.3,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.45,
  );
  static const TextStyle bodySmall = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.4,
  );
  static const double figureLetterSpacing = -0.6;

  static const TextStyle graphLabelLarge = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 1.3,
  );
  static const TextStyle graphTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.3,
  );
  static const TextStyle footerLight = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.4,
  );
}
