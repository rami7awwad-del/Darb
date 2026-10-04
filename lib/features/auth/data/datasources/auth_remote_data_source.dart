import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/auth/data/models/auth_response_model.dart';


/// طلبات API فقط، بدون تخزين ولا منطق.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiService _api;

  /// POST auth/login → يرسل رمز التفعيل عبر واتساب.
  Future<void> login(String phone) async {
    await _api.postFormData(ApiConstants.login, {'phone': phone});
  }

  /// POST auth/resend → إعادة إرسال الرمز.
  Future<void> resend(String phone) async {
    await _api.postFormData(ApiConstants.resend, {'phone': phone});
  }

  /// POST auth/active → يعيد التوكن وبيانات المستخدم.
  Future<AuthResponseModel> activate({
    required String phone,
    required String code,
    required String deviceId,
    String? fcmToken,
  }) async {
    final response = await _api.postFormData(ApiConstants.active, {
      'phone': phone,
      'verification_code': code,
      'device_id': deviceId,
      if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
    });

    try {
      final body = response.data as Map<String, dynamic>;
      return AuthResponseModel.fromJson(body['data'] as Map<String, dynamic>);
    } catch (_) {
      // أي رد غير متوقع
      throw RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );
    }
  }
}
