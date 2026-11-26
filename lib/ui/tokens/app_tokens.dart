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
  static const double s34 = 34;
  static const double s36 = 36;
  static const double s38 = 38;
  static const double s40 = 40;
  static const double s44 = 44;
  static const double s46 = 46;
  static const double s48 = 48;
  static const double s50 = 50;
  static const double s52 = 52;
  static const double s60 = 60;
  static const double s64 = 64;

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

  static const double micro = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 20;
  static const double block = 22;
  static const double card = 24;
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
  static const double iconAction = 24;
  static const double iconXxl = 26;
  static const double iconPage = 48;

  static const double gauge = 108;
  static const double gaugeDefault = 152;
  static const double gaugeStroke = 12;
  static const double gaugeInnerGap = 4;
  static const double gaugeLabelRatio = 0.24;
  static const double dot = 6;
  static const double line = 1;
  static const double barAvatar = 28;
  static const double barAvatarFont = 14;
  static const double profileBadge = 48;
  static const double profileBadgeFont = 18;
  static const double profileRing = 2;
  static const double tankWidth = 58;
  static const double tankHeight = 96;

  static const double avatarLarge = 60;
  static const double badge = 38;
  static const double checkbox = 24;
  static const double dialogMaxWidth = 420;
  static const double googleMark = 22;
  static const double onboardingMaxWidth = 520;
  static const double spinner = 20;
  static const double switchHeight = 30;
  static const double switchInset = 3;
  static const double switchThumb = 24;
  static const double switchWidth = 52;
  static const double toastAccent = 4;
  static const double trendHeaderIcon = 36;
  static const double trendSwitcherHeight = 46;
  static const double actionButtonHeight = 48;
  static const double authButtonHeight = 54;
  static const double onboardingButtonHeight = 54;
  static const double deviceTypeOptionHeight = 96;
  static const double onboardingPageHeight = 300;
  static const double refreshThreshold = 64;
  static const double pullGestureHeight = 88;
  static const double selectionMark = 20;
  static const double trendChartMinHeight = 360;
  static const double statsChromeHeight = 200;
}

/// Motion durations and route offsets.
class AppMotionTokens {
  const AppMotionTokens._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration control = Duration(milliseconds: 200);
  static const Duration segment = Duration(milliseconds: 220);
  static const Duration glyph = Duration(milliseconds: 240);
  static const Duration card = Duration(milliseconds: 280);
  static const Duration page = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration chart = Duration(milliseconds: 450);
  static const Duration refreshSnap = Duration(milliseconds: 220);
  static const Duration refreshSettle = Duration(milliseconds: 320);
  static const Duration minRefreshDuration = Duration(milliseconds: 450);
  static const Duration pulse = Duration(milliseconds: 900);
  static const Duration minLogoutDuration = Duration(milliseconds: 350);

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
  static const double border = 0.15;
  static const double whisper = 0.08;
  static const double thumb = 0.2;
  static const double soft = 0.4;
  static const double muted = 0.5;
  static const double faded = 0.6;
  static const double strong = 0.7;
  static const double overlay = 0.88;
  static const double solid = 0.9;
  static const double glass = 0.62;
  static const double glassDark = 0.55;
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

  static List<BoxShadow> frosted = [
    _shadow(0x1F, 8, 18),
  ];

  static List<BoxShadow> thumb = [
    _shadow(0x33, 1, 4),
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

  static const double healthHeaderWidth = 110;
  static const double healthGauge = 108;
  static const double healthLineWidth = 180;
  static const double healthSubWidth = 150;
  static const double controlTileWidth = 96;
  static const double environmentIcon = 22;
  static const double environmentLabelWidth = 110;
  static const double environmentLabelHeight = 15;
  static const double environmentSubWidth = 64;
  static const double environmentSubHeight = 11;
  static const double environmentValueWidth = 64;
  static const double environmentValueHeight = 26;
  static const double waterHeaderWidth = 120;
  static const double waterLabelWidth = 90;
  static const double waterLabelHeight = 13;
  static const double waterFigureWidth = 70;
  static const double waterFigureHeight = 26;
  static const double waterCaptionWidth = 130;
  static const double waterCaptionHeight = 12;
}

/// Botanical background glow values.
class AppBotanical {
  const AppBotanical._();

  static const double glowLarge = 380;
  static const double glowXLarge = 460;
  static const double glowSmall = 260;
  static const double glowBlur = 70;
  static const double glowAlpha = 0.22;
  static const double glowAlphaDark = 0.06;
  static const double glowAlphaSecondary = 0.18;
  static const double glowAlphaSecondaryDark = 0.04;
  static const double glowAlphaAccent = 0.28;
  static const double glowAlphaAccentDark = 0.03;

  static const double glowTop = -140;
  static const double glowLeft = -90;
  static const double glowBottom = -160;
  static const double glowRight = -110;
  static const double accentTop = 190;
  static const double accentRight = -80;

  static const double washAlpha = 0.08;
  static const double washAlphaDark = 0.03;
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
