import 'package:darb/features/home/data/models/subject_model.dart';

/// Model that holds the package data parsed from the API.
class PackageModel {
  const PackageModel({
    required this.id,
    required this.name,
    required this.price,
    this.subjects = const [],
    this.isSubscription = false,
  });

  final int id;
  final String name;
  final num price;
  final List<SubjectModel> subjects;
  final bool isSubscription;

  /// Builds the object from the API json.
  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: (json['name'] ?? '').toString(),
        price: json['price'] as num? ?? 0,
        subjects: ((json['subjects'] as List?) ?? const [])
            .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        isSubscription: json['is_subscription'] as bool? ?? false,
      );
}
