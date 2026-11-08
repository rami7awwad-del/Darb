import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/features/gallery/data/models/gallery_model.dart';
import 'package:darb/features/gallery/data/repositories/gallery_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State data for the gallery.
class GalleryData {
  const GalleryData({
    this.albums = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
  });

  final List<GalleryModel> albums;

  final int page;

  final bool hasMore;
  final bool loadingMore;

  /// Returns a copy with the given fields replaced.
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

/// Cubit that manages the gallery state.
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

  /// Loads the data and updates the state.
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

  /// Handles load error.
  void _onLoadError(String message) {
    if (isClosed) return;
    if (_data.albums.isNotEmpty) return;
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
