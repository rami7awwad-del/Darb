import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/gallery/data/models/gallery_model.dart';
import 'package:darb/features/gallery/data/repositories/gallery_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'gallery_state.dart';

/// تبويب المعرض: قائمة الألبومات مع تحميل صفحات إضافية عند التمرير.
class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit(this._repository) : super(const GalleryState());

  static const int _perPage = 10;

  final GalleryRepository _repository;

  /// يحمّل الصفحة الأولى. [silent] = true للسحب للتحديث (بدون مؤشر التحميل الكامل).
  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: GalleryStatus.loading));
    try {
      final albums = await _repository.getGalleries(page: 1, perPage: _perPage);
      if (isClosed) return;
      emit(state.copyWith(
        status: GalleryStatus.ready,
        albums: albums,
        page: 1,
        hasMore: albums.length >= _perPage,
        loadingMore: false,
      ));
    } on RemoteExceptions catch (e) {
      _onLoadError(e.errorMsg);
    } catch (_) {
      _onLoadError(ErrorCode.UNKNOWN.getLocalizedMessage());
    }
  }

  void _onLoadError(String message) {
    if (isClosed) return;
    // فشل تحديث صامت مع وجود بيانات سابقة: نُبقي ما هو معروض.
    if (state.albums.isNotEmpty) return;
    emit(state.copyWith(status: GalleryStatus.failure, message: message));
  }

  /// يحمّل الصفحة التالية. فشله صامت، وتُعاد المحاولة عند التمرير التالي.
  Future<void> loadMore() async {
    if (state.status != GalleryStatus.ready ||
        !state.hasMore ||
        state.loadingMore) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    try {
      final more = await _repository.getGalleries(page: next, perPage: _perPage);
      if (isClosed) return;
      emit(state.copyWith(
        albums: [...state.albums, ...more],
        page: next,
        hasMore: more.length >= _perPage,
        loadingMore: false,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(loadingMore: false));
    }
  }
}
