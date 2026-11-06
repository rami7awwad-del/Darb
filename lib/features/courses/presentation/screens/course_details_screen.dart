import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';
import 'package:darb/core/widgets/app_load_error.dart';
import 'package:darb/core/widgets/app_network_image.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';
import 'package:darb/features/courses/presentation/cubit/course_details_cubit.dart';
import 'package:darb/features/courses/presentation/lesson_access.dart';
import 'package:darb/features/courses/presentation/widgets/course_story_dialog.dart';
import 'package:darb/features/courses/presentation/widgets/lesson_timeline_tile.dart';
import 'package:darb/features/home/data/models/course_model.dart';

/// صفحة تفاصيل الدورة (Detail Page): صورة الدورة في شريط تركوازي، ثم الاسم والمدرّس
/// والوصف، ثم "مسار التعلم": كل فصل ودروسه. معلومات الرأس تأتي من [course] فورًا،
/// والوصف والفصول من courses/details. يتطلب CourseDetailsCubit في الشجرة.
class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.course});

  final CourseModel course;

  /// يمر بقيود الوصول: مقفل → اشتراك، منتظر → أكمل السابق، اختبار → تنبيه.
  /// بعد العودة (أو بعد اشتراك) تُحدَّث الدروس ليظهر المشاهَد/المفتوح.
  Future<void> _openLesson(
    BuildContext context,
    CourseLessonModel lesson,
    CourseSemesterModel semester,
  ) async {
    final cubit = context.read<CourseDetailsCubit>();
    final changed = await openLessonWithAccess(
      context,
      lesson: lesson,
      lessons: semester.lessons,
      semesterName: semester.name,
    );
    if (changed) cubit.load(silent: true);
  }

  /// نافذة التعريف (story): تظهر مرة عند أول تحميل إن طلبها الخادم.
  /// "ابدأ الآن" يفتح أول درس متاح في أول فصل فيه دروس.
  void _showStory(BuildContext context, CourseDetailsModel details) {
    showCourseStory(
      context,
      imageUrl: details.storyImage,
      text: details.storyText,
      onStart: () {
        for (final semester in details.semesters) {
          if (semester.lessons.isEmpty) continue;
          _openLesson(context, semester.lessons.first, semester);
          return;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CourseDetailsCubit, BaseState<CourseDetailsModel>>(
      listenWhen: (prev, curr) =>
          prev.data == null && (curr.data?.hasStory ?? false),
      listener: (context, state) => _showStory(context, state.data!),
      child: Scaffold(
      body: Column(
        children: [
          _Header(image: course.image, onBack: () => Navigator.pop(context)),
          Expanded(
            child: BlocBuilder<CourseDetailsCubit, BaseState<CourseDetailsModel>>(
              builder: (context, state) {
                final cubit = context.read<CourseDetailsCubit>();
                if (state.stateValue == StateValue.error) {
                  return AppLoadError(
                    message: state.errorMessage,
                    onRetry: cubit.load,
                  );
                }
                final details = state.data;
                return RefreshIndicator(
                  color: AppColors.main600,
                  onRefresh: () => cubit.load(silent: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h), // 📏
                    children: [
                      _Info(course: course, description: details?.description),
                      SizedBox(height: 16.h), // 📏
                      if (details == null)
                        Padding(
                          padding: EdgeInsets.only(top: 48.h), // 📏
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.main600,
                            ),
                          ),
                        )
                      else
                        ..._path(context, details),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }

  List<Widget> _path(BuildContext context, CourseDetailsModel details) {
    if (details.semesters.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.only(top: 32.h), // 📏
          child: Center(
            child: Text(
              'لا توجد دروس حاليًا',
              style: AppTextStyles.font14Regular.copyWith(
                color: AppColors.grey300,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      Row(
        spacing: 8.w, // 📏
        children: [
          Text(
            'مسار التعلم',
            style: AppTextStyles.font20Bold.copyWith(color: AppColors.grey700),
          ),
          Icon(Icons.route_outlined, size: 22.w, color: AppColors.second500),
        ],
      ),
      for (final s in details.semesters) ...[
        SizedBox(height: 16.h), // 📏
        Row(
          children: [
            Expanded(
              child: Text(
                s.name,
                style: AppTextStyles.font16Medium.copyWith(
                  color: AppColors.second600,
                ),
              ),
            ),
            Text(
              '${s.lessonsCount} درس',
              style: AppTextStyles.font12Regular.copyWith(
                color: AppColors.second500,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h), // 📏
        if (s.lessons.isEmpty)
          Text(
            'لا توجد دروس في هذا الفصل',
            style: AppTextStyles.font12Regular.copyWith(
              color: AppColors.grey300,
            ),
          )
        else
          for (var i = 0; i < s.lessons.length; i++)
            LessonTimelineTile(
              lesson: s.lessons[i],
              isLast: i == s.lessons.length - 1,
              onTap: () => _openLesson(context, s.lessons[i], s),
            ),
      ],
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.image, required this.onBack});

  final String image;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        height: 240.h, // 📏
        decoration: BoxDecoration(
          color: AppColors.main600,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(48.w, 24.h, 48.w, 0), // 📏
                  child: AppNetworkImage(url: image, fit: BoxFit.contain),
                ),
              ),
              PositionedDirectional(
                top: 16.h, // 📏
                start: 16.w, // 📏
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 24.w, // 📏
                    color: AppColors.white,
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

class _Info extends StatelessWidget {
  const _Info({required this.course, required this.description});

  final CourseModel course;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final text = description?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.h, // 📏
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                course.courseName,
                style: AppTextStyles.font20Bold.copyWith(
                  color: AppColors.main600,
                ),
              ),
            ),
            Text(
              course.professor,
              style: AppTextStyles.font14Medium.copyWith(
                color: AppColors.second600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${course.semestersCount} فصول , ${course.lessonsCount} درس',
                style: AppTextStyles.font12Regular.copyWith(
                  color: AppColors.grey400,
                ),
              ),
            ),
            Row(
              spacing: 4.w, // 📏
              children: [
                Text(
                  '${course.subscriptionsCount}',
                  style: AppTextStyles.font12Regular.copyWith(
                    color: AppColors.main600,
                  ),
                ),
                Icon(
                  Icons.visibility_outlined,
                  size: 14.w, // 📏
                  color: AppColors.second500,
                ),
              ],
            ),
          ],
        ),
        if (text.isNotEmpty) ...[
          const Divider(color: AppColors.grey50, height: 24),
          Text(
            'الوصف',
            style: AppTextStyles.font12Medium.copyWith(
              color: AppColors.second500,
            ),
          ),
          Text(
            text,
            style: AppTextStyles.font14Regular.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ],
    );
  }
}
