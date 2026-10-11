import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/services/api_constants.dart';
import 'package:darb/core/services/api_service.dart';
import 'package:darb/features/gallery/data/models/gallery_model.dart';

class GalleryRemoteDataSource {
  GalleryRemoteDataSource(this._api);

  final ApiService _api;

  /// GET galleries/paginate?page=1&perPage=10 → data: قائمة ألبومات.
  /// الرد لا يحمل بيانات ترقيم (meta)، لذلك الصفحة الأخيرة تُعرف من عدد العناصر.
  Future<List<GalleryModel>> getGalleries({
    required int page,
    required int perPage,
  }) async {
    final response = await _api.getRequest(
      ApiConstants.galleriesPaginate,
      queryParameters: {'page': page, 'perPage': perPage},
    );
    try {
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as List;
      return data
          .map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw RemoteExceptions(
        ErrorCode.APP_ERROR,
        ErrorCode.APP_ERROR.getLocalizedMessage(),
        response: response,
      );
    }
  }
}
