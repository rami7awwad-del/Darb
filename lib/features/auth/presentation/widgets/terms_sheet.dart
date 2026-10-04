import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/auth/data/models/terms_model.dart';
import 'package:darb/core/style/phosphor_icons.dart';

/// ورقة الشروط والأحكام (Bottom Sheet) بنص قادم من pages/terms-conditions.
/// ⚠️ قياس تقديري: Radius 24، الحشوات (20 أفقي، 24 رأسي)، أقصى ارتفاع 85% من الشاشة.
Future<void> showTermsSheet(BuildContext context, TermsModel terms) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    builder: (_) => _TermsSheet(terms: terms),
  );
}

class _TermsSheet extends StatelessWidget {
  const _TermsSheet({required this.terms});

  final TermsModel terms;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsRegular.shieldCheck,
                    size: 20.w, color: AppColors.main600),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    terms.heading ?? 'الشروط و الأحكام',
                    style: AppTextStyles.font16Medium
                        .copyWith(color: AppColors.grey500),
                  ),
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.grey100),
                    ),
                    child: Icon(PhosphorIconsRegular.x,
                        size: 16.w, color: AppColors.grey400),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < terms.sections.length; i++) ...[
                      if (i > 0)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Divider(height: 1, color: AppColors.grey50),
                        ),
                      if (terms.sections[i].title != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            terms.sections[i].title!,
                            style: AppTextStyles.font16Medium
                                .copyWith(color: AppColors.main600),
                          ),
                        ),
                      if (terms.sections[i].body.isNotEmpty)
                        Text(
                          terms.sections[i].body,
                          style: AppTextStyles.font12Regular
                              .copyWith(color: AppColors.grey400),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
