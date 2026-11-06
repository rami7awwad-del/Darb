import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/home/data/models/course_model.dart';
import 'package:darb/features/subscription/data/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit that manages the my subscriptions state.
class MySubscriptionsCubit extends Cubit<BaseState<List<CourseModel>>> {
  MySubscriptionsCubit(this._repository) : super(const BaseState());

  final SubscriptionRepository _repository;

  /// Loads the data and updates the state.
  Future<void> load({bool silent = false}) async {
    if (!silent || state.data == null) {
      emit(const BaseState<List<CourseModel>>(stateValue: StateValue.loading));
    }
    try {
      final courses = await _repository.getMyCourses();
      if (isClosed) return;
      emit(BaseState<List<CourseModel>>(
        stateValue: StateValue.loaded,
        data: courses,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(BaseState<List<CourseModel>>(
        stateValue: StateValue.error,
        errorMessage: e is RemoteExceptions
            ? e.errorMsg
            : ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }
}
