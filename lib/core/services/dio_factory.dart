import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Builds the Dio client with the auth interceptor.
class DioFactory {
  final StorageService _storageService;
  final VoidCallback? onUnauthorized;

  DioFactory(this._storageService, {this.onUnauthorized});

  // Endpoints that must be called without the Authorization header.
  static const Set<String> _publicPaths = {
    ApiConstants.login,
    ApiConstants.resend,
    ApiConstants.active,
    ApiConstants.settingsAll,
    ApiConstants.infosAll,
    ApiConstants.contactUsAdd,
    ApiConstants.pagesAll,
    ApiConstants.pagesPrivacyPolicy,
    ApiConstants.pagesTermsConditions,
    ApiConstants.pagesAboutApplication,
  };

  Dio getDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 60),
        listFormat: ListFormat.multiCompatible,
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'ar',
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.token ?? '';
          final isPublic = _publicPaths.contains(options.path);

          // Attach the token only to protected endpoints.
          if (token.isNotEmpty && !isPublic) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final requestPath = error.requestOptions.path;
          final isAuthEndpoint =
              requestPath == ApiConstants.login ||
              requestPath == ApiConstants.active;

          // Clear the token and go to login when the session has expired.
          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            if (_storageService.hasToken) {
              await _storageService.deleteToken();
              onUnauthorized?.call();
            }
          }

          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
