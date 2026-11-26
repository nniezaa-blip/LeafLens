import 'package:flutter/widgets.dart';

/// The 2 px spacing scale used across Lextari components.
class AppSpacing {
  const AppSpacing._();

  static const double s0 = 0;
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s22 = 22;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;

  static const double xxs = s2;
  static const double xs = s4;
  static const double sm = s8;
  static const double md = s12;
  static const double lg = s16;
  static const double xl = s24;
  static const double xxl = s32;
}

/// The shared corner scale.
class AppRadii {
  const AppRadii._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 20;
  static const double block = 22;
  static const double lg = 28;
  static const double xl = 32;
  static const double xxl = 34;
  static const double pill = 999;
}

/// Fixed component dimensions that are not spacing.
class AppSizes {
  const AppSizes._();

  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double iconMd = 18;
  static const double iconLg = 20;
  static const double iconXl = 22;
  static const double iconXxl = 26;

  static const double gauge = 108;
  static const double gaugeDefault = 152;
  static const double gaugeStroke = 12;
  static const double gaugeInnerGap = 4;
  static const double gaugeLabelRatio = 0.24;
  static const double dot = 6;
  static const double line = 1;
  static const double barAvatar = 28;
  static const double barAvatarFont = 14;
  static const double tankWidth = 58;
  static const double tankHeight = 96;
}

/// Motion durations and route offsets.
class AppMotionTokens {
  const AppMotionTokens._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration card = Duration(milliseconds: 280);
  static const Duration page = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 420);

  static const double pageEnterOffset = 0.08;
  static const double minTextScale = 1;
  static const double maxTextScale = 1.4;
  static const Duration loadingTimeout = Duration(seconds: 8);
  static const double pageLeaveOffset = 0.03;
}

class AppBreakpoints {
  const AppBreakpoints._();

  static const double mobile = 600;
  static const double dashboardDesktop = 640;
  static const double dashboardStandard = 1040;
  static const double dashboardStandardHeight = 824;
  static const double dashboardMaxWidth = 560;
}

/// Opacity values used for tints, tracks and muted layers.
class AppOpacity {
  const AppOpacity._();

  static const double faint = 0.12;
  static const double tint = 0.14;
  static const double soft = 0.4;
  static const double strong = 0.7;
}

/// Shared elevation levels.
abstract final class AppShadows {
  static List<BoxShadow> cardLight = [
    _shadow(0x0D, 0.5, 1),
    _shadow(0x0A, 2, 6),
    _shadow(0x17, 12, 32, -6),
  ];

  static List<BoxShadow> cardDark = [
    _shadow(0x80, 1, 2),
    _shadow(0x8C, 10, 28, -6),
  ];

  static List<BoxShadow> raisedLight = [
    _shadow(0x0F, 1, 3),
    _shadow(0x14, 10, 24),
    _shadow(0x38, 32, 64, -12),
  ];

  static List<BoxShadow> raisedDark = [
    _shadow(0x80, 2, 6),
    _shadow(0xB3, 32, 64, -12),
  ];

  static BoxShadow _shadow(
    int alpha,
    double y,
    double blur, [
    double spread = 0,
  ]) {
    return BoxShadow(
      color: Color.fromARGB(alpha, 0, 0, 0),
      offset: Offset(0, y),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }
}

/// Placeholder dimensions used by skeleton cards.
class AppSkeleton {
  const AppSkeleton._();

  static const double headerIcon = 18;
  static const double headerTitle = 18;
  static const double headerChipWidth = 64;
  static const double headerChipHeight = 24;
  static const double line = 18;
  static const double subline = 12;
  static const double value = 26;
  static const double shortLine = 110;
  static const double mediumLine = 150;
  static const double longLine = 180;
  static const double tileHeight = 84;
  static const double tankWidth = 58;
  static const double tankHeight = 96;
}

/// Botanical background glow values.
class AppBotanical {
  const AppBotanical._();

  static const double glowLarge = 380;
  static const double glowXLarge = 460;
  static const double glowSmall = 260;
  static const double glowBlur = 70;
  static const double glowAlpha = 0.22;
  static const double glowAlphaDark = 0.38;
  static const double glowAlphaSecondary = 0.18;
  static const double glowAlphaSecondaryDark = 0.28;
  static const double glowAlphaAccent = 0.28;
  static const double glowAlphaAccentDark = 0.18;

  static const double glowTop = -140;
  static const double glowLeft = -90;
  static const double glowBottom = -160;
  static const double glowRight = -110;
  static const double accentTop = 190;
  static const double accentRight = -80;

  static const double washAlpha = 0.08;
  static const double washAlphaDark = 0.12;
}

class AppDurations {
  const AppDurations._();
  static const Duration fast = AppMotionTokens.fast;
  static const Duration normal = AppMotionTokens.card;
  static const Duration slow = AppMotionTokens.slow;
}

class AppCurves {
  const AppCurves._();
  static const Curve emphasized = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve settle = Curves.easeOutCubic;
}
