import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/lessons/data/models/comment_model.dart';
import 'package:darb/features/lessons/data/repositories/lessons_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentsData {
  const CommentsData({
    this.comments = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
    this.sending = false,
  });

  final List<CommentModel> comments;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final bool sending;

  CommentsData copyWith({
    List<CommentModel>? comments,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    bool? sending,
  }) =>
      CommentsData(
        comments: comments ?? this.comments,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
        sending: sending ?? this.sending,
      );
}

/// شاشة الدرس: تعليقات الدرس (مع صفحات) + تسجيل الحضور.
/// ⚠️ رد القائمة لا يحمل meta ولا perPage، فنعتبر وجود صفحة تالية ما دامت
/// الصفحة الحالية غير فارغة؛ صفحة فارغة تُنهي التحميل.
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
      final items = await _repository.getComments(lessonId: lessonId, page: 1);
      if (isClosed) return;
      emit(BaseState<CommentsData>(
        stateValue: StateValue.loaded,
        data: _data.copyWith(
          comments: items,
          page: 1,
          hasMore: items.isNotEmpty,
          loadingMore: false,
        ),
      ));
    } catch (e) {
      if (isClosed || _data.comments.isNotEmpty) return;
      emit(state.copyWith(
        stateValue: StateValue.error,
        errorMessage: _messageOf(e),
      ));
    }
  }

  Future<void> loadMore() async {
    final data = _data;
    if (state.stateValue != StateValue.loaded ||
        !data.hasMore ||
        data.loadingMore) {
      return;
    }
    emit(state.copyWith(data: data.copyWith(loadingMore: true)));
    final next = data.page + 1;
    try {
      final more =
          await _repository.getComments(lessonId: lessonId, page: next);
      if (isClosed) return;
      emit(state.copyWith(
        data: _data.copyWith(
          comments: [..._data.comments, ...more],
          page: next,
          hasMore: more.isNotEmpty,
          loadingMore: false,
        ),
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(data: _data.copyWith(loadingMore: false)));
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
      await load(silent: true); // نعيد الجلب ليظهر التعليق بشكل الخادم.
      return null;
    } catch (e) {
      if (isClosed) return null;
      emit(state.copyWith(data: _data.copyWith(sending: false)));
      return _messageOf(e);
    }
  }
}
