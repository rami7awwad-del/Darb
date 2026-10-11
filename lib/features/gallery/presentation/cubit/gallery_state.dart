part of 'gallery_cubit.dart';

enum GalleryStatus { loading, ready, failure }

class GalleryState {
  const GalleryState({
    this.status = GalleryStatus.loading,
    this.albums = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
    this.message,
  });

  final GalleryStatus status;
  final List<GalleryModel> albums;

  /// آخر صفحة تم تحميلها.
  final int page;

  /// false عندما تعيد الصفحة عناصر أقل من perPage.
  final bool hasMore;
  final bool loadingMore;
  final String? message;

  GalleryState copyWith({
    GalleryStatus? status,
    List<GalleryModel>? albums,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? message,
  }) =>
      GalleryState(
        status: status ?? this.status,
        albums: albums ?? this.albums,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
        message: message,
      );
}
