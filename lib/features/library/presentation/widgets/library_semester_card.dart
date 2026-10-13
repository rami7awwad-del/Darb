import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_outline_button.dart';
import 'package:darb/features/library/data/models/library_semester.dart';
import 'package:darb/features/library/presentation/widgets/library_progress_row.dart';

/// بطاقة فصل: اسم الفصل والمدرس في البداية، والنقاط في النهاية، ثم خط فاصل
/// واسم المادة وشريط تقدم الدروس وزر "متابعة التعلم".
/// ⚠️ في Figma نص الشريط "الفصول : 2 من 9"؛ استخدمت "الدروس" لأن القيمة هي
/// الدروس المنجزة من دروس الفصل (is_attended / lessions_count). غيّره إن أردت.
/// ⚠️ "النقاط" مأخوذة من الكورس الأب (points_count).
/// ⚠️ قياس تقديري: Radius البطاقة (16) والحشوة (16) والفاصل (#E5E5E5).
class LibrarySemesterCard extends StatelessWidget {
  const LibrarySemesterCard({
    super.key,
    required this.semester,
    this.onContinue,
  });

  final LibrarySemester semester;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
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
                      semester.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.font14Medium.copyWith(
                        color: AppColors.main600,
                      ),
                    ),
                    Text(
                      semester.professor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.font12Regular.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${semester.points} نقطة',
                style: AppTextStyles.font14Medium.copyWith(
                  color: AppColors.main600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          SizedBox(height: 12.h),
          Text(
            semester.subjectName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font14Bold.copyWith(color: AppColors.grey700),
          ),
          SizedBox(height: 8.h),
          LibraryProgressRow(
            label:
                'الدروس : ${semester.attendedCount} من ${semester.lessonsCount}',
            percent: semester.lessonRate,
          ),
          SizedBox(height: 16.h),
          AppOutlineButton(text: 'متابعة التعلم', onPressed: onContinue),
        ],
      ),
    );
  }
}
