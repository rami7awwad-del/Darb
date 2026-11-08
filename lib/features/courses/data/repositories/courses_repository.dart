import 'package:darb/features/courses/data/datasources/courses_remote_data_source.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';

/// Repository that gives the cubits access to the courses data.
class CoursesRepository {
  CoursesRepository(this._remote);

  final CoursesRemoteDataSource _remote;

  /// Gets details.
  Future<CourseDetailsModel> getDetails(int courseId) =>
      _remote.getDetails(courseId);
}
