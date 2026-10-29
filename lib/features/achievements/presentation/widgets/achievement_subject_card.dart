import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/core/widgets/app_progress_bar.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/profile/presentation/widgets/profile_icons.dart';

/// بطاقة مادة في "إنجازاتي": رأس (بلاطة المادة + نسبة التقدم) ثم 3 صفوف تقدم
/// (النقاط، الفصول، الدروس).
/// ⚠️ الرقم الكلي على يسار كل صف (مثل 600) غير موجود في الرد؛ يُشتق من
/// العدد والنسبة (العدد × 100 ÷ النسبة) ولا يظهر إن كانت النسبة صفرًا.
/// 📏 القياسات: بلاطة المادة 104×67، Radius البطاقة 16، حشوة البطاقة 12،
/// ارتفاع الصف 54، حجم أيقونة الصف 34، حجم الخطوط، ارتفاع الشريط (5).
class AchievementSubjectCard extends StatelessWidget {
  const AchievementSubjectCard({super.key, required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w), // 📏
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r), // 📏
        border: Border.all(color: AppColors.grey50),
        boxShadow: AppShadows.midLight,
      ),
      child: Column(
        children: [
          _Header(course: course),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h), // 📏
            child: const Divider(height: 1, color: AppColors.grey50),
          ),
          _ProgressRow(
            icon: ProfileIcons.points,
            label: 'النقاط',
            count: course.pointsCount,
            rate: course.pointRate,
            color: AppColors.second500,
          ),
          SizedBox(height: 12.h), // 📏
          _ProgressRow(
            icon: ProfileIcons.semesters,
            label: 'الفصول',
            count: course.semestersCount,
            rate: course.semesterRate,
            color: AppColors.second500,
          ),
          SizedBox(height: 12.h), // 📏
          _ProgressRow(
            icon: ProfileIcons.lessons,
            label: 'الدروس',
            count: course.lessonsCount,
            rate: course.lessonRate,
            color: AppColors.main600,
          ),
        ],
      ),
    );
  }
}

String _percent(double rate) => '${rate.round()}%';

class _Header extends StatelessWidget {
  const _Header({required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 104.w, // 📏
          height: 67.h, // 📏
          padding: EdgeInsets.all(6.w), // 📏
          decoration: BoxDecoration(
            color: AppColors.second400,
            borderRadius: BorderRadius.circular(11.r), // 📏
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                course.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.font12Regular.copyWith(
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: 4.h), // 📏
              Expanded(
                child: AppNetworkImage(
                  url: course.image,
                  width: 32.w, // 📏
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w), // 📏
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _percent(course.subjectRate),
                style: AppTextStyles.font12Regular.copyWith(
                  color: AppColors.main600,
                ),
              ),
              SizedBox(height: 4.h), // 📏
              AppProgressBar(value: course.subjectRate / 100),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.rate,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final double rate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // الرقم الكلي مشتق (انظر ملاحظة الكلاس).
    final total = rate > 0 ? (count * 100 / rate).round() : null;

    return Row(
      children: [
        Container(
          width: 34.w, // 📏
          height: 34.w, // 📏
          decoration: BoxDecoration(
            color: AppColors.second50,
            borderRadius: BorderRadius.circular(8.r), // 📏
          ),
          child: Icon(icon, size: 20.w, color: AppColors.second500), // 📏
        ),
        SizedBox(width: 8.w), // 📏
        SizedBox(
          width: 72.w, // 📏
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$count ',
                  style: AppTextStyles.font12Regular.copyWith(
                    color: AppColors.second500,
                  ),
                ),
                TextSpan(
                  text: label,
                  style: AppTextStyles.font14Regular.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    _percent(rate),
                    style: AppTextStyles.font12Regular.copyWith(
                      color: AppColors.main600,
                    ),
                  ),
                  const Spacer(),
                  if (total != null)
                    Text(
                      '$total',
                      style: AppTextStyles.font12Regular.copyWith(
                        color: AppColors.second500,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.h), // 📏
              AppProgressBar(value: rate / 100, color: color),
            ],
          ),
        ),
      ],
    );
  }
}
