import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:darb/features/quiz/data/repositories/quiz_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestsData {
  const TestsData({this.exams = const [], this.activities = const []});

  final List<QuizListItem> exams;
  final List<QuizListItem> activities;
}

/// شاشة "اختباراتي": exams/my + daily-activities/my.
class TestsCubit extends Cubit<BaseState<TestsData>> {
  TestsCubit(this._repository) : super(const BaseState<TestsData>());

  final QuizRepository _repository;

  Future<void> load({bool silent = false}) async {
    if (!silent || state.data == null) {
      emit(const BaseState<TestsData>(stateValue: StateValue.loading));
    }
    try {
      final results = await Future.wait([
        _repository.getMyExams(),
        _repository.getMyActivities(),
      ]);
      if (isClosed) return;
      emit(BaseState<TestsData>(
        stateValue: StateValue.loaded,
        data: TestsData(exams: results[0], activities: results[1]),
      ));
    } catch (e) {
      if (isClosed) return;
      emit(BaseState<TestsData>(
        stateValue: StateValue.error,
        data: state.data,
        errorMessage: e is RemoteExceptions
            ? e.errorMsg
            : ErrorCode.UNKNOWN.getLocalizedMessage(),
      ));
    }
  }
}
