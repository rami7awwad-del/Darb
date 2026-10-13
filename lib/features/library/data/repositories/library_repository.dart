import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/library/data/datasources/library_remote_data_source.dart';
import 'package:darb/features/library/data/models/library_package.dart';
import 'package:darb/features/library/data/models/library_semester.dart';

class LibraryRepository {
  LibraryRepository(this._remote);

  final LibraryRemoteDataSource _remote;

  Future<List<CourseModel>> getCourses({
    required int page,
    required int perPage,
  }) =>
      _remote.getCourses(page: page, perPage: perPage);

  /// لا يوجد endpoint يعيد كل الفصول، لذا نجلب تفاصيل كل كورس بالتوازي
  /// (courses/details) وندمج فصولها. إن فشلت كل الطلبات نرمي آخر خطأ.
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

  /// قائمة الباقات ثم تفاصيل كل باقة (للمواد). إن فشلت التفاصيل نبقي الباقة بلا مواد.
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
