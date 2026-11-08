/// Model that holds the gallery data parsed from the API.
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

  String? get cover => images.isEmpty ? null : images.first;

  static String? _imageUrl(dynamic e) {
    if (e is String) return e;
    if (e is Map<String, dynamic>) {
      return (e['url'] ?? e['image'] ?? e['path'])?.toString();
    }
    return null;
  }

  /// Builds the object from the API json.
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
