/// تعليق على درس (comments/get-by-lession).
/// ⚠️ رد القائمة لم يُرَ بعد (data كانت فارغة). رد الإضافة يحمل id و comment
/// و created_at فقط. اسم الكاتب وصورته مقروءان بشكل متسامح من أكثر من شكل
/// محتمل (user.name / user_name / name)؛ إن اختلفت الأسماء عدّل fromJson فقط.
class CommentModel {
  const CommentModel({
    required this.id,
    required this.text,
    this.createdAt = '',
    this.userName = '',
    this.userImage = '',
  });

  final int id;
  final String text;
  final String createdAt;
  final String userName;
  final String userImage;

  /// التاريخ بدون الوقت وبصيغة 2026/10/31.
  String get dateLabel => createdAt.split(' ').first.replaceAll('-', '/');

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return CommentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      text: (json['comment'] ?? json['text'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      userName:
          (user['name'] ?? json['user_name'] ?? json['name'] ?? '').toString(),
      userImage: (user['image'] ?? json['user_image'] ?? json['image'] ?? '')
          .toString(),
    );
  }
}
