import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

/// Stores the login token on the device.
class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );

  static const String _tokenKey = 'auth_token';
  static const String _deviceIdKey = 'device_id';

  String? _cachedToken;
  String? _cachedDeviceId;

  Future<void> init() async {
    _cachedToken = await _read(_tokenKey);
    _cachedDeviceId = await _read(_deviceIdKey);
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (error) {
      final message = '${error.code} ${error.message} ${error.details}'
          .toLowerCase();
      if (!message.contains('wrong_final_block_length') &&
          !message.contains('illegalblocksizeexception')) {
        rethrow;
      }

      _cachedToken = null;
      _cachedDeviceId = null;
      try {
        await _storage.deleteAll();
      } on PlatformException {
      }
      return null;
    }
  }

  String? get token => _cachedToken;

  bool get hasToken => _cachedToken?.isNotEmpty ?? false;

  /// Saves token.
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Gets token.
  Future<String?> getToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }

    _cachedToken = await _read(_tokenKey);
    return _cachedToken;
  }

  /// Deletes token.
  Future<void> deleteToken() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  /// Gets device id.
  Future<String?> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId;
    }

    _cachedDeviceId = await _read(_deviceIdKey);
    return _cachedDeviceId;
  }

  /// Saves device id.
  Future<void> saveDeviceId(String deviceId) async {
    _cachedDeviceId = deviceId;
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }

  /// Gets or create device id.
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
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
