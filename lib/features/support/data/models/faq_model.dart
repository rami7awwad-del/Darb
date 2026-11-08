/// Model that holds the faq data parsed from the API.
class FaqModel {
  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  final int id;
  final String question;
  final String answer;

  /// Builds the object from the API json.
  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
        id: json['id'] as int,
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
      );
}
