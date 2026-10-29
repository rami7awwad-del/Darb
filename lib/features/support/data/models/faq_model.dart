/// عنصر من faqs/all. الرد لا يحمل تصنيفًا (category)، فتُعرض كقائمة واحدة.
class FaqModel {
  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  final int id;
  final String question;
  final String answer;

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
        id: json['id'] as int,
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
      );
}
