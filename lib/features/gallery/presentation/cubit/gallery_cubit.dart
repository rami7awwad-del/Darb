import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/gallery/data/models/gallery_model.dart';
import 'package:darb/features/gallery/data/repositories/gallery_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryData {
  const GalleryData({
    this.albums = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<GalleryModel> albums;

  /// آخر صفحة تم تحميلها.
  final int page;

  /// false عندما تعيد الصفحة عناصر أقل من perPage.
  final bool hasMore;
  final bool loadingMore;

  GalleryData copyWith({
    List<GalleryModel>? albums,
    int? page,
    bool? hasMore,
    bool? loadingMore,
  }) => GalleryData(
    albums: albums ?? this.albums,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

/// تبويب المعرض: قائمة الألبومات مع تحميل صفحات إضافية عند التمرير.
class GalleryCubit extends Cubit<BaseState<GalleryData>> {
  GalleryCubit(this._repository)
    : super(
        const BaseState<GalleryData>(
          stateValue: StateValue.loading,
          data: GalleryData(),
        ),
      );

  static const int _perPage = 10;

  final GalleryRepository _repository;

  GalleryData get _data => state.data!;

  /// يحمّل الصفحة الأولى. [silent] = true للسحب للتحديث (بدون مؤشر التحميل الكامل).
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(
        state.copyWith(stateValue: StateValue.loading, clearErrorMessage: true),
      );
    }
    try {
      final albums = await _repository.getGalleries(page: 1, perPage: _perPage);
      if (isClosed) return;
      emit(
        state.copyWith(
          stateValue: StateValue.loaded,
          data: _data.copyWith(
            albums: albums,
            page: 1,
            hasMore: albums.length >= _perPage,
            loadingMore: false,
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
    if (_data.albums.isNotEmpty) return;
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
      final more = await _repository.getGalleries(
        page: next,
        perPage: _perPage,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          data: _data.copyWith(
            albums: [..._data.albums, ...more],
            page: next,
            hasMore: more.length >= _perPage,
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
