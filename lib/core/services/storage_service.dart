

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    // TODO: upgrade the flutter_secure_storage version if the app needs
    // AndroidOptions(encryptedSharedPreferences: true) support.
    aOptions: AndroidOptions(),
  );

  static const String _tokenKey = 'auth_token';
  static const String _deviceIdKey = 'device_id';

  String? _cachedToken;

  Future<void> init() async {
    _cachedToken = await _storage.read(key: _tokenKey);
  }

  String? get token => _cachedToken;

  bool get hasToken => _cachedToken?.isNotEmpty ?? false;

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }

    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  Future<void> deleteToken() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getDeviceId() async {
    return _storage.read(key: _deviceIdKey);
  }

  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }
}