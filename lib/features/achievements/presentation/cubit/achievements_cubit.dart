import 'dart:async';

import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/library/data/repositories/library_repository.dart';
import 'package:darb/features/profile/data/models/profile_model.dart';
import 'package:darb/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State data for the achievements.
class AchievementsData {
  const AchievementsData({
    this.profile,
    this.courses = const [],
    this.coursesLoading = true,
    this.coursesError,
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final ProfileModel? profile;
  final List<CourseModel> courses;

  final bool coursesLoading;
  final String? coursesError;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  /// Returns a copy with the given fields replaced.
  AchievementsData copyWith({
    ProfileModel? profile,
    List<CourseModel>? courses,
    bool? coursesLoading,
    String? coursesError,
    bool clearCoursesError = false,
    int? page,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      AchievementsData(
        profile: profile ?? this.profile,
        courses: courses ?? this.courses,
        coursesLoading: coursesLoading ?? this.coursesLoading,
        coursesError: clearCoursesError ? null : coursesError ?? this.coursesError,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// Cubit that manages the achievements state.
class AchievementsCubit extends Cubit<BaseState<AchievementsData>> {
  AchievementsCubit(this._profile, this._library)
      : super(const BaseState<AchievementsData>(
          stateValue: StateValue.loading,
          data: AchievementsData(),
        ));

  static const int _perPage = 10;

  final ProfileRepository _profile;
  final LibraryRepository _library;

  AchievementsData get _data => state.data!;

  /// Loads the data and updates the state.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(const BaseState<AchievementsData>(
        stateValue: StateValue.loading,
        data: AchievementsData(),
      ));
    }
    await Future.wait([_loadProfile(), loadCourses(silent: silent)]);
  }

  /// Loads profile.
  Future<void> _loadProfile() async {
    try {
      final profile = await _profile.getProfile();
      if (isClosed) return;
      emit(state.copyWith(
        stateValue: StateValue.loaded,
        data: _data.copyWith(profile: profile),
        clearErrorMessage: true,
      ));
    } on RemoteExceptions catch (e) {
      _onProfileError(e.errorMsg);
    } catch (_) {
      _onProfileError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  /// Handles profile error.
  void _onProfileError(String message) {
    if (isClosed || _data.profile != null) return;
    emit(state.copyWith(stateValue: StateValue.error, errorMessage: message));
  }

  /// Loads courses.
  Future<void> loadCourses({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(
        data: _data.copyWith(coursesLoading: true, clearCoursesError: true),
      ));
    }
    try {
      final courses = await _library.getCourses(page: 1, perPage: _perPage);
      if (isClosed) return;
      emit(state.copyWith(
        data: _data.copyWith(
          courses: courses,
          coursesLoading: false,
          clearCoursesError: true,
          page: 1,
          hasMore: courses.length >= _perPage,
          loadingMore: false,
        ),
      ));
    } on RemoteExceptions catch (e) {
      _onCoursesError(e.errorMsg);
    } catch (_) {
      _onCoursesError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  /// Handles courses error.
  void _onCoursesError(String message) {
    if (isClosed) return;
    emit(state.copyWith(
      data: _data.copyWith(
        coursesLoading: false,
        coursesError: _data.courses.isEmpty ? message : null,
      ),
    ));
  }

  /// Loads the next page of results.
  Future<void> loadMore() async {
    final data = _data;
    if (data.coursesLoading || !data.hasMore || data.loadingMore) return;
    emit(state.copyWith(data: data.copyWith(loadingMore: true)));
    final next = data.page + 1;
    try {
      final more = await _library.getCourses(page: next, perPage: _perPage);
      if (isClosed) return;
      emit(state.copyWith(
        data: _data.copyWith(
          courses: [..._data.courses, ...more],
          page: next,
          hasMore: more.length >= _perPage,
          loadingMore: false,
        ),
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(data: _data.copyWith(loadingMore: false)));
    }
  }
}
