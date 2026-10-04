import 'package:darb/core/services/firebase_notification_service.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:darb/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:darb/features/auth/data/models/auth_response_model.dart';


/// الجلسة: دخول، تفعيل، (لاحقًا: خروج، حذف الحساب).
class AuthRepository {
  AuthRepository(this._remote, this._storage, this._notifications);

  final AuthRemoteDataSource _remote;
  final StorageService _storage;
  final FirebaseNotificationService _notifications;

  Future<void> login(String phone) => _remote.login(phone);

  Future<void> resend(String phone) => _remote.resend(phone);

  /// يجلب device_id و fcm_token، يفعّل الحساب، ثم يحفظ التوكن.
  Future<AuthResponseModel> activate(String phone, String code) async {
    final deviceId = await _storage.getOrCreateDeviceId();

    // فشل الحصول على FCM لا يجب أن يمنع الدخول.
    String? fcmToken;
    try {
      fcmToken = await _notifications.getFcmToken();
    } catch (_) {}

    final result = await _remote.activate(
      phone: phone,
      code: code,
      deviceId: deviceId,
      fcmToken: fcmToken,
    );

    await _storage.saveToken(result.token);
    return result;
  }
}
