import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// سطر تقدم: العنوان في البداية، ثم الشريط، ثم النسبة في النهاية.
/// [percent] من 0 إلى 100. الشريط يمتلئ من اليمين (RTL تلقائيًا).
/// ⚠️ قياس تقديري: سماكة الشريط (6) وعرض العنوان (90) وألوان الشريط.
class LibraryProgressRow extends StatelessWidget {
  const LibraryProgressRow({
    super.key,
    required this.label,
    required this.percent,
  });

  final String label;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final value = percent.clamp(0, 100).toDouble();

    return Row(
      spacing: 8.w,
      children: [
        SizedBox(
          width: 90.w,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font12Regular.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFD9D9D9),
              valueColor: const AlwaysStoppedAnimation(AppColors.second400),
            ),
          ),
        ),
        SizedBox(
          width: 34.w,
          child: Text(
            '${value.round()}%',
            textAlign: TextAlign.end,
            style: AppTextStyles.font12Regular.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ),
      ],
    );
  }
}
