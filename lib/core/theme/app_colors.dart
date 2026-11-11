import 'package:flutter/material.dart';

/// LEXTARI Design System — Colors
/// Extracted from Figma: figma.com/design/RlSmZaAAWSPq09kAFXUcmU
class AppColors {
  AppColors._();

  // Primary Greens
  /// Light green used as background on the splash screen.
  static const Color lightGreenBg = Color(0xFFA3B88C);

  /// Medium green used as the primary brand colour.
  static const Color mediumGreen = Color(0xFF409761);

  /// Dark green used for headings and text accents.
  static const Color darkGreenText = Color(0xFF1B6F0A);

  /// Deepest green used for title text.
  static const Color deepGreen = Color(0xFF083722);

  // Status / Alert
  /// Red used for alert indicators.
  static const Color redAlert = Color(0xFFD05555);

  /// Dark red used for error text and links.
  static const Color redDark = Color(0xFF981C2B);

  /// Accent red used for critical indicators.
  static const Color redAccent = Color(0xFFE33629);

  /// Google brand red.
  static const Color googleRed = Color(0xFFEA4335);

  /// Yellow used for warning states.
  static const Color yellowAlert = Color(0xFFF8BD00);

  // Chart Colors
  /// Cyan used for chart lines.
  static const Color chartCyan = Color(0xFF319BC5);

  /// Purple used for chart lines.
  static const Color chartPurple = Color(0xFFA031C5);

  /// Magenta used for chart lines.
  static const Color chartMagenta = Color(0xFFC53178);

  /// Green used for chart lines.
  static const Color chartGreen = Color(0xFF319F43);

  /// Blue used for chart lines.
  static const Color chartBlue = Color(0xFF587DBD);

  // ── Off-whites / Off-blacks (never use pure #FFF or #000)
  /// Off-white used as the app background colour.
  static const Color offWhite = Color(0xFFF8F9FA);

  /// Off-black used for dark text and backgrounds.
  static const Color offBlack = Color(0xFF1A1A1A);

  // Neutrals
  /// Pure white.
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black.
  static const Color black = Color(0xFF000000);

  /// Dark charcoal for elevated surfaces.
  static const Color darkCharcoal = Color(0xFF202124);

  /// Dark grey for body text.
  static const Color textDark = Color(0xFF3C4043);

  /// Medium grey for secondary text.
  static const Color textGrey = Color(0xFF5F6368);

  /// Dark grey for borders and dividers.
  static const Color darkGrey = Color(0xFF444444);

  /// Medium grey for muted elements.
  static const Color mediumGrey = Color(0xFF757575);

  /// Grey for placeholder text.
  static const Color grey = Color(0xFF828282);

  /// Light grey for backgrounds.
  static const Color greyLight = Color(0xFF838383);

  /// Lighter grey for disabled states.
  static const Color greyLighter = Color(0xFFD9D9D9);

  /// Light border colour.
  static const Color borderLight = Color(0xFFDADCE0);

  /// Dark grey background for contrast sections.
  static const Color backgroundGrey = Color(0xFF333333);

  // Google Brand
  /// Google brand blue.
  static const Color googleBlue = Color(0xFF4285F4);

  /// Google brand green.
  static const Color googleGreen = Color(0xFF34A853);

  /// Google brand yellow.
  static const Color googleYellow = Color(0xFFFBBC05);

  // Semantics
  /// Fill colour for text input fields.
  static const Color inputFill = Color(0xFFF1F3F4);

  /// Border colour for text input fields.
  static const Color inputBorder = Color(0xFFDADCE0);

  // Dashboard-specific
  /// Semi-transparent medium green for the background ellipse overlay.
  static const Color mediumGreenOverlay = Color(0x99409761);

  /// Card background used for sensor and health score cards.
  static const Color cardBackground = Color(0xB3D9D9D9);

  /// Green arc colour for healthy sensor gauges.
  static const Color gaugeGreen = Color(0x991B6F0A);

  /// Orange arc colour for warning sensor gauges.
  static const Color gaugeOrange = Color(0x99FFB703);

  /// Action switch pill background.
  static const Color switchBackground = Color(0x9960AE88);

  /// Action switch toggle track colour.
  static const Color switchTrack = Color(0xFF316763);

  /// Floating bottom navigation bar background.
  static const Color navBarBackground = Color(0xA6263626);

  /// Warning text colour for health alerts.
  static const Color warningText = Color(0xD9E5A00A);
}
