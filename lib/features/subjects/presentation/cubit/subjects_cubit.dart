import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/home/data/models/subject_model.dart';
import 'package:darb/features/subjects/data/repositories/subjects_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit that manages the subjects state.
class SubjectsCubit extends Cubit<BaseState<List<SubjectModel>>> {
  SubjectsCubit(this._repository)
      : super(const BaseState<List<SubjectModel>>(stateValue: StateValue.loading));

  final SubjectsRepository _repository;

  /// Loads the data and updates the state.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true));
    }
    try {
      final subjects = await _repository.getAll();
      if (isClosed) return;
      emit(BaseState<List<SubjectModel>>(
        stateValue: StateValue.loaded,
        data: subjects,
      ));
    } on RemoteExceptions catch (e) {
      _onError(e.errorMsg);
    } catch (_) {
      _onError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  /// Handles error.
  void _onError(String message) {
    if (isClosed || state.data != null) return;
    emit(state.copyWith(stateValue: StateValue.error, errorMessage: message));
  }
}
