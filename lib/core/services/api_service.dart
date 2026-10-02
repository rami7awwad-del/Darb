import 'package:darb/core/errors/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<Response> _send(
    Future<Response> Function() call,
    String tag,
  ) async {
    try {
      return await call();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$tag] Exception: $e');
      }
      throw ErrorHandler.handle(e);
    }
  }

  /// طلبات GET (تمرير المعاملات عبر [queryParameters] مثل page و perPage).
  Future<Response> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    return _send(
      () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      ),
      'GET',
    );
  }

  /// ⚠️ يرسل الـ body بصيغة JSON.
  /// كل طلبات POST في الـ API الحالي (حسب الكولكشن) تعتمد form-data،
  /// لذلك استخدم [postFormData] لها. هذه الدالة للاستخدام فقط
  /// إن احتاج endpoint مستقبلي إلى JSON.
  Future<Response> postRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    return _send(
      () => _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      'POST',
    );
  }

  /// طلبات POST بصيغة form-data (الأساسية في هذا الـ API).
  /// - القوائم تُرسل بمفتاح بدون أقواس: {'answers_id': [1, 2, 3]}
  ///   وتتحول تلقائيًا إلى answers_id[] بفضل ListFormat.multiCompatible.
  /// - الملفات (مثل الصورة) تُمرَّر كـ MultipartFile:
  ///   {'image': await MultipartFile.fromFile(path)}
  Future<Response> postFormData(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap(body, ListFormat.multiCompatible);

    return _send(
      () => _dio.post(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      'POST FormData',
    );
  }
}
