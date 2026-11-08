import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/notifications/data/models/notification_model.dart';
import 'package:darb/features/notifications/data/repositories/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State data for the notifications.
class NotificationsData {
  const NotificationsData({
    this.items = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<NotificationModel> items;

  final int page;

  final bool hasMore;
  final bool loadingMore;

  int get unreadCount => items.where((e) => !e.isRead).length;

  /// Returns a copy with the given fields replaced.
  NotificationsData copyWith({
    List<NotificationModel>? items,
    int? page,
    bool? hasMore,
    bool? loadingMore,
  }) => NotificationsData(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

/// Cubit that manages the notifications state.
class NotificationsCubit extends Cubit<BaseState<NotificationsData>> {
  NotificationsCubit(this._repository)
    : super(
        const BaseState<NotificationsData>(
          stateValue: StateValue.loading,
          data: NotificationsData(),
        ),
      );

  final NotificationsRepository _repository;

  NotificationsData get _data => state.data!;

  /// Loads the data and updates the state.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(
        state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true),
      );
    }
    try {
      final items = await _repository.getNotifications(page: 1);
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: NotificationsData(
            items: items,
            page: 1,
            hasMore: items.isNotEmpty,
          ),
          clearErrorMessage: true,
        ),
      );
    } on RemoteExceptions catch (e) {
      _onLoadError(e.errorMsg);
    } catch (_) {
      _onLoadError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  /// Handles load error.
  void _onLoadError(String message) {
    if (isClosed) return;
    if (_data.items.isNotEmpty) return;
    emit(state.copyWith(stateValue: StateValue.error, errorMessage: message));
  }

  /// Loads the next page of results.
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
      final more = await _repository.getNotifications(page: next);
      if (isClosed) return;
      final known = _data.items.map((e) => e.id).toSet();
      final fresh = more.where((e) => !known.contains(e.id)).toList();
      emit(
        state.copyWith(
          data: _data.copyWith(
            items: [..._data.items, ...fresh],
            page: next,
            hasMore: fresh.isNotEmpty,
            loadingMore: false,
          ),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(data: _data.copyWith(loadingMore: false)));
    }
  }
}
