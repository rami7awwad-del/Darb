import 'package:flutter/material.dart';

/// ==================== Main Color Swatch ====================
const Color main50  = Color(0xFFEBFAFA);
const Color main100 = Color(0xFFC2F0F0);
const Color main200 = Color(0xFFA4E8E9);
const Color main300 = Color(0xFF7ADEE0);
const Color main400 = Color(0xFF61D8D9);
const Color main500 = Color(0xFF39CED0);
const Color main600 = Color(0xFF34BBBD);
const Color main700 = Color(0xFF289294);
const Color main800 = Color(0xFF1F7172);
const Color main900 = Color(0xFF185757);

/// ==================== Second Color Swatch ====================
const Color second50  = Color(0xFFEFF4FD);
const Color second100 = Color(0xFFCCDCFA);
const Color second200 = Color(0xFFB4CBF8);
const Color second300 = Color(0xFF91B3F4);
const Color second400 = Color(0xFF7CA4F2);
const Color second500 = Color(0xFF5B8DEF);
const Color second600 = Color(0xFF5380D9);
const Color second700 = Color(0xFF4164AA);
const Color second800 = Color(0xFF324E83);
const Color second900 = Color(0xFF263B64);

/// ==================== Grey Color Swatch ====================
const Color grey50  = Color(0xFFEBEBEB);
const Color grey100 = Color(0xFFC0C0C0);
const Color grey200 = Color(0xFFA1A1A1);
const Color grey300 = Color(0xFF767676);
const Color grey400 = Color(0xFF5C5C5C);
const Color grey500 = Color(0xFF333333);
const Color grey600 = Color(0xFF2E2E2E);
const Color grey700 = Color(0xFF242424);
const Color grey800 = Color(0xFF1C1C1C);
const Color grey900 = Color(0xFF151515);

/// ==================== Status Colors ====================
const Color dangerStatue      = Color(0xFFD85A5A);
const Color dangerStatueLight = Color(0xFFFCE1E2);

const Color successStatue      = Color(0xFF52C480);
const Color successStatueLight = Color(0xFFD6FCE2);

/// ==================== Common Colors ====================
const Color appWhiteColor = Color(0xFFFFFFFF);
const Color appBlackColor = Color(0xFF000000);

/// ==================== Extended Colors Class ====================
abstract class AppColors {
  // Main Palette
  static const Color pmain50  = main50;
  static const Color pmain100 = main100;
  static const Color pmain200 = main200;
  static const Color pmain300 = main300;
  static const Color pmain400 = main400;
  static const Color pmain500 = main500;
  static const Color pmain600 = main600;
  static const Color pmain700 = main700;
  static const Color pmain800 = main800;
  static const Color pmain900 = main900;

  // Second Palette
  static const Color psecond50  = second50;
  static const Color psecond100 = second100;
  static const Color psecond200 = second200;
  static const Color psecond300 = second300;
  static const Color psecond400 = second400;
  static const Color psecond500 = second500;
  static const Color psecond600 = second600;
  static const Color psecond700 = second700;
  static const Color psecond800 = second800;
  static const Color psecond900 = second900;

  // Grey Palette
  static const Color pgrey50  = grey50;
  static const Color pgrey100 = grey100;
  static const Color pgrey200 = grey200;
  static const Color pgrey300 = grey300;
  static const Color pgrey400 = grey400;
  static const Color pgrey500 = grey500;
  static const Color pgrey600 = grey600;
  static const Color pgrey700 = grey700;
  static const Color pgrey800 = grey800;
  static const Color pgrey900 = grey900;

  // Status Colors
  static const Color danger       = dangerStatue;
  static const Color dangerLight  = dangerStatueLight;
  static const Color success      = successStatue;
  static const Color successLight = successStatueLight;

  // Shortcuts
  static const Color primary   = main500;
  static const Color secondary = second500;
  static const Color white     = appWhiteColor;
  static const Color black     = appBlackColor;
}

/// ==================== Shadows Class ====================
abstract class AppShadows {
  static final List<BoxShadow> midPurple = [
    const BoxShadow(
      color: Color(0xFFA55DBB),
      offset: Offset(1, 1),
      blurRadius: 7,
      spreadRadius: 0,
    ),
  ];

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