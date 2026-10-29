import 'package:darb/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/home/presentation/widgets/section_header.dart';

/// قسم "أبرز الدورات": بطاقات أفقية.
/// ⚠️ قياس تقديري: عرض البطاقة (170) وارتفاع الصورة (110) وارتفاع القائمة (212)،
/// ورأس البطاقة (second100) فوق جسم أبيض، والألوان التفاعلية main600 حسب Figma.
/// ⚠️ أيقونة العنوان بديلة مؤقتًا (التصميم فيه رسمة دفتر لم تصلنا كملف).
/// ⚠️ الشارة العلوية = subscriptions_count، والعنوان = course_name (افتراضان).
class CoursesSection extends StatelessWidget {
  const CoursesSection({super.key, required this.courses, this.onCourseTap});

  final List<CourseModel> courses;
  final ValueChanged<CourseModel>? onCourseTap;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();

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
          height: 212.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: courses.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, i) => _CourseCard(
              course: courses[i],
              onTap: () => onCourseTap?.call(courses[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final CourseModel course;
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
          width: 170.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة: خلفية زرقاء فاتحة والصورة فوقها.
              Container(
                color: AppColors.second100,
                width: double.infinity,
                height: 110.h,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AppNetworkImage(
                        url: course.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                    PositionedDirectional(
                      top: 8.h,
                      end: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
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
                              '${course.subscriptionsCount}',
                              style: AppTextStyles.font12Regular.copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
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
                      style: AppTextStyles.font14Regular.copyWith(
                        color: AppColors.main600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
