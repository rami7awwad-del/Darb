import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_grid.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/home/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Section widget for the subjects.
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

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    // Grow the label with the text size so it never overflows.
    final badgeHeight = 40.h * textScale;
    final imageSize = 68.w;
    final gap = 8.h;

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
          height: badgeHeight + gap + imageSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: subjects.length,
            separatorBuilder: (_, _) => SizedBox(width: AppGrid.gutter),
            itemBuilder: (context, i) => _SubjectItem(
              subject: subjects[i],
              badgeHeight: badgeHeight,
              imageSize: imageSize,
              gap: gap,
              onTap: () => onSubjectTap?.call(subjects[i]),
            ),
          ),
        ),
      ],
    );
  }
}

/// Item widget for the subject.
class _SubjectItem extends StatelessWidget {
  const _SubjectItem({
    required this.subject,
    required this.badgeHeight,
    required this.imageSize,
    required this.gap,
    required this.onTap,
  });

  final SubjectModel subject;
  final double badgeHeight;
  final double imageSize;
  final double gap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: SizedBox(
        width: 127.w,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: badgeHeight,
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
            SizedBox(height: gap),
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: AppNetworkImage(
                    url: subject.image,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
