import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/phosphor_icons.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// عدّاد العمر: العنوان، الرقم الكبير، وزرّا − و +.
/// تمرير null لـ [onDecrement] أو [onIncrement] يعطّل الزر (عند الحد).
/// ⚠️ قياس تقديري: حجم الدائرتين (40)، المسافة بينهما (16)، حجم الرقم (31).
class AgeCounter extends StatelessWidget {
  const AgeCounter({
    super.key,
    required this.age,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int age;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFDBDBDB), width: 1),
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'العمر',
              style: AppTextStyles.font14Regular.copyWith(color: AppColors.grey500),
            ),
          ),
          Text(
            '$age',
            style: AppTextStyles.font31Medium.copyWith(color: AppColors.main600),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16.w,
            children: [
              _CircleButton(icon: PhosphorIconsRegular.minus, onTap: onDecrement),
              _CircleButton(icon: PhosphorIconsRegular.plus, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null ? AppColors.grey100 : AppColors.main600;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(icon, size: 18.w, color: color),
      ),
    );
  }
}
