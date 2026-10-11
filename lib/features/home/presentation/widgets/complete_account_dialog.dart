import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_sizes.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/style/phosphor_icons.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/core/widgets/app_primary_button.dart';

/// نافذة "أكمل حسابك الان" (أولى خطوتين). تُغلق بـ true عند الضغط على "أكمل"،
/// وبـ false (أو null) عند "الرجوع" أو زر الإغلاق أو الضغط خارجها.
/// ⚠️ قياس تقديري: الهامش الجانبي للنافذة (40)، نصف قطر الحواف (24)،
/// الحشوة (24)، حجم أيقونة الإغلاق (32)، المسافة بين الصف العلوي والأزرار (24).
class CompleteAccountDialog extends StatelessWidget {
  const CompleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'أكمل حسابك الان',
                    style: AppTextStyles.font20Medium
                        .copyWith(color: AppColors.grey500),
                  ),
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context, false),
                  child: Icon(
                    PhosphorIconsRegular.x,
                    size: 32.w,
                    color: AppColors.grey300,
                  ),
                ),
              ],
            ),
            AppGaps.gapH24,
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    text: 'أكمل',
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                AppGaps.gapW12,
                Expanded(
                  child: AppOutlineButton(
                    text: 'الرجوع',
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
