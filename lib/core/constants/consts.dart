import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceVariant = Color(0xFF252525);
  static const onSurface = Color(0xFFE0E0E0);
  static const subtle = Color(0xFF9E9E9E);
  static const purple = Color(0xFFAB47BC);
  static const yellow = Color(0xFFFFD600);

  static const gradientRing = [yellow, purple];
}

class AppSpacing {
  AppSpacing._();

  static const double screenHorizontalPadding = 24;
  static const double cardBorderRadius = 16;
  static const double pillRadius = 999;
  static const double accentBarHeight = 4;
}

class WelcomeSpacing {
  WelcomeSpacing._();

  static const double titleTopPadding = 80;
  static const double titleFontSize = 36;
  static const double titleLetterSpacing = 12;
  static const FontWeight titleFontWeight = FontWeight.w800;

  static const double taglineGap = 12;
  static const double taglineFontSize = 18;

  static const double cameraButtonSize = 160;
  static const double cameraIconSize = 56;
  static const double cameraRingStrokeWidth = 4;

  static const double pillGap = 24;
  static const double pillHeight = 52;
}

class InfoSpacing {
  InfoSpacing._();

  static const double headingTopPadding = 32;
  static const double headingFontSize = 26;
  static const FontWeight headingFontWeight = FontWeight.w700;

  static const double headingToCards = 24;
  static const double cardGap = 12;
  static const double cardPadding = 16;
  static const double cardIconSize = 40;
  static const double cardIconMarginRight = 16;
  static const double cardTitleFontSize = 16;
  static const FontWeight cardTitleFontWeight = FontWeight.w600;
  static const double cardSubtitleFontSize = 14;
  static const double cardTitleSubtitleGap = 4;

  static const double buttonHeight = 52;
  static const double buttonGap = 12;
  static const double buttonVerticalPadding = 16;
}
