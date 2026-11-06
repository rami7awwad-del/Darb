import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:dio/dio.dart';

/// طلبات الاختبارات والنشاطات اليومية.
class QuizRemoteDataSource {
  QuizRemoteDataSource(this._api);

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

  List<QuizListItem> _items(dynamic data, {required bool isActivity}) {
    // بلا بيانات قد يعيد الخادم [] أو null.
    if (data is! List) return const [];
    return data
        .map((e) => QuizListItem.fromJson(
              e as Map<String, dynamic>,
              isActivity: isActivity,
            ))
        .toList();
  }

  /// GET exams/my
  Future<List<QuizListItem>> getMyExams() async {
    final response = await _api.getRequest(ApiConstants.examsMy);
    return _parse(response, (d) => _items(d, isActivity: false));
  }

  /// GET daily-activities/my
  Future<List<QuizListItem>> getMyActivities() async {
    final response = await _api.getRequest(ApiConstants.dailyActivitiesMy);
    return _parse(response, (d) => _items(d, isActivity: true));
  }

  /// GET exams/result?id= → الأسئلة والأجوبة (+ current_answer بعد الحضور).
  Future<QuizDetails> getExam(int id) async {
    final response = await _api.getRequest(
      ApiConstants.examsResult,
      queryParameters: {'id': id},
    );
    return _parse(
      response,
      (d) => QuizDetails.fromJson(d as Map<String, dynamic>),
    );
  }

  /// POST exams/attend-exam (form-data): `answers_id[]` مكررًا لكل إجابة.
  /// الخادم لا يطلب معرّف الاختبار؛ يعرفه من معرّفات الإجابات.
  Future<QuizScore> attend(List<int> answerIds) async {
    final response = await _api.postFormFields(
      ApiConstants.examsAttend,
      [for (final id in answerIds) MapEntry('answers_id[]', '$id')],
    );
    return _parse(
      response,
      (d) => d is Map<String, dynamic>
          ? QuizScore.fromJson(d)
          : const QuizScore(
              questionsCount: 0,
              correctAnswers: 0,
              failedAnswers: 0,
            ),
    );
  }
}
