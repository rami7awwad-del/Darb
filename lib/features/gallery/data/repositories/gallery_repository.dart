import 'package:darb/features/gallery/data/datasources/gallery_remote_data_source.dart';
import 'package:darb/features/gallery/data/models/gallery_model.dart';

class GalleryRepository {
  GalleryRepository(this._remote);

  final GalleryRemoteDataSource _remote;

  Future<List<GalleryModel>> getGalleries({
    required int page,
    required int perPage,
  }) =>
      _remote.getGalleries(page: page, perPage: perPage);
}
