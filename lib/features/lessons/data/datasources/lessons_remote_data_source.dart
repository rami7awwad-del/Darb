import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/lessons/data/models/lesson_details_model.dart';

class LessonsRemoteDataSource {
  LessonsRemoteDataSource(this._api);

  final ApiService _api;

  /// GET lessions/details?id= → الدرس + فصله + تعليقاته في طلب واحد.
  /// يقبل data ككائن أو داخل قائمة.
  Future<LessonDetailsModel> getDetails(int lessonId) async {
    final response = await _api.getRequest(
      ApiConstants.lessonsDetails,
      queryParameters: {'id': lessonId},
    );
    try {
      var data = (response.data as Map<String, dynamic>)['data'];
      if (data is List && data.isNotEmpty) data = data.first;
      return LessonDetailsModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      throw RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );
    }
  }

  /// POST comments/add-comment (form-data: lession_id, comment).
  Future<void> addComment({
    required int lessonId,
    required String comment,
  }) async {
    await _api.postFormData(ApiConstants.commentsAddComment, {
      'lession_id': lessonId,
      'comment': comment,
    });
  }

  /// POST lessions/attend-lession → تسجيل حضور الدرس.
  /// ⚠️ اسم الحقل lession_id افتراض (الرد يحمل lession_id)؛ لم يُرَ جسم الطلب.
  Future<void> attend(int lessonId) async {
    await _api.postFormData(ApiConstants.lessonsAttend, {
      'lession_id': lessonId,
    });
  }
}
