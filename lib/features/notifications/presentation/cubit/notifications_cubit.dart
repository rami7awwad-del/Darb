import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/notifications/data/models/notification_model.dart';
import 'package:darb/features/notifications/data/repositories/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsData {
  const NotificationsData({
    this.items = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<NotificationModel> items;

  /// آخر صفحة تم تحميلها.
  final int page;

  /// الرد لا يحمل بيانات ترقيم (meta) ولا حجم صفحة ثابتًا،
  /// فنستمر بالتحميل حتى تعود صفحة فارغة أو بلا عناصر جديدة.
  final bool hasMore;
  final bool loadingMore;

  int get unreadCount => items.where((e) => !e.isRead).length;

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

/// شاشة الإشعارات: الصفحة الأولى + تحميل صفحات إضافية عند التمرير.
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

  /// [silent] = true للسحب للتحديث (بدون مؤشر التحميل الكامل).
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

  void _onLoadError(String message) {
    if (isClosed) return;
    // فشل تحديث صامت مع وجود بيانات سابقة: نُبقي ما هو معروض.
    if (_data.items.isNotEmpty) return;
    emit(state.copyWith(stateValue: StateValue.error, errorMessage: message));
  }

  /// يحمّل الصفحة التالية. فشله صامت، وتُعاد المحاولة عند التمرير التالي.
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
      // حماية من خادم يتجاهل page فيكرر نفس العناصر.
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
