import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppGrid {
  /// عدد أعمدة الشبكة الرئيسية (4 Columns)
  static const int columnCount = 4;

  /// عرض العامود المعتمد في التصميم (94px)
  static double get columnWidth => 94.w;

  /// المسافة بين الأعمدة (Gutter: 8px)
  static double get gutter => 8.w;

  /// الهوامش الجانبية للشبكة (Margin: 16px)
  static double get margin => 16.w;

  /// إعدادات SliverGridDelegate جاهزة للاستخدام في القوائم المزدوجة (2 Columns Grid)
  static SliverGridDelegateWithFixedCrossAxisCount get gridTwoColumns =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: gutter,
        crossAxisSpacing: gutter,
        childAspectRatio: 1.0,
      );

  /// إعدادات GridDelegate لقوائم الشبكة المكونة من 4 أعمدة
  static SliverGridDelegateWithFixedCrossAxisCount get gridFourColumns =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        mainAxisSpacing: gutter,
        crossAxisSpacing: gutter,
        childAspectRatio: 1.0,
      );
}