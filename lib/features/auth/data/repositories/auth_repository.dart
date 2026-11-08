import 'package:darb/core/services/storage_service.dart';
import 'package:darb/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/auth/data/models/auth_response_model.dart';

/// Repository that gives the cubits access to the auth data.
class AuthRepository {
  AuthRepository(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final StorageService _storage;

  Future<void> login(String phone) => _remote.login(phone);

  Future<void> resend(String phone) => _remote.resend(phone);

  Future<AuthResponseModel> activate(String phone, String code) async {
    final deviceId = await _storage.getOrCreateDeviceId();

    final result = await _remote.activate(
      phone: phone,
      code: code,
      deviceId: deviceId,
    );

    await _storage.saveToken(result.token);
    return result;
  }

  /// Ends the current session.
  Future<void> logout() async {
    try {
      await _remote.logout();
    } on RemoteExceptions {
    }
    await _storage.deleteToken();
  }
}
