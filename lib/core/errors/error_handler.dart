import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:dio/dio.dart';

class ErrorHandler {
  const ErrorHandler._();

  static RemoteExceptions handle(Object error) {
    if (error is RemoteExceptions) {
      return error;
    }
    if (error is DioException) {
      return handleDioError(error);
    }
    return const RemoteExceptions(
      ErrorCode.UNKNOWN,
      'An unexpected error occurred',
    );
  }

  static RemoteExceptions handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const RemoteExceptions(ErrorCode.TIMEOUT, 'Connection timeout');

      case DioExceptionType.badResponse:
        if (error.response != null) {
          return fromResponse(error.response!);
        }
        return const RemoteExceptions(
          ErrorCode.SERVER_ERROR,
          'Server response error',
        );

      case DioExceptionType.cancel:
        return const RemoteExceptions(ErrorCode.CANCEL, 'Request cancelled');

      case DioExceptionType.connectionError:
        return const RemoteExceptions(
          ErrorCode.NO_INTERNET_CONNECTION,
          'No internet connection',
        );

      case DioExceptionType.badCertificate:
        return const RemoteExceptions(
          ErrorCode.BAD_CERTIFICATE,
          'Bad certificate',
        );

      case DioExceptionType.unknown:
      default:
        return const RemoteExceptions(
          ErrorCode.UNKNOWN,
          'An unknown error occurred',
        );
    }
  }

  static RemoteExceptions fromResponse(Response response) {
    final statusCode = response.statusCode ?? 500;
    final errorCode = _mapStatusCode(statusCode);
    final message = _extractServerMessage(response) ?? 'An error occurred';
    return RemoteExceptions(errorCode, message, response: response);
  }

  static ErrorCode _mapStatusCode(int statusCode) {
    return switch (statusCode) {
      400 => ErrorCode.BAD_REQUEST,
      401 => ErrorCode.UNAUTHENTICATED,
      403 => ErrorCode.FORBIDDEN,
      404 => ErrorCode.NOT_FOUND,
      408 => ErrorCode.TIMEOUT,
      409 => ErrorCode.PENDING_APPROVAL,
      422 => ErrorCode.UNPROCESSABLE_ENTITY,
      426 => ErrorCode.NOT_EXIST_ACCOUNT,
      500 || 501 || 502 || 503 || 504 => ErrorCode.SERVER_ERROR,
      _ => ErrorCode.UNKNOWN,
    };
  }

  static String? _extractServerMessage(Response response) {
    final data = response.data;

    if (data is! Map) {
      return null;
    }

    // { "message": "..." }
    if (data['message'] is String) {
      return data['message'] as String;
    }

    // { "error": { "message": "..." } }
    if (data['error'] is Map && data['error']['message'] is String) {
      return data['error']['message'] as String;
    }

    // Laravel Validation Errors: { "errors": { "field": ["error message"] } }
    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;
      if (errors.isNotEmpty && errors.values.first is List) {
        final firstList = errors.values.first as List;
        if (firstList.isNotEmpty) {
          return firstList.first.toString();
        }
      }
    }

    return null;
  }
}