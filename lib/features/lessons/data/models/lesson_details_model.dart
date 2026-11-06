import 'package:darb/features/courses/data/models/course_details_model.dart';
import 'package:darb/features/lessons/data/models/comment_model.dart';

/// رد lessions/details?id= الموحّد: الدرس + فصله بدروسه + تعليقاته.
/// يغني عن طلب comments/get-by-lession ويضمن اتساق الدرس والفصل والتعليقات.
class LessonDetailsModel {
  const LessonDetailsModel({
    required this.lesson,
    this.semesterName = '',
    this.semesterLessons = const [],
    this.comments = const [],
  });

  /// الدرس نفسه؛ رابط الفيديو في `url` والملف في `file` (يقرؤهما readLessonFile).
  final CourseLessonModel lesson;
  final String semesterName;

  /// دروس الفصل مرتبة، لـ "مسار التعلم".
  final List<CourseLessonModel> semesterLessons;
  final List<CommentModel> comments;

  factory LessonDetailsModel.fromJson(Map<String, dynamic> json) {
    final semesterJson = json['semester'] is Map<String, dynamic>
        ? json['semester'] as Map<String, dynamic>
        : null;
    final semester =
        semesterJson == null ? null : CourseSemesterModel.fromJson(semesterJson);
    return LessonDetailsModel(
      lesson: CourseLessonModel.fromJson(json),
      semesterName: semester?.name ?? '',
      semesterLessons: semester?.lessons ?? const [],
      comments: (json['comments'] as List? ?? const [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
