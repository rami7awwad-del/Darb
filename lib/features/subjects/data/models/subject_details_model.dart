import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/subjects/data/models/subject_exam_model.dart';

/// Model that holds the subject details data parsed from the API.
class SubjectDetailsModel {
  const SubjectDetailsModel({
    this.courses = const [],
    this.exams = const [],
    this.dailyActivities = const [],
  });

  final List<CourseModel> courses;
  final List<SubjectExamModel> exams;
  final List<SubjectExamModel> dailyActivities;

  static List<SubjectExamModel> _exams(dynamic raw) => (raw as List? ?? const [])
      .map((e) => SubjectExamModel.fromJson(e as Map<String, dynamic>))
      .toList();

  /// Builds the object from the API json.
  factory SubjectDetailsModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    final courses = switch (content) {
      Map<String, dynamic> m => [CourseModel.fromJson(m)],
      List l => l
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      _ => <CourseModel>[],
    };
    return SubjectDetailsModel(
      courses: courses,
      exams: _exams(json['exams']),
      dailyActivities: _exams(json['dailyActivities']),
    );
  }
}
