import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/library/data/models/library_package.dart';
import 'package:darb/features/library/data/models/library_semester.dart';
import 'package:darb/features/library/data/repositories/library_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// حالة تحميل قائمة تبويب (الفصول / الباقات): items == null يعني لم تُحمَّل بعد.
class LoadState<T> {
  const LoadState({
    this.items,
    this.loading = false,
    this.error,
    this.requested = false,
  });

  final List<T>? items;
  final bool loading;
  final String? error;

  /// طُلب التبويب مرة واحدة على الأقل (لإعادة التحميل بعد تحديث الكورسات).
  final bool requested;
}

class LibraryData {
  const LibraryData({
    this.courses = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
    this.query = '',
    this.semesters = const LoadState<LibrarySemester>(),
    this.packages = const LoadState<LibraryPackage>(),
  });

  final List<CourseModel> courses;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String query;
  final LoadState<LibrarySemester> semesters;
  final LoadState<LibraryPackage> packages;

  String get _q => query.trim();

  /// ⚠️ البحث محلي على ما تم تحميله في كل تبويب.
  List<CourseModel> get visibleCourses => _q.isEmpty
      ? courses
      : courses
            .where((c) =>
                c.name.contains(_q) ||
                c.courseName.contains(_q) ||
                c.professor.contains(_q))
            .toList();

  List<LibrarySemester> get visibleSemesters {
    final all = semesters.items ?? const <LibrarySemester>[];
    return _q.isEmpty
        ? all
        : all
              .where((s) =>
                  s.name.contains(_q) ||
                  s.subjectName.contains(_q) ||
                  s.professor.contains(_q))
              .toList();
  }

  List<LibraryPackage> get visiblePackages {
    final all = packages.items ?? const <LibraryPackage>[];
    return _q.isEmpty ? all : all.where((p) => p.name.contains(_q)).toList();
  }

  LibraryData copyWith({
    List<CourseModel>? courses,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? query,
    LoadState<LibrarySemester>? semesters,
    LoadState<LibraryPackage>? packages,
  }) => LibraryData(
    courses: courses ?? this.courses,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    query: query ?? this.query,
    semesters: semesters ?? this.semesters,
    packages: packages ?? this.packages,
  );
}

/// صفحة "موادي": الكورسات (مع صفحات إضافية) + الفصول + الباقات + بحث محلي.
class LibraryCubit extends Cubit<BaseState<LibraryData>> {
  LibraryCubit(this._repository)
    : super(
        const BaseState<LibraryData>(
          stateValue: StateValue.loading,
          data: LibraryData(),
        ),
      );

  static const int _perPage = 10;

  final LibraryRepository _repository;

  LibraryData get _data => state.data!;

  String _messageOf(Object e) => e is RemoteExceptions
      ? e.errorMsg
      : ErrorCode.UNKNOWN.getLocalizedMessage();

  // ───────────── الكورسات ─────────────

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(
        state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true),
      );
    }
    try {
      final courses = await _repository.getCourses(page: 1, perPage: _perPage);
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: _data.copyWith(
            courses: courses,
            page: 1,
            hasMore: courses.length >= _perPage,
            loadingMore: false,
          ),
          clearErrorMessage: true,
        ),
      );
      // الفصول مبنية على الكورسات: نعيد بناءها إن كان التبويب قد طُلب.
      if (_data.semesters.requested) loadSemesters(force: true);
    } catch (e) {
      if (isClosed || _data.courses.isNotEmpty) return;
      emit(
        state.copyWith(
          stateValue: StateValue.error,
          errorMessage: _messageOf(e),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final data = _data;
    if (state.stateValue != StateValue.loaded ||
        !data.hasMore ||
        data.loadingMore) {
      return;
    }
    emit(state.copyWith(data: data.copyWith(loadingMore: true)));
    final next = data.page + 1;
    try {
      final more = await _repository.getCourses(page: next, perPage: _perPage);
      if (isClosed) return;
      emit(
        state.copyWith(
          data: _data.copyWith(
            courses: [..._data.courses, ...more],
            page: next,
            hasMore: more.length >= _perPage,
            loadingMore: false,
          ),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(data: _data.copyWith(loadingMore: false)));
    }
  }

  // ───────────── الفصول ─────────────

  /// ⚠️ تُبنى من أول صفحة كورسات محمَّلة (10) عبر courses/details لكل كورس.
  Future<void> loadSemesters({bool force = false}) async {
    final current = _data.semesters;
    if (!force && (current.loading || current.items != null)) return;

    // الكورسات لم تُحمَّل بعد: نسجل الطلب وسيُنفَّذ بعد load().
    if (state.stateValue != StateValue.loaded) {
      emit(
        state.copyWith(
          data: _data.copyWith(
            semesters: LoadState<LibrarySemester>(
              items: current.items,
              requested: true,
            ),
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        data: _data.copyWith(
          semesters: LoadState<LibrarySemester>(
            items: current.items,
            loading: true,
            requested: true,
          ),
        ),
      ),
    );
    try {
      final items = await _repository.getSemesters(_data.courses);
      if (isClosed) return;
      emit(
        state.copyWith(
          data: _data.copyWith(
            semesters: LoadState<LibrarySemester>(items: items, requested: true),
          ),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          data: _data.copyWith(
            semesters: LoadState<LibrarySemester>(
              items: current.items,
              error: _messageOf(e),
              requested: true,
            ),
          ),
        ),
      );
    }
  }

  // ───────────── الباقات ─────────────

  Future<void> loadPackages({bool force = false}) async {
    final current = _data.packages;
    if (!force && (current.loading || current.items != null)) return;

    emit(
      state.copyWith(
        data: _data.copyWith(
          packages: LoadState<LibraryPackage>(
            items: current.items,
            loading: true,
            requested: true,
          ),
        ),
      ),
    );
    try {
      final items = await _repository.getPackages();
      if (isClosed) return;
      emit(
        state.copyWith(
          data: _data.copyWith(
            packages: LoadState<LibraryPackage>(items: items, requested: true),
          ),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          data: _data.copyWith(
            packages: LoadState<LibraryPackage>(
              items: current.items,
              error: _messageOf(e),
              requested: true,
            ),
          ),
        ),
      );
    }
  }

  void search(String query) {
    if (state.data == null) return;
    emit(state.copyWith(data: _data.copyWith(query: query)));
  }
}
