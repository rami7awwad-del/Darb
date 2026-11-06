import 'package:darb/features/home/data/models/course_model.dart';

/// يحوّل data الخاص بـ subscriptions/my إلى بطاقات دورات.
/// الشكل: `{subjects: [{id, price, subject: {...بطاقة الدورة}}]}`؛ وبلا اشتراكات
/// يعيد الخادم `data: []`. المادة المكررة في أكثر من اشتراك تُعرض مرة واحدة.
/// يقبل أيضًا قائمة عناصر مباشرة احتياطًا.
List<CourseModel> parseSubscribedCourses(dynamic data) {
  final List items;
  if (data is Map<String, dynamic>) {
    items = (data['subjects'] as List?) ?? const [];
  } else if (data is List) {
    items = data;
  } else {
    return const [];
  }
  final courses = <int, CourseModel>{};
  for (final item in items) {
    final map = item as Map<String, dynamic>;
    final card = map['subject'] is Map<String, dynamic>
        ? map['subject'] as Map<String, dynamic>
        : map;
    final course = CourseModel.fromJson(card);
    courses.putIfAbsent(course.id, () => course);
  }
  return courses.values.toList();
}
