import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/lessons/data/models/comment_model.dart';
import 'package:darb/features/lessons/data/models/lesson_details_model.dart';
import 'package:darb/features/lessons/data/repositories/lessons_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State data for the comments.
class CommentsData {
  const CommentsData({this.details, this.sending = false});

  final LessonDetailsModel? details;
  final bool sending;

  List<CommentModel> get comments => details?.comments ?? const [];

  /// Returns a copy with the given fields replaced.
  CommentsData copyWith({LessonDetailsModel? details, bool? sending}) =>
      CommentsData(
        details: details ?? this.details,
        sending: sending ?? this.sending,
      );
}

/// Cubit that manages the lesson state.
class LessonCubit extends Cubit<BaseState<CommentsData>> {
  LessonCubit(this._repository, {required this.lessonId})
      : super(
          const BaseState<CommentsData>(
            stateValue: StateValue.loading,
            data: CommentsData(),
          ),
        );

  final LessonsRepository _repository;
  final int lessonId;

  CommentsData get _data => state.data!;

  String _messageOf(Object e) => e is RemoteExceptions
      ? e.errorMsg
      : ErrorCode.UNKNOWN.getLocalizedMessage();

  Future<void> attend() async {
    try {
      await _repository.attend(lessonId);
    } catch (_) {}
  }

  /// Loads the data and updates the state.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true));
    }
    try {
      final details = await _repository.getDetails(lessonId);
      if (isClosed) return;
      emit(BaseState<CommentsData>(
        stateValue: StateValue.loaded,
        data: _data.copyWith(details: details),
      ));
    } catch (e) {
      if (isClosed || _data.details != null) return;
      emit(state.copyWith(
        stateValue: StateValue.error,
        errorMessage: _messageOf(e),
      ));
    }
  }

  Future<String?> send(String text) async {
    if (_data.sending) return null;
    emit(state.copyWith(data: _data.copyWith(sending: true)));
    try {
      await _repository.addComment(lessonId: lessonId, comment: text);
      if (isClosed) return null;
      emit(state.copyWith(data: _data.copyWith(sending: false)));
      await load(silent: true);
      return null;
    } catch (e) {
      if (isClosed) return null;
      emit(state.copyWith(data: _data.copyWith(sending: false)));
      return _messageOf(e);
    }
  }
}
