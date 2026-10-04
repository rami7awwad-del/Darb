import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// رسالة قصيرة أسفل الشاشة (خطأ افتراضيًا).
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = true,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11.r)),
        content: Text(
          message,
          style: AppTextStyles.font14Regular.copyWith(color: AppColors.white),
        ),
      ),
    );
}
