import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';

abstract class AppTextStyles {
  static const String fontFamily = 'Noto Sans Arabic';

  static TextStyle _style(double size, FontWeight weight) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size.sp,
    fontWeight: weight,
    height: 1.4,
    color: AppColors.black,
  );

  // ==================== H1 (61px) ====================
  static TextStyle get font61Regular => _style(61, FontWeight.w400);
  static TextStyle get font61Bold => _style(61, FontWeight.w700);
  static TextStyle get font61Medium => _style(61, FontWeight.w500);

  // ==================== H2 (49px) ====================
  static TextStyle get font49Regular => _style(49, FontWeight.w400);
  static TextStyle get font49Bold => _style(49, FontWeight.w700);
  static TextStyle get font49Medium => _style(49, FontWeight.w500);

  // ==================== H3 (39px) ====================
  static TextStyle get font39Regular => _style(39, FontWeight.w400);
  static TextStyle get font39Bold => _style(39, FontWeight.w700);
  static TextStyle get font39Medium => _style(39, FontWeight.w500);

  // ==================== H4 (31px) ====================
  static TextStyle get font31Regular => _style(31, FontWeight.w400);
  static TextStyle get font31Bold => _style(31, FontWeight.w700);
  static TextStyle get font31Medium => _style(31, FontWeight.w500);

  // ==================== H5 (25px) ====================
  static TextStyle get font25Regular => _style(25, FontWeight.w400);
  static TextStyle get font25Bold => _style(25, FontWeight.w700);
  static TextStyle get font25Medium => _style(25, FontWeight.w500);

  // ==================== Title 1 (20px) ====================
  static TextStyle get font20Regular => _style(20, FontWeight.w400);
  static TextStyle get font20Bold => _style(20, FontWeight.w700);
  static TextStyle get font20Medium => _style(20, FontWeight.w500);

  // ==================== Title 2 (16px) ====================
  static TextStyle get font16Regular => _style(16, FontWeight.w400);
  static TextStyle get font16Bold => _style(16, FontWeight.w700);
  static TextStyle get font16Medium => _style(16, FontWeight.w500);

  // ==================== Body (14px) ====================
  static TextStyle get font14Regular => _style(14, FontWeight.w400);
  static TextStyle get font14Bold => _style(14, FontWeight.w700);
  static TextStyle get font14Medium => _style(14, FontWeight.w500);

  // ==================== Caption (12px) ====================
  static TextStyle get font12Regular => _style(12, FontWeight.w400);
  static TextStyle get font12Bold => _style(12, FontWeight.w700);
  static TextStyle get font12Medium => _style(12, FontWeight.w500);
}
