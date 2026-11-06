import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/lessons/data/models/comment_model.dart';
import 'package:darb/features/lessons/data/models/lesson_details_model.dart';
import 'package:darb/features/lessons/data/repositories/lessons_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// بيانات شاشة الدرس: تفاصيل موحّدة من lessions/details (الدرس + الفصل + التعليقات).
/// [comments] مستخرجة من التفاصيل، و[sending] حالة إرسال تعليق.
class CommentsData {
  const CommentsData({this.details, this.sending = false});

  final LessonDetailsModel? details;
  final bool sending;

  List<CommentModel> get comments => details?.comments ?? const [];

  CommentsData copyWith({LessonDetailsModel? details, bool? sending}) =>
      CommentsData(
        details: details ?? this.details,
        sending: sending ?? this.sending,
      );
}

/// شاشة الدرس: طلب واحد (lessions/details?id=) يغذي الدرس والفصل والتعليقات،
/// + تسجيل الحضور + إضافة تعليق (ثم إعادة جلب التفاصيل).
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

  /// تسجيل الحضور: أفضل جهد، وفشله لا يمنع عرض الدرس.
  Future<void> attend() async {
    try {
      await _repository.attend(lessonId);
    } catch (_) {}
  }

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
      // عند إعادة تحديث صامتة نبقي ما عرضناه سابقًا.
      if (isClosed || _data.details != null) return;
      emit(state.copyWith(
        stateValue: StateValue.error,
        errorMessage: _messageOf(e),
      ));
    }
  }

  /// يعيد null عند النجاح، وإلا رسالة الخطأ.
  Future<String?> send(String text) async {
    if (_data.sending) return null;
    emit(state.copyWith(data: _data.copyWith(sending: true)));
    try {
      await _repository.addComment(lessonId: lessonId, comment: text);
      if (isClosed) return null;
      emit(state.copyWith(data: _data.copyWith(sending: false)));
      await load(silent: true); // إعادة جلب التفاصيل ليظهر التعليق بشكل الخادم.
      return null;
    } catch (e) {
      if (isClosed) return null;
      emit(state.copyWith(data: _data.copyWith(sending: false)));
      return _messageOf(e);
    }
  }
}
