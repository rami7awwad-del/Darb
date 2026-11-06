import 'package:darb/core/errors/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<Response> _send(Future<Response> Function() call, String tag) async {
    try {
      return await call();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$tag] Exception: $e');
      }
      throw ErrorHandler.handle(e);
    }
  }

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

  /// POST form-data بمفاتيح مكررة (مثل `answers_id[]`) كما يتوقعها Laravel.
  /// Map لا تسمح بتكرار المفتاح، لذلك تُمرَّر الحقول كقائمة MapEntry.
  Future<Response> postFormFields(
    String endpoint,
    List<MapEntry<String, String>> fields, {
    CancelToken? cancelToken,
  }) async {
    final formData = FormData()..fields.addAll(fields);
    return _send(
      () => _dio.post(endpoint, data: formData, cancelToken: cancelToken),
      'POST FormFields',
    );
  }
}
