import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/home/data/models/news_model.dart';
import 'package:darb/features/home/data/models/subject_model.dart';

/// رد home-page/index.
/// sliders غير مقروءة: البانر في الواجهة UI ثابت حسب الطلب.
class HomeDataModel {
  const HomeDataModel({
    required this.subjects,
    required this.news,
    required this.courses,
    this.notificationUnread = 0,
    this.completionRate = 0,
    this.subjectCount = 0,
  });

  final List<SubjectModel> subjects;
  final List<NewsModel> news;
  final List<CourseModel> courses;
  final int notificationUnread;

  /// نسبة تقدم المنهاج. ⚠️ افتراض: قيمة من 0 إلى 100 (تحقق عند وجود بيانات حقيقية).
  final double completionRate;

  /// عدد الكورسات في بطاقة "تقدم المنهاج". ⚠️ افتراض: subject_count من index.
  final int subjectCount;

  static List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) f) =>
      (raw as List? ?? const [])
          .map((e) => f(e as Map<String, dynamic>))
          .toList();

  factory HomeDataModel.fromJson(Map<String, dynamic> json) => HomeDataModel(
        subjects: _list(json['subjects'], SubjectModel.fromJson),
        news: _list(json['news'], NewsModel.fromJson),
        courses: _list(json['courses'], CourseModel.fromJson),
        notificationUnread: (json['notification_unread'] as num?)?.toInt() ?? 0,
        completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0,
        subjectCount: (json['subject_count'] as num?)?.toInt() ?? 0,
      );
}
