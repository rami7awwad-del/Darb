import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/auth/data/models/auth_response_model.dart';

/// Remote data source that calls the auth endpoints.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiService _api;

  /// Starts the login request.
  Future<void> login(String phone) async {
    await _api.postFormData(ApiConstants.login, {'phone': phone});
  }

  /// Requests a new code.
  Future<void> resend(String phone) async {
    await _api.postFormData(ApiConstants.resend, {'phone': phone});
  }

  /// Ends the current session.
  Future<void> logout() async {
    await _api.getRequest(ApiConstants.logout);
  }

  Future<AuthResponseModel> activate({
    required String phone,
    required String code,
    required String deviceId,
  }) async {
    final response = await _api.postFormData(ApiConstants.active, {
      'phone': phone,
      'verification_code': code,
      'device_id': deviceId,
    });

    try {
      final body = response.data as Map<String, dynamic>;
      return AuthResponseModel.fromJson(body['data'] as Map<String, dynamic>);
    } catch (_) {
      throw RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );
    }
  }
}
