import 'package:darb/features/courses/data/models/course_details_model.dart';
import 'package:darb/features/lessons/data/models/comment_model.dart';

/// Model that holds the lesson details data parsed from the API.
class LessonDetailsModel {
  const LessonDetailsModel({
    required this.lesson,
    this.semesterName = '',
    this.semesterLessons = const [],
    this.comments = const [],
  });

  final CourseLessonModel lesson;
  final String semesterName;

  final List<CourseLessonModel> semesterLessons;
  final List<CommentModel> comments;

  /// Builds the object from the API json.
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
