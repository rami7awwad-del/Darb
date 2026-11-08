/// Model that holds the comment data parsed from the API.
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

  String get dateLabel => createdAt.split(' ').first.replaceAll('-', '/');

  /// Builds the object from the API json.
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
