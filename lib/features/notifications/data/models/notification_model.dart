/// Model that holds the notification data parsed from the API.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.text,
    this.createdAt,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String text;
  final DateTime? createdAt;
  final bool isRead;

  static const List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String get formattedDate {
    final d = createdAt;
    if (d == null) return '';
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'صباحًا' : 'مساءً';
    return '${d.day} ${_months[d.month - 1]} ${d.year} / $hour12:$minute $period';
  }

  /// Reads flag.
  static bool _readFlag(dynamic value) =>
      value == 1 || value == true || value == '1';

  /// Builds the object from the API json.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'];
    final created = json['created_at']?.toString();
    return NotificationModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: created == null
          ? null
          : DateTime.tryParse(created.replaceFirst(' ', 'T')),
      isRead: pivot is Map ? _readFlag(pivot['is_read']) : false,
    );
  }
}
