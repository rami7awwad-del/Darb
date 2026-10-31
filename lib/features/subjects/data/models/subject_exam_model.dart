import 'package:darb/features/quiz/data/models/quiz_models.dart';

/// عنصر اختبار أو نشاط يومي داخل subjects/details (exams / dailyActivities).
/// شكل الرد: { id, expiry_date, type, is_free, exam: { id, title, professor,
/// questions[], questions_count, subscriptions_count, ... } }.
/// الحقول الأساسية داخل `exam`، ونقبل أيضًا الشكل المسطّح احتياطًا.
class SubjectExamModel {
  const SubjectExamModel({
    required this.id,
    required this.title,
    this.entryId = 0,
    this.professor = '',
    this.questions = const [],
    this.questionsCount = 0,
    this.subscriptionsCount = 0,
    this.isFree = false,
    this.isSubscription = false,
    this.expiryDate,
  });

  /// معرّف الاختبار نفسه (exam.id).
  final int id;

  /// معرّف السجل الخارجي (المغلِّف) في القائمة.
  final int entryId;
  final String title;
  final String professor;
  final List<QuizQuestion> questions;
  final int questionsCount;
  final int subscriptionsCount;
  final bool isFree;
  final bool isSubscription;
  final String? expiryDate;

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  factory SubjectExamModel.fromJson(Map<String, dynamic> json) {
    final inner = json['exam'] is Map<String, dynamic>
        ? json['exam'] as Map<String, dynamic>
        : json;
    final questions = (inner['questions'] as List? ?? const [])
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    return SubjectExamModel(
      id: _int(inner['id']),
      entryId: _int(json['id']),
      title: stripHtml(inner['title'] ?? inner['name']),
      professor: inner['professor'] as String? ?? '',
      questions: questions,
      questionsCount: inner['questions_count'] == null
          ? questions.length
          : _int(inner['questions_count']),
      subscriptionsCount: _int(inner['subscriptions_count']),
      isFree: json['is_free'] as bool? ?? inner['is_free'] as bool? ?? false,
      isSubscription: inner['is_subscription'] as bool? ?? false,
      expiryDate: json['expiry_date'] as String?,
    );
  }
}
