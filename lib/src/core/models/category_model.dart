import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String? description;
  final String? name;
  final String? icon;
  final IconInfo? iconInfo;


  const CategoryModel({required this.id, required this.description, required this.name, required this.icon, required this.iconInfo});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      description: json['description'],
      name: json['name'],
      icon: json['icon'] as String?,
      iconInfo: json['iconInfo'] != null ? IconInfo.fromJson(json['iconInfo'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'description': description, 'icon': icon ?? '', 'iconInfo': iconInfo?.toJson()};
  }

  @override
  List<Object?> get props => [id, description, icon, iconInfo];

  String get categoryName => description ?? name ?? '';

  String get categoryIcon => icon ?? iconInfo?.name ?? '';
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

class IconInfo extends Equatable {
  final String name;

  const IconInfo({required this.name});

  factory IconInfo.fromJson(Map<String, dynamic> json) {
    return IconInfo(name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  @override
  List<Object?> get props => [name];
}
