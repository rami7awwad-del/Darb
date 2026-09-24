import 'package:flutter/material.dart';

abstract class AppColors {
  // Main Palette
  static const Color main50 = Color(0xFFEBFAFA);
  static const Color main100 = Color(0xFFC2F0F0);
  static const Color main200 = Color(0xFFA4E8E9);
  static const Color main300 = Color(0xFF7ADEE0);
  static const Color main400 = Color(0xFF61D8D9);
  static const Color main500 = Color(0xFF39CED0);
  static const Color main600 = Color(0xFF34BBBD);
  static const Color main700 = Color(0xFF289294);
  static const Color main800 = Color(0xFF1F7172);
  static const Color main900 = Color(0xFF185757);

  // Second Palette
  static const Color second50 = Color(0xFFEFF4FD);
  static const Color second100 = Color(0xFFCCDCFA);
  static const Color second200 = Color(0xFFB4CBF8);
  static const Color second300 = Color(0xFF91B3F4);
  static const Color second400 = Color(0xFF7CA4F2);
  static const Color second500 = Color(0xFF5B8DEF);
  static const Color second600 = Color(0xFF5380D9);
  static const Color second700 = Color(0xFF4164AA);
  static const Color second800 = Color(0xFF324E83);
  static const Color second900 = Color(0xFF263B64);

  // Grey Palette
  static const Color grey50 = Color(0xFFEBEBEB);
  static const Color grey100 = Color(0xFFC0C0C0);
  static const Color grey200 = Color(0xFFA1A1A1);
  static const Color grey300 = Color(0xFF767676);
  static const Color grey400 = Color(0xFF5C5C5C);
  static const Color grey500 = Color(0xFF333333);
  static const Color grey600 = Color(0xFF2E2E2E);
  static const Color grey700 = Color(0xFF242424);
  static const Color grey800 = Color(0xFF1C1C1C);
  static const Color grey900 = Color(0xFF151515);

  // Status Colors
  static const Color danger = Color(0xFFD85A5A);
  static const Color dangerLight = Color(0xFFFCE1E2);
  static const Color success = Color(0xFF52C480);
  static const Color successLight = Color(0xFFD6FCE2);

  // Shortcuts
  static const Color primary = main500;
  static const Color secondary = second500;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

/// ==================== Shadows Class ====================
abstract class AppShadows {
  static final List<BoxShadow> midGrey = [
    const BoxShadow(
      color: Color(0xFFB0B0B0),
      offset: Offset(1, 1),
      blurRadius: 7,
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> midLight = [
    const BoxShadow(
      color: Color(0xFFD9DDE5),
      offset: Offset(1, 1),
      blurRadius: 7,
      spreadRadius: 0,
    ),
  ];
}
