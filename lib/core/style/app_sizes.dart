import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Common spacing and padding values.
abstract class AppSizes {
  static double get s2 => 2.w;
  static double get s4 => 4.w;
  static double get s8 => 8.w;
  static double get s12 => 12.w;
  static double get s16 => 16.w;
  static double get s20 => 20.w;
  static double get s24 => 24.w;
  static double get s28 => 28.w;
  static double get s32 => 32.w;
  static double get s36 => 36.w;

  static double get pageHorizontalPadding => 16.w;

  static double get pageVerticalPadding => 24.h;

  static double get titleToDetailSpace => 16.h;

  static double get sectionSpace => 24.h;

  static EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: pageHorizontalPadding,
    vertical: pageVerticalPadding,
  );

  static EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: pageHorizontalPadding);
}

/// Ready made spacing widgets.
class AppGaps {
  static Widget get gapH2 => SizedBox(height: 2.h);
  static Widget get gapH4 => SizedBox(height: 4.h);
  static Widget get gapH8 => SizedBox(height: 8.h);
  static Widget get gapH12 => SizedBox(height: 12.h);
  static Widget get gapH16 => SizedBox(height: 16.h);
  static Widget get gapH20 => SizedBox(height: 20.h);
  static Widget get gapH24 => SizedBox(height: 24.h);
  static Widget get gapH28 => SizedBox(height: 28.h);
  static Widget get gapH32 => SizedBox(height: 32.h);
  static Widget get gapH36 => SizedBox(height: 36.h);

  static Widget get gapW2 => SizedBox(width: 2.w);
  static Widget get gapW4 => SizedBox(width: 4.w);
  static Widget get gapW8 => SizedBox(width: 8.w);
  static Widget get gapW12 => SizedBox(width: 12.w);
  static Widget get gapW16 => SizedBox(width: 16.w);
  static Widget get gapW20 => SizedBox(width: 20.w);
  static Widget get gapW24 => SizedBox(width: 24.w);
  static Widget get gapW28 => SizedBox(width: 28.w);
  static Widget get gapW32 => SizedBox(width: 32.w);
  static Widget get gapW36 => SizedBox(width: 36.w);
}
