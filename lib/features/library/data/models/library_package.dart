import 'package:darb/features/home/data/models/course_model.dart';

/// باقة من packages/all (قائمة) أو packages/details?id= (مع subjects).
/// ⚠️ لا يوجد في الرد حقل للمدة (7 أيام) ولا للوصف، فلم أضفهما.
class LibraryPackage {
  const LibraryPackage({
    required this.id,
    required this.name,
    required this.price,
    this.isSubscription = false,
    this.subjects = const [],
  });

  final int id;
  final String name;
  final num price;
  final bool isSubscription;
  final List<CourseModel> subjects;

  factory LibraryPackage.fromJson(Map<String, dynamic> json) => LibraryPackage(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        price: json['price'] as num? ?? 0,
        isSubscription: json['is_subscription'] as bool? ?? false,
        subjects: (json['subjects'] as List? ?? const [])
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
