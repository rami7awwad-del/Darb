import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';

/// Simple progress bar.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.second500,
    this.height = 5,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fraction = value.isNaN ? 0.0 : value.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(height.r),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: height.h,
        backgroundColor: AppColors.grey50,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
