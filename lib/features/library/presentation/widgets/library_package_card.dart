import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/features/library/data/models/library_package.dart';
import 'package:darb/features/library/presentation/widgets/library_course_card.dart';

/// بطاقة باقة: الاسم والسعر في البداية وزر "تفاصيل" في النهاية، ثم قسم قابل للطي
/// فيه مواد الباقة (بطاقات كورس بحد رفيع)، ثم زر "متابعة التعلم".
/// ⚠️ لا يوجد حقل مدة ولا وصف في الـ API فلم يُعرضا ("/ 7 أيام" وسطر الوصف).
/// ⚠️ تسمية القسم "إخفاء/إظهار المواد المنجزة" كما في Figma، وهو يعرض كل مواد الباقة.
/// ⚠️ قياس تقديري: Radius (16) وحد القسم (#DBDBDB) وارتفاع زر تفاصيل (28).
class LibraryPackageCard extends StatefulWidget {
  const LibraryPackageCard({
    super.key,
    required this.package,
    this.onDetails,
    this.onContinue,
  });

  final LibraryPackage package;
  final VoidCallback? onDetails;
  final VoidCallback? onContinue;

  @override
  State<LibraryPackageCard> createState() => _LibraryPackageCardState();
}

class _LibraryPackageCardState extends State<LibraryPackageCard> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final package = widget.package;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.w,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6.h,
                  children: [
                    Text(
                      package.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.font14Bold.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                    Text(
                      '${package.price} ليرة سورية',
                      style: AppTextStyles.font14Medium.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              _DetailsChip(onTap: widget.onDetails),
            ],
          ),
          if (package.subjects.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _SubjectsSection(
              package: package,
              open: _open,
              onToggle: () => setState(() => _open = !_open),
            ),
          ],
          SizedBox(height: 16.h),
          AppOutlineButton(text: 'متابعة التعلم', onPressed: widget.onContinue),
        ],
      ),
    );
  }
}

class _DetailsChip extends StatelessWidget {
  const _DetailsChip({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);
    return Material(
      color: AppColors.main500,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: 28.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          alignment: Alignment.center,
          child: Text(
            'تفاصيل',
            style: AppTextStyles.font12Regular.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectsSection extends StatelessWidget {
  const _SubjectsSection({
    required this.package,
    required this.open,
    required this.onToggle,
  });

  final LibraryPackage package;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFDBDBDB)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    open ? 'إخفاء المواد المنجزة' : 'إظهار المواد المنجزة',
                    style: AppTextStyles.font12Regular.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 24.w,
                    color: AppColors.second400,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Column(
                      spacing: 12.h,
                      children: [
                        for (final subject in package.subjects)
                          LibraryCourseCard(
                            course: subject,
                            showAction: false,
                            outlined: true,
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
