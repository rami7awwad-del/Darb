import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/subscription/data/models/package_model.dart';
import 'package:darb/features/subscription/data/models/payment_method_model.dart';
import 'package:darb/features/subscription/data/models/subscribed_courses.dart';
import 'package:dio/dio.dart';

class SubscriptionRemoteDataSource {
  SubscriptionRemoteDataSource(this._api);

  final ApiService _api;

  T _parse<T>(Response response, T Function(dynamic data) convert) {
    try {
      final body = response.data as Map<String, dynamic>;
      return convert(body['data']);
    } catch (_) {
      throw RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );
    }
  }

  /// GET subscriptions/my → دورات المستخدم المشترك بها.
  Future<List<CourseModel>> getMyCourses() async {
    final response = await _api.getRequest(ApiConstants.subscriptionsMy);
    return _parse(response, parseSubscribedCourses);
  }

  /// GET payment-methods/all → وسائل الدفع ومعلومات الوكلاء.
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _api.getRequest(ApiConstants.paymentMethodsAll);
    return _parse(
      response,
      (d) => (d is List ? d : const [])
          .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// GET packages/all → الباقات المتاحة مع موادها.
  Future<List<PackageModel>> getPackages() async {
    final response = await _api.getRequest(ApiConstants.packagesAll);
    return _parse(
      response,
      (d) => (d is List ? d : const [])
          .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// POST subscriptions/add (form-data: code) → الاشتراك بكود.
  /// ⚠️ المسار في Postman هو subscriptions/add وليس addcode.
  Future<void> subscribeWithCode(String code) async {
    await _api.postFormData(ApiConstants.subscriptionsAdd, {'code': code});
  }
}
