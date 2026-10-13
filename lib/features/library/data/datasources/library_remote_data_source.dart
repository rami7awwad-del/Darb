import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/library/data/models/library_package.dart';
import 'package:darb/features/library/data/models/library_semester.dart';

class LibraryRemoteDataSource {
  LibraryRemoteDataSource(this._api);

  final ApiService _api;

  /// GET courses/paginate?page=1&perPage=10 → data: قائمة كورسات (CourseModel).
  /// الرد لا يحمل meta، فالصفحة الأخيرة تُعرف من عدد العناصر.
  Future<List<CourseModel>> getCourses({
    required int page,
    required int perPage,
  }) async {
    final response = await _api.getRequest(
      ApiConstants.coursesPaginate,
      queryParameters: {'page': page, 'perPage': perPage},
    );
    return _parse(
      response,
      () => (_data(response) as List)
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// GET courses/details?subject_id= → data.semesters[].
  Future<List<LibrarySemester>> getCourseSemesters(CourseModel course) async {
    final response = await _api.getRequest(
      ApiConstants.coursesDetails,
      queryParameters: {'subject_id': course.id},
    );
    return _parse(
      response,
      () => ((_data(response) as Map<String, dynamic>)['semesters'] as List? ??
              const [])
          .map((e) => LibrarySemester.fromJson(e as Map<String, dynamic>, course))
          .toList(),
    );
  }

  /// GET packages/all → data: قائمة باقات.
  Future<List<LibraryPackage>> getPackages() async {
    final response = await _api.getRequest(ApiConstants.packagesAll);
    return _parse(
      response,
      () => (_data(response) as List)
          .map((e) => LibraryPackage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// GET packages/details?id= → data: باقة مع subjects[].
  Future<LibraryPackage> getPackageDetails(int id) async {
    final response = await _api.getRequest(
      ApiConstants.packagesDetails,
      queryParameters: {'id': id},
    );
    return _parse(
      response,
      () => LibraryPackage.fromJson(_data(response) as Map<String, dynamic>),
    );
  }

  dynamic _data(dynamic response) =>
      (response.data as Map<String, dynamic>)['data'];

  T _parse<T>(dynamic response, T Function() parse) {
    try {
      return parse();
    } catch (_) {
      throw RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );
    }
  }
}
