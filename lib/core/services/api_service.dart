import 'package:darb/core/errors/error_handler.dart';
import 'package:dio/dio.dart';

/// Thin wrapper around Dio for all API calls.
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  /// Runs a request and converts any failure into an app error.
  Future<Response> _send(Future<Response> Function() call) async {
    try {
      return await call();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Gets request.
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
    );
  }

  /// Posts request.
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
    );
  }

  /// Posts form data.
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
    );
  }

  /// Posts form data that can repeat the same key, as the backend expects.
  Future<Response> postFormFields(
    String endpoint,
    List<MapEntry<String, String>> fields, {
    CancelToken? cancelToken,
  }) async {
    final formData = FormData()..fields.addAll(fields);
    return _send(
      () => _dio.post(endpoint, data: formData, cancelToken: cancelToken),
    );
  }
}
