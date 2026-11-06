import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:dio/dio.dart';

/// Remote data source that calls the profile endpoints.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._api);

  final ApiService _api;

  ProfileModel _parse(Response response) {
    try {
      final body = response.data as Map<String, dynamic>;
      return ProfileModel.fromJson(body['data'] as Map<String, dynamic>);
    } catch (_) {
      throw RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );
    }
  }

  /// Gets profile.
  Future<ProfileModel> getProfile() async {
    final response = await _api.getRequest(ApiConstants.profile);
    return _parse(response);
  }

  /// Updates profile.
  Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required int schoolId,
    int? gender,
  }) async {
    final response = await _api.postFormData(ApiConstants.userUpdate, {
      'f_name': firstName,
      'l_name': lastName,
      'school_id': schoolId,
      'gender': gender,
    });
    return _parse(response);
  }
}
