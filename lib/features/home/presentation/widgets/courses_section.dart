import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/home/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Section widget for the courses.
class CoursesSection extends StatelessWidget {
  const CoursesSection({super.key, required this.courses, this.onCourseTap});

  // Width to height ratio of the course image.
  static const double _imageAspectRatio = 1.6;

  final List<CourseModel> courses;
  final ValueChanged<CourseModel>? onCourseTap;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cardWidth = 170.w;
    final imageHeight = cardWidth / _imageAspectRatio;
    // Reserve room for three text lines, scaled with the text size.
    final infoHeight = 102.h * textScale;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: const SectionHeader(
            title: 'أبرز الدورات',
            color: AppColors.main600,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: imageHeight + infoHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: courses.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, i) => _CourseCard(
              course: courses[i],
              width: cardWidth,
              imageAspectRatio: _imageAspectRatio,
              onTap: () => onCourseTap?.call(courses[i]),
            ),
          ),
        ),
      ],
    );
  }
}

/// Card widget for the course.
class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.width,
    required this.imageAspectRatio,
    required this.onTap,
  });

  final CourseModel course;
  final double width;
  final double imageAspectRatio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);

    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.grey50),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: ColoredBox(
                  color: AppColors.second100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: AppNetworkImage(
                            url: course.image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: 8.h,
                        end: 8.w,
                        child: _SubscribersBadge(count: course.subscriptionsCount),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 6.w,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 20.w,
                            color: AppColors.second400,
                          ),
                          Expanded(
                            child: Text(
                              course.courseName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.font14Medium.copyWith(
                                color: AppColors.main600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        course.professor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.font12Regular.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${course.semestersCount} فصول ، ${course.lessonsCount} درس',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.font14Regular.copyWith(
                          color: AppColors.main600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge widget for the subscribers.
class _SubscribersBadge extends StatelessWidget {
  const _SubscribersBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.w,
        children: [
          Icon(
            PhosphorIconsRegular.users,
            size: 12.w,
            color: AppColors.second500,
          ),
          Text(
            '$count',
            style: AppTextStyles.font12Regular.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}
