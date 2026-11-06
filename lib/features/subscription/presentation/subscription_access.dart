import 'package:flutter/material.dart';

import 'package:darb/core/navigation/app_navigator.dart';
import 'package:darb/core/routing/app_routes.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/subscription/presentation/widgets/subscribe_dialog.dart';

/// Opens subject with access.
Future<void> openSubjectWithAccess(
  BuildContext context,
  SubjectModel subject,
) async {
  if (!(subject.isFree || subject.isSubscription)) {
    final subscribed = await showSubscribeDialog(
      context,
      title: 'اشترك الآن واحصل عليها',
    );
    if (!subscribed) return;
  }
  await navigatorKey.currentState?.pushNamed(
    AppRoutes.subjectDetails,
    arguments: subject,
  );
}

/// Opens course with access.
Future<void> openCourseWithAccess(
  BuildContext context,
  CourseModel course,
) async {
  if (!(course.isFree || course.isSubscription)) {
    final subscribed = await showSubscribeDialog(
      context,
      title: 'اشترك الآن واحصل عليها',
    );
    if (!subscribed) return;
  }
  await navigatorKey.currentState?.pushNamed(
    AppRoutes.courseDetails,
    arguments: course,
  );
}
