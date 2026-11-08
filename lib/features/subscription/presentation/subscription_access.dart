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

/// True when the user can open the course without paying.
bool hasCourseAccess(CourseModel course) =>
    course.isFree || course.isSubscription;

/// Home course tap: opens the course when the user has access, otherwise
/// goes straight to the subscription page.
///
/// If the user subscribes there (the page pops with `true`), [onSubscribed]
/// is called and the course is opened.
Future<void> openCourseOrSubscription(
  BuildContext context,
  CourseModel course, {
  VoidCallback? onSubscribed,
}) async {
  final navigator = Navigator.of(context);

  if (!hasCourseAccess(course)) {
    final subscribed = await navigator.pushNamed<bool>(AppRoutes.subscription);
    if (subscribed != true) return;
    onSubscribed?.call();
  }

  await navigator.pushNamed(AppRoutes.courseDetails, arguments: course);
}
