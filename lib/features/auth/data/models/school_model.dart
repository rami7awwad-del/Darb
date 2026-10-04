/// عنصر من schools/all. TODO: حقل governorate يُضاف عند الحاجة.
class SchoolModel {
  const SchoolModel({required this.id, required this.name});

  final int id;
  final String name;

  factory SchoolModel.fromJson(Map<String, dynamic> json) =>
      SchoolModel(id: json['id'] as int, name: json['name'] as String);
}
