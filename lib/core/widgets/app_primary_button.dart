import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// الزر الأساسي (Figma: 48 ارتفاع، Radius 11، خلفية main600)
/// إذا كان [onPressed] = null يظهر الزر بحالة معطّل.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11.r);

    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: Material(
        color: _enabled ? AppColors.main600 : AppColors.grey100,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: _enabled ? onPressed : null,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        text,
                        style: AppTextStyles.font16Medium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
