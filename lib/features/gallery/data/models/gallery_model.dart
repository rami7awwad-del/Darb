/// ألبوم من galleries/paginate: id و name و images.
/// ⚠️ شكل عنصر الصورة غير مؤكد (الاستجابات التي جُرّبت كانت images: [] فقط).
/// نقبل نصًا مباشرًا (رابط)، أو كائنًا فيه url أو image أو path.
class GalleryModel {
  const GalleryModel({
    required this.id,
    required this.name,
    this.images = const [],
  });

  final int id;
  final String name;
  final List<String> images;

  int get count => images.length;

  /// غلاف الألبوم: أول صورة (لا يوجد حقل غلاف في الـ API).
  String? get cover => images.isEmpty ? null : images.first;

  static String? _imageUrl(dynamic e) {
    if (e is String) return e;
    if (e is Map<String, dynamic>) {
      return (e['url'] ?? e['image'] ?? e['path'])?.toString();
    }
    return null;
  }

  factory GalleryModel.fromJson(Map<String, dynamic> json) => GalleryModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        images: ((json['images'] as List?) ?? const [])
            .map(_imageUrl)
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList(),
      );
}
