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
  });

  final int id;
  final String title;
  final bool correct;

  factory QuizAnswer.fromJson(Map<String, dynamic> json) => QuizAnswer(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: stripHtml(json['title']),
        correct: json['correct'] as bool? ?? false,
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
  const QuizArgs({required this.title, required this.questions});

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

  bool isCorrect(QuizQuestion q) => selectedAnswer(q)?.correct ?? false;

  int get total => questions.length;
  int get correct => questions.where(isCorrect).length;
  int get wrong => total - correct;
  int get percent => total == 0 ? 0 : ((correct * 100) / total).round();
}
