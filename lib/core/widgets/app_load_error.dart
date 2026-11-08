import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_outline_button.dart';

/// Error message with a retry button.
class AppLoadError extends StatelessWidget {
  const AppLoadError({super.key, required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16.h,
          children: [
            Text(
              message ?? 'تعذر تحميل البيانات',
              textAlign: TextAlign.center,
              style: AppTextStyles.font14Regular.copyWith(
                color: AppColors.grey400,
              ),
            ),
            AppOutlineButton(text: 'إعادة المحاولة', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
