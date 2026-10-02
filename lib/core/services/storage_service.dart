import 'dart:math';

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
  String? _cachedDeviceId;

  /// يُستدعى مرة واحدة في main() قبل إنشاء Dio.
  Future<void> init() async {
    _cachedToken = await _storage.read(key: _tokenKey);
    _cachedDeviceId = await _storage.read(key: _deviceIdKey);
  }

  // ==================== Token ====================

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

  // ==================== Device ID ====================

  Future<String?> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId;
    }

    _cachedDeviceId = await _storage.read(key: _deviceIdKey);
    return _cachedDeviceId;
  }

  Future<void> saveDeviceId(String deviceId) async {
    _cachedDeviceId = deviceId;
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }

  /// يعيد معرّف الجهاز المخزَّن، وإن لم يوجد يولّد واحدًا جديدًا (UUID v4)
  /// ويحفظه. المعرّف ثابت طالما بقي التطبيق مثبتًا.
  /// يُستخدم مع auth/active (حقل device_id).
  Future<String> getOrCreateDeviceId() async {
    final existing = await getDeviceId();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final newId = _generateUuidV4();
    await saveDeviceId(newId);
    return newId;
  }

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    final hex =
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
