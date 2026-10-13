import 'package:darb/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_grid.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/home/presentation/widgets/section_header.dart';

/// قسم "المواد": قائمة أفقية، لكل مادة شارة باسمها فوق صورتها.
/// ⚠️ قياس تقديري: عرض العنصر (94 = عمود الشبكة)، ارتفاع الشارة (32)،
/// حجم الصورة (60)، لون الشارة (second500).
class SubjectsSection extends StatelessWidget {
  const SubjectsSection({
    super.key,
    required this.subjects,
    this.onShowAll,
    this.onSubjectTap,
  });

  final List<SubjectModel> subjects;
  final VoidCallback? onShowAll;
  final ValueChanged<SubjectModel>? onSubjectTap;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SectionHeader(
            title: 'المواد',
            actionLabel: 'أظهر الكل',
            onAction: onShowAll,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 112.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: subjects.length,
            separatorBuilder: (_, _) => SizedBox(width: AppGrid.gutter),
            itemBuilder: (context, i) => _SubjectItem(
              subject: subjects[i],
              onTap: () => onSubjectTap?.call(subjects[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubjectItem extends StatelessWidget {
  const _SubjectItem({required this.subject, required this.onTap});

  final SubjectModel subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: SizedBox(
        width: AppGrid.columnWidth,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 32.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: AppColors.second500,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                subject.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.font12Regular.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            AppNetworkImage(
              url: subject.image,
              width: 60.w,
              height: 60.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
