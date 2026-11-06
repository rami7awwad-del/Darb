import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/core/widgets/app_snack_bar.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';
import 'package:darb/features/courses/presentation/widgets/finish_previous_dialog.dart';
import 'package:darb/features/lessons/presentation/screens/lesson_screen.dart';
import 'package:darb/features/subscription/presentation/widgets/subscribe_dialog.dart';
import 'package:flutter/material.dart';

/// حالة الدرس في "مسار التعلم".
enum LessonStep {
  /// يُفتح الآن.
  open,

  /// مدفوع والطالب غير مشترك.
  locked,

  /// مفتوح، لكن قبله في فصله درس مفتوح لم يحضره الطالب بعد.
  waiting,

  /// اختبار: لا صفحة درس له في التطبيق.
  exam,
}

class LessonAccess {
  const LessonAccess(this.step, {this.previous});

  final LessonStep step;

  /// للدرس المنتظر: الدرس الذي يكمله الطالب أولًا.
  final CourseLessonModel? previous;
}

/// يحدد حالة [lesson] ضمن دروس فصله [lessons] (بترتيبها).
/// الترتيب: الدرس المفتوح ينتظر حتى يحضر الطالب ما قبله من الدروس المفتوحة.
/// ⚠️ الخادم لا يفرض هذا الترتيب؛ هو قيد واجهة فقط. الاختبار والدرس المقفل لا
/// يوقفان ما بعدهما لأن الطالب لا يستطيع إنهاءهما من شاشة الدروس.
LessonAccess lessonAccess(
  List<CourseLessonModel> lessons,
  CourseLessonModel lesson,
) {
  if (lesson.isExam) return const LessonAccess(LessonStep.exam);
  if (lesson.isLocked) return const LessonAccess(LessonStep.locked);
  CourseLessonModel? pending;
  for (final l in lessons) {
    if (l.id == lesson.id) break;
    if (l.isExam || l.isLocked || l.isAttended) continue;
    pending ??= l;
  }
  return pending == null
      ? const LessonAccess(LessonStep.open)
      : LessonAccess(LessonStep.waiting, previous: pending);
}

/// نقطة الدخول الوحيدة لفتح درس مع قيود الوصول:
/// مقفل → حوار اشتراك، منتظر → حوار إكمال السابق، اختبار → تنبيه، وإلا يُفتح.
/// يعيد true إن اشترك الطالب أو عاد من الدرس (ليحدّث المستدعي بياناته).
Future<bool> openLessonWithAccess(
  BuildContext context, {
  required CourseLessonModel lesson,
  required List<CourseLessonModel> lessons,
  required String semesterName,
  bool replace = false,
}) async {
  final access = lessonAccess(lessons, lesson);
  switch (access.step) {
    case LessonStep.locked:
      return showSubscribeDialog(context);
    case LessonStep.exam:
      showAppSnackBar(context, 'الاختبارات تجدها في "إختباراتي" من الملف الشخصي');
      return false;
    case LessonStep.waiting:
      await showFinishPreviousDialog(
        context,
        onStart: () => openLessonWithAccess(
          context,
          lesson: access.previous!,
          lessons: lessons,
          semesterName: semesterName,
          replace: replace,
        ),
      );
      return false;
    case LessonStep.open:
      final args = LessonArgs(
        lesson: lesson,
        semesterName: semesterName,
        lessons: lessons,
      );
      if (replace) {
        await Navigator.pushReplacementNamed(
          context,
          AppRoutes.lesson,
          arguments: args,
        );
      } else {
        await Navigator.pushNamed(context, AppRoutes.lesson, arguments: args);
      }
      return true;
  }
}
