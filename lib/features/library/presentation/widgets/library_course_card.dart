import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/library/presentation/widgets/library_progress_row.dart';

/// بطاقة كورس في "موادي": الصورة في البداية، ثم اسم الدورة والمدرس وعدد الفصول
/// والدروس، ثم اسم المادة وشريطا التقدم وزر "متابعة التعلم".
/// ⚠️ ربط الحقول (افتراضات):
///  - اسم الدورة (بجانب الأيقونة) = course_name، والمادة (عنوان عريض) = name.
///  - "الوحدات المكتملة" = semester_rate، و"الدروس المنجزة" = lession_rate.
/// ⚠️ قياس تقديري: قطر الصورة (96) وخلفيتها الدائرية (second100) وRadius البطاقة (16).
class LibraryCourseCard extends StatelessWidget {
  const LibraryCourseCard({
    super.key,
    required this.course,
    this.onContinue,
    this.showAction = true,
    this.outlined = false,
  });

  final CourseModel course;
  final VoidCallback? onContinue;

  /// إظهار زر "متابعة التعلم" (يُخفى داخل بطاقة الباقة كما في Figma).
  final bool showAction;

  /// حد رفيع بدل الظل (البطاقة المتداخلة داخل الباقة).
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: outlined ? Border.all(color: const Color(0xFFDBDBDB)) : null,
        boxShadow: outlined
            ? null
            : [
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
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12.w,
            children: [
              Container(
                width: 96.w,
                height: 96.w,
                decoration: const BoxDecoration(
                  color: AppColors.second100,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: AppNetworkImage(
                    url: course.image,
                    width: 96.w,
                    height: 96.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6.h,
                  children: [
                    Row(
                      spacing: 6.w,
                      children: [
                        Icon(
                          PhosphorIconsRegular.bookOpen,
                          size: 18.w,
                          color: AppColors.main600,
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
                    Text(
                      course.professor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.font12Regular.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                    Text(
                      '${course.semestersCount} فصول ، ${course.lessonsCount} درس',
                      style: AppTextStyles.font14Medium.copyWith(
                        color: AppColors.main600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            course.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font14Bold.copyWith(color: AppColors.grey700),
          ),
          SizedBox(height: 8.h),
          LibraryProgressRow(
            label: 'الوحدات المكتملة',
            percent: course.semesterRate,
          ),
          SizedBox(height: 6.h),
          LibraryProgressRow(
            label: 'الدروس المنجزة',
            percent: course.lessonRate,
          ),
          if (showAction) ...[
            SizedBox(height: 16.h),
            AppOutlineButton(text: 'متابعة التعلم', onPressed: onContinue),
          ],
        ],
      ),
    );
  }
}
