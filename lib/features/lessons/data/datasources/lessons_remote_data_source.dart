import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/lessons/data/models/comment_model.dart';

class LessonsRemoteDataSource {
  LessonsRemoteDataSource(this._api);

  final ApiService _api;

  /// GET comments/get-by-lession?lession_id=&page= → data: قائمة تعليقات.
  Future<List<CommentModel>> getComments({
    required int lessonId,
    required int page,
  }) async {
    final response = await _api.getRequest(
      ApiConstants.commentsGetByLession,
      queryParameters: {'lession_id': lessonId, 'page': page},
    );
    try {
      final body = response.data as Map<String, dynamic>;
      return (body['data'] as List)
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
