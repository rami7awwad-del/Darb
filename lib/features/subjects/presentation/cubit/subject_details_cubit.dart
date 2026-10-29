import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/subjects/data/models/subject_details_model.dart';
import 'package:darb/features/subjects/data/repositories/subjects_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// صفحة المادة: طلب واحد يغذّي التبويبات الثلاثة (المحتوى، إختبارات، نشاطات يومية).
class SubjectDetailsCubit extends Cubit<BaseState<SubjectDetailsModel>> {
  SubjectDetailsCubit(this._repository, {required this.subjectId})
      : super(const BaseState<SubjectDetailsModel>(stateValue: StateValue.loading));

  final SubjectsRepository _repository;
  final int subjectId;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true));
    }
    try {
      final details = await _repository.getDetails(subjectId);
      if (isClosed) return;
      emit(BaseState<SubjectDetailsModel>(
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
