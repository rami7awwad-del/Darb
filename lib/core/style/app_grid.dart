import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Grid sizes and spacing from the design.
abstract class AppGrid {
  static const int columnCount = 4;

  static double get columnWidth => 94.w;

  static double get gutter => 8.w;

  static double get margin => 16.w;

  static SliverGridDelegateWithFixedCrossAxisCount get gridTwoColumns =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: gutter,
        crossAxisSpacing: gutter,
        childAspectRatio: 1.0,
      );

  static SliverGridDelegateWithFixedCrossAxisCount get gridFourColumns =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        mainAxisSpacing: gutter,
        crossAxisSpacing: gutter,
        childAspectRatio: 1.0,
      );
}
