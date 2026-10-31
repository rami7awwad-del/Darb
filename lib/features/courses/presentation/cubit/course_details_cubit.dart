import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/courses/data/models/course_details_model.dart';
import 'package:darb/features/courses/data/repositories/courses_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// صفحة تفاصيل الدورة: الفصول ودروسها (مسار التعلم).
class CourseDetailsCubit extends Cubit<BaseState<CourseDetailsModel>> {
  CourseDetailsCubit(this._repository, {required this.courseId})
      : super(
          const BaseState<CourseDetailsModel>(stateValue: StateValue.loading),
        );

  final CoursesRepository _repository;
  final int courseId;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true));
    }
    try {
      final details = await _repository.getDetails(courseId);
      if (isClosed) return;
      emit(BaseState<CourseDetailsModel>(
        stateValue: StateValue.loaded,
        data: details,
      ));
    } on RemoteExceptions catch (e) {
      _onError(e.errorMsg);
    } catch (_) {
      _onError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  void _onError(String message) {
    if (isClosed || state.data != null) return;
    emit(state.copyWith(stateValue: StateValue.error, errorMessage: message));
  }
}
