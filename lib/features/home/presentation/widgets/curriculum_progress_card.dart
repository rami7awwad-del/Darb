import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// بطاقة "تقدم المنهاج": النص في البداية والدائرة في النهاية.
/// ⚠️ قياس تقديري: قطر الدائرة (82) وسماكتها (7) وألوانها، Radius البطاقة (16).
class CurriculumProgressCard extends StatelessWidget {
  const CurriculumProgressCard({
    super.key,
    required this.percent,
    required this.coursesCount,
    this.onDetails,
  });

  /// من 0 إلى 100.
  final double percent;
  final int coursesCount;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final value = (percent.clamp(0, 100)) / 100;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFDBDBDB), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'تقدم المنهاج',
                      style: AppTextStyles.font16Medium
                          .copyWith(color: AppColors.grey700),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: onDetails,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'التفاصيل',
                        style: AppTextStyles.font12Regular
                            .copyWith(color: AppColors.second500),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'أنت على الطريق الصحيح لإتمام دوراتك.',
                  style: AppTextStyles.font12Regular
                      .copyWith(color: AppColors.grey400),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$coursesCount كورس',
                  style: AppTextStyles.font12Regular
                      .copyWith(color: AppColors.grey300),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 82.w,
            height: 82.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value.toDouble(),
                    strokeWidth: 7.w,
                    strokeCap: StrokeCap.round,
                    color: AppColors.main500,
                    backgroundColor: AppColors.main100,
                  ),
                ),
                Text(
                  '${percent.round()}%',
                  style: AppTextStyles.font16Regular
                      .copyWith(color: AppColors.second500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
