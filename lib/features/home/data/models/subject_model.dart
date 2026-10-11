class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.name,
    required this.image,
    this.isFree = false,
    this.isSubscription = false,
  });

  final int id;
  final String name;
  final String image;
  final bool isFree;
  final bool isSubscription;

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        image: json['image'] as String? ?? '',
        isFree: json['is_free'] as bool? ?? false,
        isSubscription: json['is_subscription'] as bool? ?? false,
      );
}
