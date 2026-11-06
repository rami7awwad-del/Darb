import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/support/data/models/contact_info_model.dart';
import 'package:darb/features/support/data/models/faq_model.dart';
import 'package:dio/dio.dart';

/// Remote data source that calls the support endpoints.
class SupportRemoteDataSource {
  SupportRemoteDataSource(this._api);

  final ApiService _api;

  RemoteExceptions _appError(Response response) => RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );

  T _parse<T>(Response response, T Function(dynamic data) convert) {
    try {
      final body = response.data as Map<String, dynamic>;
      return convert(body['data']);
    } catch (_) {
      throw _appError(response);
    }
  }

  Future<List<FaqModel>> getFaqs() async {
    final response = await _api.getRequest(ApiConstants.faqsAll);
    return _parse(
      response,
      (d) => (d as List)
          .map((e) => FaqModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Gets page value.
  Future<String> getPageValue(String endpoint) async {
    final response = await _api.getRequest(endpoint);
    return _parse(response, (d) => (d as Map<String, dynamic>)['value'] as String);
  }

  /// Gets infos.
  Future<ContactInfoModel> getInfos() async {
    final response = await _api.getRequest(ApiConstants.infosAll);
    return _parse(
      response,
      (d) => ContactInfoModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Adds contact us.
  Future<void> addContactUs({
    required String firstName,
    required String lastName,
    required String phone,
    required String text,
  }) async {
    await _api.postFormData(ApiConstants.contactUsAdd, {
      'f_name': firstName,
      'l_name': lastName,
      'phone': phone,
      'text': text,
    });
  }
}
