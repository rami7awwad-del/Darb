import 'package:flutter/material.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// عنوان قسم + رابط اختياري في النهاية (مثل "أظهر الكل").
/// ⚠️ قياس تقديري: لون العنوان (second500) وحجمه (16) وحجم الرابط (12).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.color = AppColors.second500,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// لون العنوان والرابط (الافتراضي second500، وقسم الدورات يستخدم main600).
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.font16Medium.copyWith(color: color),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(
              actionLabel!,
              style: AppTextStyles.font12Regular.copyWith(color: color),
            ),
          ),
      ],
    );
  }
}
