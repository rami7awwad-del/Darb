import 'package:darb/features/home/data/models/course_model.dart';

/// درس داخل فصل (courses/details → semesters[].lessions[]).
class CourseLessonModel {
  const CourseLessonModel({
    required this.id,
    required this.name,
    this.order = 0,
    this.typeId = 0,
    this.typeName = '',
    this.time = '',
    this.file = '',
    this.isFree = false,
    this.isSubscription = false,
    this.isAttended = false,
  });

  final int id;
  final String name;
  final int order;
  final int typeId;

  /// اسم النوع كما يأتي من الخادم (مثل File).
  final String typeName;

  /// نص جاهز للعرض (مثل "3 ايام").
  final String time;
  final String file;
  final bool isFree;
  final bool isSubscription;
  final bool isAttended;

  bool get isFile => typeName.toLowerCase() == 'file';

  /// مقفل إن لم يكن مجانيًا والمستخدم غير مشترك.
  bool get isLocked => !isFree && !isSubscription;

  factory CourseLessonModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] is Map<String, dynamic>
        ? json['type'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return CourseLessonModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      typeId: (type['id'] as num?)?.toInt() ?? 0,
      typeName: type['name'] as String? ?? '',
      time: json['time']?.toString() ?? '',
      file: json['file'] as String? ?? '',
      isFree: json['is_free'] as bool? ?? false,
      isSubscription: json['is_subscription'] as bool? ?? false,
      isAttended: json['is_attended'] as bool? ?? false,
    );
  }
}

/// فصل داخل الدورة مع دروسه.
class CourseSemesterModel {
  const CourseSemesterModel({
    required this.id,
    required this.name,
    this.lessons = const [],
    this.lessonsCount = 0,
    this.lessonRate = 0,
    this.isFree = false,
    this.price = 0,
    this.isSubscription = false,
  });

  final int id;
  final String name;
  final List<CourseLessonModel> lessons;
  final int lessonsCount;
  final double lessonRate;
  final bool isFree;
  final num price;
  final bool isSubscription;

  factory CourseSemesterModel.fromJson(Map<String, dynamic> json) {
    final lessons = (json['lessions'] as List? ?? const [])
        .map((e) => CourseLessonModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return CourseSemesterModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      lessons: lessons,
      lessonsCount: (json['lessions_count'] as num?)?.toInt() ?? lessons.length,
      lessonRate: (json['lession_rate'] as num?)?.toDouble() ?? 0,
      isFree: json['is_free'] as bool? ?? false,
      price: json['price'] as num? ?? 0,
      isSubscription: json['is_subscription'] as bool? ?? false,
    );
  }
}

/// رد courses/details?subject_id= : بيانات الدورة + semesters[].
class CourseDetailsModel {
  const CourseDetailsModel({
    required this.course,
    this.description = '',
    this.semesters = const [],
  });

  final CourseModel course;

  /// حقل text في الرد (وصف الدورة).
  final String description;
  final List<CourseSemesterModel> semesters;

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) =>
      CourseDetailsModel(
        course: CourseModel.fromJson(json),
        description: json['text'] as String? ?? '',
        semesters: (json['semesters'] as List? ?? const [])
            .map((e) => CourseSemesterModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
