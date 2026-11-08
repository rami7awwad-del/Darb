/// Model that holds the course data parsed from the API.
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
    this.semesterRate = 0,
    this.lessonRate = 0,
    this.subjectRate = 0,
    this.pointsCount = 0,
    this.pointRate = 0,
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

  final double semesterRate;
  final double lessonRate;
  final double subjectRate;
  final int pointsCount;

  final double pointRate;

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
  static double _double(dynamic v) => (v as num?)?.toDouble() ?? 0;

  /// Builds the object from the API json.
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
        semesterRate: _double(json['semester_rate']),
        lessonRate: _double(json['lession_rate']),
        subjectRate: _double(json['subject_rate']),
        pointsCount: _int(json['points_count']),
        pointRate: _double(json['point_rate']),
      );
}
