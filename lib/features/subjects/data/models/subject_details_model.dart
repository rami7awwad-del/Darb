import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/subjects/data/models/subject_exam_model.dart';

/// رد subjects/details?id= : { content, exams, dailyActivities }.
/// content قد يأتي كائنًا واحدًا (دورة) أو مصفوفة دورات، ونقبل الشكلين.
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
