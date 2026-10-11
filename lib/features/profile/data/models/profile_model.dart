/// رد profile/get. الحقول المتداخلة (school, branch, gender, know_about_app)
/// غير مقروءة حاليًا. TODO: تُضاف عند بناء شاشة الملف الشخصي.
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.image,
    this.points = 0,
    this.medals = 0,
    this.cups = 0,
    this.packageCount = 0,
    this.subjectCount = 0,
    this.semesterCount = 0,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? image;
  final int points;
  final int medals;
  final int cups;
  final int packageCount;
  final int subjectCount;
  final int semesterCount;

  String get fullName => '$firstName $lastName'.trim();

  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as int,
        firstName: json['f_name'] as String? ?? '',
        lastName: json['l_name'] as String? ?? '',
        phone: json['phone']?.toString() ?? '',
        email: json['email'] as String?,
        image: json['image'] as String?,
        points: _int(json['points']),
        medals: _int(json['medals']),
        cups: _int(json['cups']),
        packageCount: _int(json['package_count']),
        subjectCount: _int(json['subject_count']),
        semesterCount: _int(json['semester_count']),
      );
}
