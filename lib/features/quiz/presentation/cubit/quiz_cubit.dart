import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/quiz/data/models/quiz_models.dart';
import 'package:darb/features/quiz/data/repositories/quiz_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizState {
  const QuizState({this.selected = const {}, this.submitting = false});

  /// questionId → answerId
  final Map<int, int> selected;
  final bool submitting;

  QuizState copyWith({Map<int, int>? selected, bool? submitting}) => QuizState(
        selected: selected ?? this.selected,
        submitting: submitting ?? this.submitting,
      );
}

/// اختيارات المستخدم أثناء الاختبار + تسليمها إلى exams/attend-exam.
class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this._repository) : super(const QuizState());

  final QuizRepository _repository;

  void select(int questionId, int answerId) => emit(
        state.copyWith(selected: {...state.selected, questionId: answerId}),
      );

  /// يسلّم الإجابات ثم يجلب النتيجة من exams/result (فيها current_answer).
  /// يعيد [QuizOutcome] عند النجاح. إن فشل جلب النتيجة بعد نجاح التسليم نحسبها
  /// محليًا، وإن فشل التسليم نفسه يُرمى الخطأ ليعرضه المستدعي.
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
