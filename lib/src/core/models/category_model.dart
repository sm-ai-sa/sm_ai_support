import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String? description;
  final String? name;
  final String icon;

  const CategoryModel({required this.id, required this.description, required this.name, required this.icon});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      description: json['description'],
      name: json['name'],
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'description': description, 'icon': icon};
  }

  @override
  List<Object?> get props => [id, description, icon];

  String get categoryName => description ?? name ?? '';
}

class CategoriesResponse extends Equatable {
  final List<CategoryModel> result;
  final int statusCode;

  const CategoriesResponse({required this.result, required this.statusCode});

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      result: (json['result'] as List)
          .map((category) => CategoryModel.fromJson(category as Map<String, dynamic>))
          .toList(),
      statusCode: json['statusCode'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'result': result.map((category) => category.toJson()).toList(), 'statusCode': statusCode};
  }

  @override
  List<Object?> get props => [result, statusCode];
}
