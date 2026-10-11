/// عنصر من courses في home-page/index.
/// ملاحظة: اسم الحقل في الـ API lessions_count (بهذا الإملاء).
class CourseModel {
  const CourseModel({
    required this.id,
    required this.name,
    required this.courseName,
    required this.professor,
    required this.image,
    this.price = 0,
    this.isFree = false,
    this.semestersCount = 0,
    this.lessonsCount = 0,
    this.subscriptionsCount = 0,
    this.isSubscription = false,
  });

  final int id;
  final String name;
  final String courseName;
  final String professor;
  final String image;
  final num price;
  final bool isFree;
  final int semestersCount;
  final int lessonsCount;
  final int subscriptionsCount;
  final bool isSubscription;

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        courseName: json['course_name'] as String? ?? '',
        professor: json['professor'] as String? ?? '',
        image: json['image'] as String? ?? '',
        price: json['price'] as num? ?? 0,
        isFree: json['is_free'] as bool? ?? false,
        semestersCount: _int(json['semesters_count']),
        lessonsCount: _int(json['lessions_count']),
        subscriptionsCount: _int(json['subscriptions_count']),
        isSubscription: json['is_subscription'] as bool? ?? false,
      );
}
