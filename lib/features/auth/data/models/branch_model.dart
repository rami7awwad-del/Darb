/// عنصر من branches/all.
class BranchModel {
  const BranchModel({required this.id, required this.name});

  final int id;
  final String name;

  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      BranchModel(id: json['id'] as int, name: json['name'] as String);
}
