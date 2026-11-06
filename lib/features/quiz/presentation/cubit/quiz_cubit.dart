import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:darb/features/quiz/data/repositories/quiz_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the quiz that is being taken.
class QuizState {
  const QuizState({this.selected = const {}, this.submitting = false});

  final Map<int, int> selected;
  final bool submitting;

  /// Returns a copy with the given fields replaced.
  QuizState copyWith({Map<int, int>? selected, bool? submitting}) => QuizState(
        selected: selected ?? this.selected,
        submitting: submitting ?? this.submitting,
      );
}

/// Cubit that manages the quiz state.
class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this._repository) : super(const QuizState());

  final QuizRepository _repository;

  void select(int questionId, int answerId) => emit(
        state.copyWith(selected: {...state.selected, questionId: answerId}),
      );

  /// Sends the collected data to the server.
  Future<QuizOutcome> submit({
    required int examId,
    required String title,
    required List<QuizQuestion> questions,
  }) async {
    emit(state.copyWith(submitting: true));
    try {
      await _repository.attend(state.selected.values.toList());
      try {
        final details = await _repository.getExam(examId);
        return QuizOutcome.fromDetails(details, title: title);
      } catch (_) {
        return QuizOutcome(
          title: title,
          questions: questions,
          selected: state.selected,
        );
      }
    } catch (e) {
      throw e is RemoteExceptions
          ? e.errorMsg
          : ErrorCode.UNKNOWN.getLocalizedMessage();
    } finally {
      if (!isClosed) emit(state.copyWith(submitting: false));
    }
  }
}
