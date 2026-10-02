import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioFactory {
  final StorageService _storageService;
  final VoidCallback? onUnauthorized;

  DioFactory(this._storageService, {this.onUnauthorized});

  /// endpoints لا تحتاج توكن حسب الكولكشن (لا يُرسل معها Authorization،
  /// حتى لا يسبب توكن قديم رد 401 عليها).
  static const Set<String> _publicPaths = {
    ApiConstants.login,
    ApiConstants.resend,
    ApiConstants.active,
    ApiConstants.paymentMethodsAll,
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
        sendTimeout: const Duration(seconds: 60), // رفع الصور
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

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (object) {
            final message = object.toString().replaceAll(
              RegExp(r'Authorization:\s*Bearer\s*[^\r\n]+'),
              'Authorization: Bearer [REDACTED]',
            );
            debugPrint(message);
          },
        ),
      );
    }

    return dio;
  }
}
