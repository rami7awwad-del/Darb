import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// زر Outline (Figma: 48 ارتفاع، Radius 11، حد 1px بلون main600)
/// إذا كان [onPressed] = null يظهر الزر بحالة معطّل.
class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11.r);
    final color = _enabled ? AppColors.main600 : AppColors.grey100;

    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: color, width: 1),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: color),
                    child: icon!,
                  ),
                  SizedBox(width: 6.w),
                ],
                Text(
                  text,
                  style: AppTextStyles.font16Medium.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
