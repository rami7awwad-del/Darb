import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// شريط التقدم: 3 مراحل (المعلومات الشخصية، نوع المؤسسة، تفاصيل الحساب).
/// [stage] من 1 إلى 3. المقاطع المكتملة بلون second، والمؤشر عند طرف التقدم.
/// ⚠️ قياس تقديري: سماكة الشريط (6)، حجم المؤشر (12)، الفراغ بين المقاطع (4)،
/// وألوان المقاطع والتسميات (second500 / grey50 / grey500).
class RegisterProgressBar extends StatelessWidget {
  const RegisterProgressBar({super.key, required this.stage});

  final int stage;

  static const List<String> _labels = [
    'المعلومات الشخصية',
    'نوع المؤسسة',
    'تفاصيل الحساب',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 12.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                spacing: 4.w,
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: i < stage ? AppColors.second500 : AppColors.grey50,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                ],
              ),
              // المؤشر عند طرف التقدم (يبدأ من اليمين في RTL)
              Align(
                alignment: AlignmentDirectional(-1 + 2 * stage / 3, 0),
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.second500, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 3; i++)
              Text(
                _labels[i],
                style: AppTextStyles.font12Regular.copyWith(
                  color: i == stage - 1 ? AppColors.second500 : AppColors.grey500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
