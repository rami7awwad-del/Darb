
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/storage_service.dart';
import 'package:dio/dio.dart';

class DioFactory {
  final StorageService _storageService;

  DioFactory(this._storageService);

  Dio getDio() {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'ar', // متوافق مع خريطة الرسائل العربية لديك[cite: 5]
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    return dio;
  }
}