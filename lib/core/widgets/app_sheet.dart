import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_circle_close_button.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/core/widgets/app_primary_button.dart';

/// ورقة سفلية موحدة: العنوان + أيقونته في البداية، وزر الإغلاق في النهاية (Figma).
/// تُستخدم في: تواصل معنا، حول التطبيق، تعديل المعلومات الشخصية.
/// 📏 كل القياسات هنا تقديرية من لقطة Figma (Radius 24، الحشوات 16/32/24، المسافة 24).
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required IconData icon,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)), // 📏
    ),
    builder: (sheetContext) => Padding(
      // يرفع الورقة فوق لوحة المفاتيح.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 24.h), // 📏
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24.w, color: AppColors.main600), // 📏
                  SizedBox(width: 8.w), // 📏
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.font16Medium.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                  AppCircleCloseButton(
                    onTap: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              SizedBox(height: 24.h), // 📏
              Flexible(
                child: SingleChildScrollView(child: builder(sheetContext)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// صف زرّين متساويين: الأساسي في البداية (يمين) و"الخروج" في النهاية (يسار).
class AppSheetActions extends StatelessWidget {
  const AppSheetActions({
    super.key,
    required this.primaryText,
    required this.onPrimary,
    required this.onSecondary,
    this.secondaryText = 'الخروج',
    this.isLoading = false,
  });

  final String primaryText;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final String secondaryText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12.w, // 📏
      children: [
        Expanded(
          child: AppPrimaryButton(
            text: primaryText,
            onPressed: onPrimary,
            isLoading: isLoading,
          ),
        ),
        Expanded(
          child: AppOutlineButton(
            text: secondaryText,
            onPressed: isLoading ? null : onSecondary,
          ),
        ),
      ],
    );
  }
}
