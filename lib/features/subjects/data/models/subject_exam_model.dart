/// عنصر اختبار أو نشاط يومي داخل subjects/details (exams / dailyActivities).
/// ⚠️ افتراض: النشاط اليومي بنفس حقول الاختبار (title, professor, questions_count,
/// subscriptions_count). رد النشاط لم يُرَ بعد؛ إن اختلفت الحقول عدّل fromJson فقط.
class SubjectExamModel {
  const SubjectExamModel({
    required this.id,
    required this.title,
    this.professor = '',
    this.questionsCount = 0,
    this.subscriptionsCount = 0,
    this.isFree = false,
    this.isSubscription = false,
  });

  final int id;
  final String title;
  final String professor;
  final int questionsCount;
  final int subscriptionsCount;
  final bool isFree;
  final bool isSubscription;

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  factory SubjectExamModel.fromJson(Map<String, dynamic> json) =>
      SubjectExamModel(
        id: _int(json['id']),
        title: (json['title'] ?? json['name'] ?? '').toString(),
        professor: json['professor'] as String? ?? '',
        questionsCount: _int(json['questions_count']),
        subscriptionsCount: _int(json['subscriptions_count']),
        isFree: json['is_free'] as bool? ?? false,
        isSubscription: json['is_subscription'] as bool? ?? false,
      );
}
