import 'package:darb/features/home/data/models/course_model.dart';

/// Semester shown in the library.
class LibrarySemester {
  const LibrarySemester({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.professor,
    required this.points,
    required this.lessonsCount,
    required this.attendedCount,
    required this.lessonRate,
    required this.course,
    this.isFree = false,
    this.price = 0,
    this.isSubscription = false,
  });

  final int id;
  final String name;
  final String subjectName;
  final String professor;

  final int points;
  final int lessonsCount;

  final int attendedCount;

  final double lessonRate;

  final CourseModel course;
  final bool isFree;
  final num price;
  final bool isSubscription;

  /// Builds the object from the API json.
  factory LibrarySemester.fromJson(
    Map<String, dynamic> json,
    CourseModel course,
  ) {
    final lessons = json['lessions'] as List? ?? const [];
    final attended = lessons
        .where((e) => e is Map && e['is_attended'] == true)
        .length;
    return LibrarySemester(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      subjectName: course.name,
      professor: course.professor,
      points: course.pointsCount,
      lessonsCount: (json['lessions_count'] as num?)?.toInt() ?? lessons.length,
      attendedCount: attended,
      lessonRate: (json['lession_rate'] as num?)?.toDouble() ?? 0,
      course: course,
      isFree: json['is_free'] as bool? ?? false,
      price: json['price'] as num? ?? 0,
      isSubscription: json['is_subscription'] as bool? ?? false,
    );
  }
}
