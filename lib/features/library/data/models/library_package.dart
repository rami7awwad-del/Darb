import 'package:darb/features/home/data/models/course_model.dart';

/// Package shown in the library.
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

  final int? durationDays;
  final String? description;

  /// Builds the object from the API json.
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
