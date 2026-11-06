import 'package:darb/features/home/data/models/course_model.dart';

/// باقة من packages/all (قائمة) أو packages/details?id= (مع subjects).
/// المدة والوصف يُقرآن بتسامح (duration/days و description) ويكونان null إن غابا.
class LibraryPackage {
  const LibraryPackage({
    required this.id,
    required this.name,
    required this.price,
    this.isSubscription = false,
    this.subjects = const [],
    this.durationDays,
    this.description,
  });

  final int id;
  final String name;
  final num price;
  final bool isSubscription;
  final List<CourseModel> subjects;

  /// مدة الباقة بالأيام (duration أو days).
  final int? durationDays;
  final String? description;

  factory LibraryPackage.fromJson(Map<String, dynamic> json) => LibraryPackage(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        price: json['price'] as num? ?? 0,
        isSubscription: json['is_subscription'] as bool? ?? false,
        durationDays:
            int.tryParse('${json['duration'] ?? json['days'] ?? ''}'),
        description: (json['description'] as String?)?.trim(),
        subjects: (json['subjects'] as List? ?? const [])
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
