/// يحوّل نص HTML القادم من الـ API (مثل <p>..&nbsp;</p>) إلى نص عادي.
String stripHtml(dynamic value) {
  var s = (value ?? '').toString();
  s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'<[^>]*>'), '');
  s = s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&');
  s = s.replaceAll(RegExp(r'[ \t\u00A0]+'), ' ');
  return s.trim();
}

/// جواب واحد داخل سؤال (answers[] في subjects/details).
class QuizAnswer {
  const QuizAnswer({
    required this.id,
    required this.title,
    this.correct = false,
    this.selected = false,
  });

  final int id;
  final String title;
  final bool correct;

  /// `current_answer` في exams/result: إجابة الطالب المسجّلة (غائب قبل الحضور).
  final bool selected;

  factory QuizAnswer.fromJson(Map<String, dynamic> json) => QuizAnswer(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: stripHtml(json['title']),
        correct: json['correct'] as bool? ?? false,
        selected: json['current_answer'] == true || json['current_answer'] == 1,
      );
}

/// سؤال (questions[] داخل exam).
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.title,
    required this.answers,
  });

  final int id;
  final String title;
  final List<QuizAnswer> answers;

  QuizAnswer? get correctAnswer {
    for (final a in answers) {
      if (a.correct) return a;
    }
    return null;
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: stripHtml(json['title']),
        answers: (json['answers'] as List? ?? const [])
            .map((e) => QuizAnswer.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// معاملات فتح شاشة الاختبار.
class QuizArgs {
  const QuizArgs({
    required this.title,
    required this.questions,
    required this.examId,
  });

  /// معرّف الاختبار (exam.id): يُستخدم لجلب النتيجة بعد التسليم.
  final int examId;
  final String title;
  final List<QuizQuestion> questions;
}

/// نتيجة محاولة: تُحسب محليًا من علامة correct في كل جواب.
/// ⚠️ الأسئلة غير المجابة تُحسب خاطئة.
class QuizOutcome {
  const QuizOutcome({
    required this.title,
    required this.questions,
    required this.selected,
  });

  final String title;
  final List<QuizQuestion> questions;

  /// questionId → answerId
  final Map<int, int> selected;

  QuizAnswer? selectedAnswer(QuizQuestion q) {
    final id = selected[q.id];
    if (id == null) return null;
    for (final a in q.answers) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// نتيجة من exams/result: الإجابات المختارة تُقرأ من `current_answer`، فتطابق
  /// حساب الخادم نفسه.
  factory QuizOutcome.fromDetails(QuizDetails details, {String? title}) {
    final selected = <int, int>{};
    for (final q in details.questions) {
      for (final a in q.answers) {
        if (a.selected) selected[q.id] = a.id;
      }
    }
    return QuizOutcome(
      title: title ?? details.title,
      questions: details.questions,
      selected: selected,
    );
  }

  bool isCorrect(QuizQuestion q) => selectedAnswer(q)?.correct ?? false;

  int get total => questions.length;
  int get correct => questions.where(isCorrect).length;
  int get wrong => total - correct;
  int get percent => total == 0 ? 0 : ((correct * 100) / total).round();
}


/// رد exams/result?id= : الاختبار بأسئلته وأجوبته (+ current_answer بعد الحضور).
class QuizDetails {
  const QuizDetails({
    required this.id,
    required this.title,
    required this.questionsCount,
    required this.correctAnswers,
    required this.failedAnswers,
    required this.questions,
  });

  final int id;
  final String title;
  final int questionsCount;
  final int correctAnswers;
  final int failedAnswers;
  final List<QuizQuestion> questions;

  /// حضر الطالب الاختبار (له إجابة مسجّلة واحدة على الأقل).
  bool get attended =>
      questions.any((q) => q.answers.any((a) => a.selected));

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  factory QuizDetails.fromJson(Map<String, dynamic> json) {
    // قد يأتي الاختبار مغلّفًا بـ exam أو في المستوى الأعلى.
    final inner =
        json['exam'] is Map<String, dynamic> ? json['exam'] as Map<String, dynamic> : json;
    final questions = (inner['questions'] as List? ?? const [])
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    return QuizDetails(
      id: _int(inner['id']),
      title: stripHtml(inner['title'] ?? inner['name']),
      questionsCount: inner['questions_count'] == null
          ? questions.length
          : _int(inner['questions_count']),
      correctAnswers: _int(json['correct_answers'] ?? inner['correct_answers']),
      failedAnswers: _int(json['failed_answers'] ?? inner['failed_answers']),
      questions: questions,
    );
  }
}

/// رد POST exams/attend-exam: ثلاثة أعداد بلا معرّف اختبار.
class QuizScore {
  const QuizScore({
    required this.questionsCount,
    required this.correctAnswers,
    required this.failedAnswers,
  });

  final int questionsCount;
  final int correctAnswers;
  final int failedAnswers;

  factory QuizScore.fromJson(Map<String, dynamic> json) => QuizScore(
        questionsCount: (json['questions_count'] as num?)?.toInt() ?? 0,
        correctAnswers: (json['correct_answers'] as num?)?.toInt() ?? 0,
        failedAnswers: (json['failed_answers'] as num?)?.toInt() ?? 0,
      );
}

/// عنصر قائمة exams/my أو daily-activities/my.
/// ⚠️ شكل العنصر لم يُرَ فعليًا (القائمة كانت فارغة عند الزميل)، لذلك يُقرأ
/// بغلاف `exam` أو من المستوى الأعلى والحقول الغائبة بقيم افتراضية.
class QuizListItem {
  const QuizListItem({
    required this.id,
    required this.title,
    this.professor = '',
    this.questionsCount = 0,
    this.isActivity = false,
  });

  final int id;
  final String title;
  final String professor;
  final int questionsCount;
  final bool isActivity;

  factory QuizListItem.fromJson(
    Map<String, dynamic> json, {
    required bool isActivity,
  }) {
    final inner =
        json['exam'] is Map<String, dynamic> ? json['exam'] as Map<String, dynamic> : json;
    return QuizListItem(
      id: (inner['id'] as num?)?.toInt() ?? 0,
      title: stripHtml(inner['title'] ?? inner['name']),
      professor: inner['professor'] as String? ?? '',
      questionsCount: (inner['questions_count'] as num?)?.toInt() ?? 0,
      isActivity: isActivity,
    );
  }
}
