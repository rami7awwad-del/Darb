import 'package:darb/features/auth/data/models/user_model.dart';

/// رد auth/active الناجح: { message, data: { token, user: {...} } }
class AuthResponseModel {
  const AuthResponseModel({required this.token, required this.user});

  final String token;
  final UserModel user;

  /// مستخدم جديد لم يُكمل بياناته (في التجربة: f_name = null).
  /// TODO: تحقق من رد مستخدم مكتمل البيانات للتأكد أن هذا هو المعيار الصحيح.
  bool get needsProfileCompletion =>
      user.firstName == null || user.firstName!.trim().isEmpty;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        token: json['token'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
