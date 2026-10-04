import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// عنوان الخطوة بلونين + نص فرعي. وسط داخل البطاقات، وبداية خارجها.
/// ⚠️ قياس تقديري: توزيع اللونين وحجم النص الفرعي (12).
class StepHeading extends StatelessWidget {
  const StepHeading({
    super.key,
    required this.first,
    required this.second,
    this.subtitle,
    this.centered = false,
  });

  final String first;
  final String second;
  final String? subtitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    final base = AppTextStyles.font31Medium.copyWith(fontSize: 32.sp);

    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$first ', style: base.copyWith(color: AppColors.main600)),
              TextSpan(text: second, style: base.copyWith(color: AppColors.second500)),
            ],
          ),
          textAlign: align,
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle!,
            textAlign: align,
            style: AppTextStyles.font12Regular.copyWith(color: AppColors.grey400),
          ),
        ],
      ],
    );
  }
}
