/// بيانات المستخدم كما تأتي في رد auth/active (الحقول التي تحققنا منها فقط).
/// TODO: gender و know_about_app و points ... تُضاف عند الحاجة لها.
class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.age,
    this.image,
  });

  final int id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final int? age;
  final String? image;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        phone: json['phone']?.toString() ?? '',
        firstName: json['f_name'] as String?,
        lastName: json['l_name'] as String?,
        email: json['email'] as String?,
        age: json['age'] as int?,
        image: json['image'] as String?,
      );
}
