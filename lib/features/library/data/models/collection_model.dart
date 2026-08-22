import '../../domain/entities/collection.dart';

class CollectionModel extends Collection {
  const CollectionModel({required super.id, required super.name, required super.createdAt});

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CollectionModel.fromEntity(Collection c) =>
      CollectionModel(id: c.id, name: c.name, createdAt: c.createdAt);
}