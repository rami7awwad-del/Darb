import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/library/data/datasources/library_remote_data_source.dart';
import 'package:darb/features/library/data/models/library_package.dart';
import 'package:darb/features/library/data/models/library_semester.dart';

/// Repository that gives the cubits access to the library data.
class LibraryRepository {
  LibraryRepository(this._remote);

  final LibraryRemoteDataSource _remote;

  Future<List<CourseModel>> getCourses({
    required int page,
    required int perPage,
  }) =>
      _remote.getCourses(page: page, perPage: perPage);

  Future<List<LibrarySemester>> getSemesters(List<CourseModel> courses) async {
    Object? lastError;
    var failed = 0;
    final lists = await Future.wait(
      courses.map((c) async {
        try {
          return await _remote.getCourseSemesters(c);
        } catch (e) {
          failed++;
          lastError = e;
          return <LibrarySemester>[];
        }
      }),
    );
    if (courses.isNotEmpty && failed == courses.length) throw lastError!;
    return lists.expand((e) => e).toList();
  }

  Future<List<LibraryPackage>> getPackages() async {
    final packages = await _remote.getPackages();
    return Future.wait(
      packages.map((p) async {
        try {
          return await _remote.getPackageDetails(p.id);
        } catch (_) {
          return p;
        }
      }),
    );
  }
}
