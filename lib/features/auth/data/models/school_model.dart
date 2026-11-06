/// Model that holds the school data parsed from the API.
class SchoolModel {
  const SchoolModel({required this.id, required this.name});

  final int id;
  final String name;

  /// Builds the object from the API json.
  factory SchoolModel.fromJson(Map<String, dynamic> json) =>
      SchoolModel(id: json['id'] as int, name: json['name'] as String);
}
