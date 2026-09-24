import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppSizes {
  // ==================== Spaces Increments ====================
  static double s2  = 2.w;
  static double s4  = 4.w;
  static double s8  = 8.w;
  static double s12 = 12.w;
  static double s16 = 16.w;
  static double s20 = 20.w;
  static double s24 = 24.w;
  static double s28 = 28.w;
  static double s32 = 32.w;
  static double s36 = 36.w;

  // ==================== Page Layout Margins ====================
  /// الهامش الجانبي المعتمد لجميع الصفحات (16px)
  static double get pageHorizontalPadding => 16.w;

  /// الهامش العلوي والسفلي للواجهات (24px)
  static double get pageVerticalPadding => 24.h;

  /// المسافة بين العنوان والتفاصيل (16px)
  static double get titleToDetailSpace => 16.h;

  /// المسافة بين الأقسام الرئيسية في الصفحة (24px)
  static double get sectionSpace => 24.h;

  // ==================== Common EdgeInsets ====================
  /// الحشوة العامة لمحتوى الصفحة بالكامل
  static EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: pageHorizontalPadding,
        vertical: pageVerticalPadding,
      );

  static EdgeInsets get horizontalPadding => EdgeInsets.symmetric(
        horizontal: pageHorizontalPadding,
      );
}

/// ==================== Vertical & Horizontal Gaps ====================
class AppGaps {
  // Vertical Spacing (SizedBox Height)
  static Widget gapH4  = SizedBox(height: 4.h);
  static Widget gapH8  = SizedBox(height: 8.h);
  static Widget gapH12 = SizedBox(height: 12.h);
  static Widget gapH16 = SizedBox(height: 16.h); // Title to Details
  static Widget gapH20 = SizedBox(height: 20.h);
  static Widget gapH24 = SizedBox(height: 24.h); // Between Sections
  static Widget gapH32 = SizedBox(height: 32.h);

  // Horizontal Spacing (SizedBox Width)
  static Widget gapW4  = SizedBox(width: 4.w);
  static Widget gapW8  = SizedBox(width: 8.w);
  static Widget gapW12 = SizedBox(width: 12.w);
  static Widget gapW16 = SizedBox(width: 16.w);
  static Widget gapW24 = SizedBox(width: 24.w);
}