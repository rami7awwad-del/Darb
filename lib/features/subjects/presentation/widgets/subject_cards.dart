import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/subjects/data/models/subject_exam_model.dart';
import 'package:darb/features/subjects/presentation/widgets/subject_icons.dart';

/// Widget that shows the card shell.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.second100),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(padding: EdgeInsets.all(12.w), child: child),
      ),
    );
  }
}

/// Card widget for the subject course.
class SubjectCourseCard extends StatelessWidget {
  const SubjectCourseCard({super.key, required this.course, this.onTap});

  final CourseModel course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = 100.w;
    return _CardShell(
      onTap: onTap,
      child: Row(
        spacing: 12.w,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.second100,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: AppNetworkImage(
                url: course.image,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4.h,
              children: [
                Row(
                  spacing: 6.w,
                  children: [
                    Icon(
                      SubjectIcons.course,
                      size: 18.w,
                      color: AppColors.second500,
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
                _ProfessorRow(
                  professor: course.professor,
                  subscribers: course.subscriptionsCount,
                ),
                Text(
                  '${course.semestersCount} فصول , ${course.lessonsCount} درس',
                  style: AppTextStyles.font12Medium.copyWith(
                    color: AppColors.main600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Possible values for the subject exam kind.
enum SubjectExamKind { exam, activity }

/// Card widget for the subject exam.
class SubjectExamCard extends StatelessWidget {
  const SubjectExamCard({
    super.key,
    required this.exam,
    required this.kind,
    this.onTap,
  });

  final SubjectExamModel exam;
  final SubjectExamKind kind;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isExam = kind == SubjectExamKind.exam;
    return _CardShell(
      onTap: onTap,
      child: Row(
        spacing: 12.w,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: isExam ? Colors.transparent : AppColors.second50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExam ? SubjectIcons.exam : SubjectIcons.activity,
              size: 56.w,
              color: AppColors.second500,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4.h,
              children: [
                Text(
                  exam.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font14Medium.copyWith(
                    color: AppColors.main600,
                  ),
                ),
                _ProfessorRow(
                  professor: exam.professor,
                  subscribers: exam.subscriptionsCount,
                ),
                Text(
                  '${exam.questionsCount} سؤال',
                  style: AppTextStyles.font12Medium.copyWith(
                    color: AppColors.main600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Row widget for the professor.
class _ProfessorRow extends StatelessWidget {
  const _ProfessorRow({required this.professor, required this.subscribers});

  final String professor;
  final int subscribers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            professor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font12Regular.copyWith(
              color: AppColors.grey400,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4.w,
          children: [
            Text(
              '$subscribers',
              style: AppTextStyles.font12Regular.copyWith(
                color: AppColors.main600,
              ),
            ),
            Icon(
              SubjectIcons.subscribers,
              size: 14.w,
              color: AppColors.second500,
            ),
          ],
        ),
      ],
    );
  }
}
