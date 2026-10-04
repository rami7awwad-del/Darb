import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/auth/data/models/branch_model.dart';
import 'package:darb/features/auth/data/models/school_model.dart';
import 'package:darb/features/auth/data/models/terms_model.dart';
import 'package:dio/dio.dart';

/// طلبات إكمال البيانات: القوائم، الشروط، وتعديل المستخدم.
class RegistrationRemoteDataSource {
  RegistrationRemoteDataSource(this._api);

  final ApiService _api;

  RemoteExceptions _appError(Response response) => RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );

  List<T> _parseList<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as List;
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      throw _appError(response);
    }
  }

  /// GET schools/all (يعمل بدون معاملات، جُرّب في Postman).
  Future<List<SchoolModel>> getSchools() async {
    final response = await _api.getRequest(ApiConstants.schoolsAll);
    return _parseList(response, SchoolModel.fromJson);
  }

  /// GET branches/all
  Future<List<BranchModel>> getBranches() async {
    final response = await _api.getRequest(ApiConstants.branchesAll);
    return _parseList(response, BranchModel.fromJson);
  }

  /// GET pages/terms-conditions → data.value نص HTML.
  Future<TermsModel> getTerms() async {
    final response = await _api.getRequest(ApiConstants.pagesTermsConditions);
    try {
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return TermsModel.fromHtml(data['value'] as String);
    } catch (_) {
      throw _appError(response);
    }
  }

  /// POST users/edit (form-data). الجنس: 0 أنثى، 1 ذكر.
  Future<void> completeProfile({
    required String firstName,
    required String lastName,
    required String email,
    required int schoolId,
    required int knowAboutApp,
    required int gender,
    required int age,
    required int branchId,
  }) async {
    await _api.postFormData(ApiConstants.usersEdit, {
      'f_name': firstName,
      'l_name': lastName,
      'email': email,
      'school_id': schoolId,
      'know_about_app': knowAboutApp,
      'gender': gender,
      'age': age,
      'branch_id': branchId,
    });
  }
}
