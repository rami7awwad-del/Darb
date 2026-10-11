import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/phosphor_icons.dart';

/// زر إغلاق دائري (X داخل دائرة) كما في Figma. [onTap] = null يعطّله.
/// ⚠️ قياس تقديري: الحجم (32)، سمك الحد (2)، حجم الأيقونة (55% من الحجم).
class AppCircleCloseButton extends StatelessWidget {
  const AppCircleCloseButton({
    super.key,
    required this.onTap,
    this.color = AppColors.grey300,
    this.size = 32,
  });

  final VoidCallback? onTap;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.w),
        ),
        child: Icon(PhosphorIconsRegular.x, size: (size * 0.55).w, color: color),
      ),
    );
  }
}
