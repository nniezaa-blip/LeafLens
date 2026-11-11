import 'package:flutter/material.dart';

/// LEXTARI Design System — Typography
/// Single font: Lexend (variable, embedded in binary).
/// Weights: Light 300, Regular 400, Medium 500,
/// SemiBold 600, Bold 700, ExtraBold 800.
class AppTypography {
  AppTypography._();

  // ── Display / Large Headings ──────────────────────────────

  /// Screen titles (Login, Sign Up) — SemiBold 38px
  static const TextStyle displayLarge = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 38,
    letterSpacing: -0.5,
  );

  /// Section headings — SemiBold 30px
  static const TextStyle displayMedium = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 30,
    letterSpacing: -0.3,
  );

  /// CTA buttons (Get Started, Login, Sign Up) — SemiBold 24px
  static const TextStyle displaySmall = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );

  // ── Sensor Values ─────────────────────────────────────────

  /// Large sensor readings (26, 64%, 90%) — Bold 36px
  static const TextStyle headlineLarge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 36,
  );

  /// Gauge values — ExtraBold 28px
  static const TextStyle headlineMedium = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 28,
  );

  // ── Card Titles ───────────────────────────────────────────

  /// Card title (Temperature, Humidity, etc.) — Bold 20px
  static const TextStyle titleLarge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  /// Menu item labels — Bold 16px
  static const TextStyle titleMedium = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  // ── Status Text ───────────────────────────────────────────

  /// Status labels (Perfect Environment, Saturated) — Bold 16px
  static const TextStyle labelLarge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  /// Status descriptions (Temperature is normal) — SemiBold Italic 16px
  static const TextStyle labelMedium = TextStyle(
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    fontSize: 16,
  );

  // ── Body Text ─────────────────────────────────────────────

  /// Input labels, body text — Medium 16px
  static const TextStyle bodyLarge = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  /// Input field content — Regular 32px
  static const TextStyle bodyExtraLarge = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 32,
  );

  /// Small labels, metadata — Regular 14px
  static const TextStyle bodyMedium = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  /// Tiny text — Regular 12px
  static const TextStyle bodySmall = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
  );

  // ── Graph Labels ──────────────────────────────────────────

  /// Y-axis values — Light 20px
  static const TextStyle graphLabelLarge = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 20,
  );

  /// Graph titles — Bold 20px
  static const TextStyle graphTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  // ── Footer / Secondary Links ─────────────────────────────

  /// Footer text — Light 20px
  static const TextStyle footerLight = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 20,
  );

  /// Footer link — Bold 20px
  static const TextStyle footerBold = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );
}
