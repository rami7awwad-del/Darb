class NewsModel {
  const NewsModel({required this.id, required this.link, required this.image});

  final int id;
  final String link;
  final String image;

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        id: json['id'] as int,
        link: json['link'] as String? ?? '',
        image: json['image'] as String? ?? '',
      );
}
