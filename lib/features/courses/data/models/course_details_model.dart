import 'package:darb/features/home/data/models/course_model.dart';

/// Reads lesson file.
String readLessonFile(Map<String, dynamic> json) {
  String? pick(dynamic v) {
    if (v is String && v.trim().isNotEmpty) return v.trim();
    if (v is Map) {
      for (final k in const ['url', 'path', 'link', 'file']) {
        final r = pick(v[k]);
        if (r != null) return r;
      }
    }
    return null;
  }

  for (final k in const ['file', 'video', 'video_url', 'url', 'link']) {
    final r = pick(json[k]);
    if (r != null) return r;
  }
  return '';
}

/// Model that holds the course lesson data parsed from the API.
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

  final String typeName;

  final String time;
  final String file;
  final bool isFree;
  final bool isSubscription;
  final bool isAttended;

  bool get isFile => typeName.toLowerCase() == 'file';

  bool get isExam => typeId == 3 || typeName.toLowerCase() == 'exam';

  bool get isLocked => !isFree && !isSubscription;

  /// Builds the object from the API json.
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
      file: readLessonFile(json),
      isFree: json['is_free'] as bool? ?? false,
      isSubscription: json['is_subscription'] as bool? ?? false,
      isAttended: json['is_attended'] as bool? ?? false,
    );
  }
}

/// Model that holds the course semester data parsed from the API.
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

  /// Builds the object from the API json.
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

/// Model that holds the course details data parsed from the API.
class CourseDetailsModel {
  const CourseDetailsModel({
    required this.course,
    this.description = '',
    this.semesters = const [],
    this.pointsCount = 0,
    this.storyImage,
    this.storyText,
    this.isFirstStory = false,
  });

  final CourseModel course;

  final String description;
  final List<CourseSemesterModel> semesters;

  final int pointsCount;

  final String? storyImage;
  final String? storyText;

  final bool isFirstStory;

  bool get hasStory =>
      isFirstStory &&
      ((storyText?.trim().isNotEmpty ?? false) ||
          (storyImage?.isNotEmpty ?? false));

  /// Builds the object from the API json.
  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) =>
      CourseDetailsModel(
        course: CourseModel.fromJson(json),
        description: json['text'] as String? ?? '',
        semesters: (json['semesters'] as List? ?? const [])
            .map((e) => CourseSemesterModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        pointsCount: (json['points_count'] as num?)?.toInt() ?? 0,
        storyImage: json['story_image'] as String?,
        storyText: json['story_text'] as String?,
        isFirstStory: json['is_first_story'] == true || json['is_first_story'] == 1,
      );
}
