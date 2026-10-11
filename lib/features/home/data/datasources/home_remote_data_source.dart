import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/home/data/models/home_data_model.dart';
import 'package:darb/features/home/data/models/news_model.dart';
import 'package:darb/features/home/data/models/search_result_model.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:dio/dio.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._api);

  final ApiService _api;

  /// يقرأ حقل data من الرد، وأي شكل غير متوقع يتحول إلى APP_ERROR.
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

  /// GET home-page/index?perPage=10
  Future<HomeDataModel> getHome({int perPage = 10}) async {
    final response = await _api.getRequest(
      ApiConstants.homePageIndex,
      queryParameters: {'perPage': perPage},
    );
    return _parse(
      response,
      (d) => HomeDataModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// GET home-page/search?perPage=10&text=...
  Future<SearchResultModel> search(String text, {int perPage = 10}) async {
    final response = await _api.getRequest(
      ApiConstants.homePageSearch,
      queryParameters: {'perPage': perPage, 'text': text},
    );
    return _parse(
      response,
      (d) => SearchResultModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// GET news/all (جاهز لزر "أظهر الكل" لاحقًا).
  Future<List<NewsModel>> getAllNews() async {
    final response = await _api.getRequest(ApiConstants.newsAll);
    return _parse(
      response,
      (d) => (d as List)
          .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// GET subjects/all (جاهز لزر "أظهر الكل" لاحقًا).
  Future<List<SubjectModel>> getAllSubjects() async {
    final response = await _api.getRequest(ApiConstants.subjectsAll);
    return _parse(
      response,
      (d) => (d as List)
          .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
