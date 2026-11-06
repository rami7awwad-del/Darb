import 'package:darb/features/home/data/models/subject_model.dart';

/// Model that holds the exam brief data parsed from the API.
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

  /// Builds the object from the API json.
  factory ExamBriefModel.fromJson(Map<String, dynamic> json) => ExamBriefModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        professor: json['professor'] as String? ?? '',
        questionsCount: (json['questions_count'] as num?)?.toInt() ?? 0,
        isFree: json['is_free'] as bool? ?? false,
      );
}

/// Model that holds the search result data parsed from the API.
class SearchResultModel {
  const SearchResultModel({this.subjects = const [], this.exams = const []});

  final List<SubjectModel> subjects;
  final List<ExamBriefModel> exams;

  bool get isEmpty => subjects.isEmpty && exams.isEmpty;

  /// Builds the object from the API json.
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
