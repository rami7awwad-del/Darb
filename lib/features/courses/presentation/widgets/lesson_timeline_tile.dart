import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';

/// List tile widget for the lesson timeline.
class LessonTimelineTile extends StatelessWidget {
  const LessonTimelineTile({
    super.key,
    required this.lesson,
    required this.isLast,
    required this.onTap,
  });

  final CourseLessonModel lesson;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32.w,
            child: Column(
              children: [
                _Indicator(lesson: lesson),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(width: 2.w, color: AppColors.second100),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              child: _LessonCard(lesson: lesson, onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small private widget used only in this file.
class _Indicator extends StatelessWidget {
  const _Indicator({required this.lesson});

  final CourseLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color background;
    final Color color;
    if (lesson.isLocked) {
      icon = Icons.lock_outline_rounded;
      background = AppColors.grey50;
      color = AppColors.grey200;
    } else if (lesson.isAttended) {
      icon = Icons.check_rounded;
      background = AppColors.successLight;
      color = AppColors.success;
    } else {
      icon = lesson.isFile
          ? Icons.description_outlined
          : Icons.play_arrow_rounded;
      background = AppColors.main600;
      color = AppColors.white;
    }
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: 18.w, color: color),
    );
  }
}

/// Card widget for the lesson.
class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.onTap});

  final CourseLessonModel lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    final muted = lesson.isLocked;
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.second100),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.h,
            children: [
              Text(
                lesson.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.font14Medium.copyWith(
                  color: muted ? AppColors.grey200 : AppColors.main600,
                ),
              ),
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: [
                  _Chip(
                    icon: lesson.isFile
                        ? Icons.description_outlined
                        : Icons.play_circle_outline_rounded,
                    text: lesson.isFile ? 'ملف' : 'فيديو',
                  ),
                  if (lesson.time.isNotEmpty)
                    _Chip(icon: Icons.schedule_rounded, text: lesson.time),
                  if (lesson.isFree && !lesson.isSubscription)
                    const _Chip(
                      icon: Icons.lock_open_rounded,
                      text: 'مجاني',
                      color: AppColors.success,
                      background: AppColors.successLight,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small private widget used only in this file.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.text,
    this.color = AppColors.grey400,
    this.background = AppColors.second50,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.w,
        children: [
          Icon(icon, size: 14.w, color: color),
          Text(text, style: AppTextStyles.font12Regular.copyWith(color: color)),
        ],
      ),
    );
  }
}
