import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/subjects/data/models/subject_details_model.dart';
import 'package:dio/dio.dart';

/// Remote data source that calls the subjects endpoints.
class SubjectsRemoteDataSource {
  SubjectsRemoteDataSource(this._api);

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

  Future<List<SubjectModel>> getAll() async {
    final response = await _api.getRequest(ApiConstants.subjectsAll);
    return _parse(
      response,
      (d) => (d as List)
          .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Gets details.
  Future<SubjectDetailsModel> getDetails(int id) async {
    final response = await _api.getRequest(
      ApiConstants.subjectsDetails,
      queryParameters: {'id': id},
    );
    return _parse(
      response,
      (d) => SubjectDetailsModel.fromJson(d as Map<String, dynamic>),
    );
  }
}
