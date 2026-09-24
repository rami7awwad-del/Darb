import 'dart:io';

import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:dio/dio.dart';

class ErrorHandler {
  const ErrorHandler._();

  static RemoteExceptions handle(Object error) {
    if (error is RemoteExceptions) {
      final message = error.response == null
          ? error.errorCode.getLocalizedMessage()
          : _extractServerMessage(error.response!) ??
                error.errorCode.getLocalizedMessage();
      return RemoteExceptions(
        error.errorCode,
        message,
        response: error.response,
      );
    }
    if (error is DioException) {
      return handleDioError(error);
    }
    final errorCode = error is FormatException || error is TypeError
        ? ErrorCode.APP_ERROR
        : ErrorCode.UNKNOWN;
    return RemoteExceptions(errorCode, errorCode.getLocalizedMessage());
  }

  static RemoteExceptions handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return RemoteExceptions(
          ErrorCode.TIMEOUT,
          ErrorCode.TIMEOUT.getLocalizedMessage(),
        );

      case DioExceptionType.badResponse:
        if (error.response != null) {
          return fromResponse(error.response!);
        }
        return RemoteExceptions(
          ErrorCode.SERVER_ERROR,
          ErrorCode.SERVER_ERROR.getLocalizedMessage(),
        );

      case DioExceptionType.cancel:
        return RemoteExceptions(
          ErrorCode.CANCEL,
          ErrorCode.CANCEL.getLocalizedMessage(),
        );

      case DioExceptionType.connectionError:
        return RemoteExceptions(
          ErrorCode.NO_INTERNET_CONNECTION,
          ErrorCode.NO_INTERNET_CONNECTION.getLocalizedMessage(),
        );

      case DioExceptionType.badCertificate:
        return RemoteExceptions(
          ErrorCode.BAD_CERTIFICATE,
          ErrorCode.BAD_CERTIFICATE.getLocalizedMessage(),
        );

      case DioExceptionType.unknown:
        final errorCode = error.error is SocketException
            ? ErrorCode.NO_INTERNET_CONNECTION
            : ErrorCode.UNKNOWN;
        return RemoteExceptions(errorCode, errorCode.getLocalizedMessage());
    }
  }

  static RemoteExceptions fromResponse(Response response) {
    final statusCode = response.statusCode ?? 500;
    final errorCode = _mapStatusCode(statusCode);
    final message =
        _extractServerMessage(response) ?? errorCode.getLocalizedMessage();
    return RemoteExceptions(errorCode, message, response: response);
  }

  static ErrorCode _mapStatusCode(int statusCode) {
    return switch (statusCode) {
      400 => ErrorCode.BAD_REQUEST,
      401 => ErrorCode.UNAUTHENTICATED,
      403 => ErrorCode.FORBIDDEN,
      404 => ErrorCode.NOT_FOUND,
      408 => ErrorCode.TIMEOUT,
      // TODO: unverified assumptions, confirm real status codes against the backend
      409 => ErrorCode.PENDING_APPROVAL,
      422 => ErrorCode.UNPROCESSABLE_ENTITY,
      // TODO: unverified assumptions, confirm real status codes against the backend
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
