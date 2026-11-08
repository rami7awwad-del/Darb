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

/// One answer option of a quiz question.
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

  final bool selected;

  /// Builds the object from the API json.
  factory QuizAnswer.fromJson(Map<String, dynamic> json) => QuizAnswer(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: stripHtml(json['title']),
        correct: json['correct'] as bool? ?? false,
        selected: json['current_answer'] == true || json['current_answer'] == 1,
      );
}

/// One question of a quiz.
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

  /// Builds the object from the API json.
  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: stripHtml(json['title']),
        answers: (json['answers'] as List? ?? const [])
            .map((e) => QuizAnswer.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Arguments passed to the quiz screen.
class QuizArgs {
  const QuizArgs({
    required this.title,
    required this.questions,
    required this.examId,
  });

  final int examId;
  final String title;
  final List<QuizQuestion> questions;
}

/// Result of the quiz.
class QuizOutcome {
  const QuizOutcome({
    required this.title,
    required this.questions,
    required this.selected,
  });

  final String title;
  final List<QuizQuestion> questions;

  final Map<int, int> selected;

  QuizAnswer? selectedAnswer(QuizQuestion q) {
    final id = selected[q.id];
    if (id == null) return null;
    for (final a in q.answers) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Creates the object from from details.
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

/// Quiz title, duration and questions.
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

  bool get attended =>
      questions.any((q) => q.answers.any((a) => a.selected));

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  /// Builds the object from the API json.
  factory QuizDetails.fromJson(Map<String, dynamic> json) {
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

/// Score returned after the quiz is submitted.
class QuizScore {
  const QuizScore({
    required this.questionsCount,
    required this.correctAnswers,
    required this.failedAnswers,
  });

  final int questionsCount;
  final int correctAnswers;
  final int failedAnswers;

  /// Builds the object from the API json.
  factory QuizScore.fromJson(Map<String, dynamic> json) => QuizScore(
        questionsCount: (json['questions_count'] as num?)?.toInt() ?? 0,
        correctAnswers: (json['correct_answers'] as num?)?.toInt() ?? 0,
        failedAnswers: (json['failed_answers'] as num?)?.toInt() ?? 0,
      );
}

/// Item widget for the quiz list.
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

  /// Builds the object from the API json.
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
