import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';

class CoursesRemoteDataSource {
  CoursesRemoteDataSource(this._api);

  final ApiService _api;

  /// GET courses/details?subject_id= → data: دورة + semesters[].lessions[].
  Future<CourseDetailsModel> getDetails(int courseId) async {
    final response = await _api.getRequest(
      ApiConstants.coursesDetails,
      queryParameters: {'subject_id': courseId},
    );
    try {
      final body = response.data as Map<String, dynamic>;
      return CourseDetailsModel.fromJson(body['data'] as Map<String, dynamic>);
    } catch (_) {
      throw RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );
    }
  }
}
