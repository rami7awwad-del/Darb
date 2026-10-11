import 'package:darb/features/home/data/models/subject_model.dart';

/// اختبار مختصر من نتائج البحث (الأسئلة والإجابات غير مقروءة).
class ExamBriefModel {
  const ExamBriefModel({
    required this.id,
    required this.title,
    required this.professor,
    this.questionsCount = 0,
    this.isFree = false,
  });

  final int id;
  final String title;
  final String professor;
  final int questionsCount;
  final bool isFree;

  factory ExamBriefModel.fromJson(Map<String, dynamic> json) => ExamBriefModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        professor: json['professor'] as String? ?? '',
        questionsCount: (json['questions_count'] as num?)?.toInt() ?? 0,
        isFree: json['is_free'] as bool? ?? false,
      );
}

/// رد home-page/search. TODO: dailyActivities (قائمة فارغة، شكلها غير معروف).
class SearchResultModel {
  const SearchResultModel({this.subjects = const [], this.exams = const []});

  final List<SubjectModel> subjects;
  final List<ExamBriefModel> exams;

  bool get isEmpty => subjects.isEmpty && exams.isEmpty;

  factory SearchResultModel.fromJson(Map<String, dynamic> json) =>
      SearchResultModel(
        subjects: (json['subjects'] as List? ?? const [])
            .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        exams: (json['exams'] as List? ?? const [])
            .map((e) => ExamBriefModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
