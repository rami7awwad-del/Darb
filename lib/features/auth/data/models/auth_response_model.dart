import 'package:darb/features/auth/data/models/user_model.dart';

/// Model that holds the auth response data parsed from the API.
class AuthResponseModel {
  const AuthResponseModel({required this.token, required this.user});

  final String token;
  final UserModel user;

  bool get needsProfileCompletion =>
      user.firstName == null || user.firstName!.trim().isEmpty;

  /// Builds the object from the API json.
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        token: json['token'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
