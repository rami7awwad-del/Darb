import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/phosphor_icons.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_primary_button.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';

/// شاشة "مبروك!" بعد حفظ البيانات. لا رجوع منها.
/// ⚠️ قياس تقديري: حجم الشارة (100)، الفراغ بين العناصر (32)، حجم العنوان (32).
class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 32.h,
                      children: [
                        Icon(
                          PhosphorIconsFill.sealCheck,
                          size: 100.w,
                          color: AppColors.second400,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8.h,
                          children: [
                            Text(
                              'مبروك!',
                              style: AppTextStyles.font31Medium.copyWith(
                                fontSize: 32.sp,
                                color: AppColors.second500,
                              ),
                            ),
                            Text(
                              'تم تسجيل حسابك بنجاح. نحن سعداء بانضمامك إلينا!',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.font14Regular
                                  .copyWith(color: AppColors.grey300),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AppPrimaryButton(
                  text: 'الصفحة الرئيسية',
                  onPressed: () {
                    // TODO: عند إنشاء MainLayout:
                    // Navigator.pushNamedAndRemoveUntil(
                    //   context, AppRoutes.mainLayout, (_) => false);
                    showAppSnackBar(
                      context,
                      'الصفحة الرئيسية قيد البناء',
                      isError: false,
                    );
                  },
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
