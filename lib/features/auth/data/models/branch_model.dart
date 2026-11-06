/// Model that holds the branch data parsed from the API.
class BranchModel {
  const BranchModel({required this.id, required this.name});

  final int id;
  final String name;

  /// Builds the object from the API json.
  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      BranchModel(id: json['id'] as int, name: json['name'] as String);
}
