import 'package:darb/core/errors/error_handler.dart';
import 'package:darb/core/services/dio_factory.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio;

  ApiService(StorageService storageService)
      : _dio = DioFactory(storageService).getDio();

  /// GET
  Future<Response> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      debugPrint('GET Exception [$endpoint]: ${e.message}');
      throw ErrorHandler.handle(e);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// POST (JSON)
  Future<Response> postRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      debugPrint('POST Exception [$endpoint]: ${e.message}');
      throw ErrorHandler.handle(e);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// PUT (JSON)
  Future<Response> putRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      debugPrint('PUT Exception [$endpoint]: ${e.message}');
      throw ErrorHandler.handle(e);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// DELETE
  Future<Response> deleteRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      debugPrint('DELETE Exception [$endpoint]: ${e.message}');
      throw ErrorHandler.handle(e);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// POST (FormData)
  Future<Response> postFormData(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final formData = FormData.fromMap(body);

      return await _dio.post(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      debugPrint('POST FormData Exception [$endpoint]: ${e.message}');
      throw ErrorHandler.handle(e);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}