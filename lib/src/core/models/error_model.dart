import 'package:equatable/equatable.dart';

class ApiErrorModel extends Equatable {
  final int code;
  final String error;
  final Map<String, List<String?>> errors;

  const ApiErrorModel({this.code = 500, this.error = 'Something went wrong', this.errors = const {}});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      code: json['code'] ?? 500,
      error: json['error'] ?? 'Something went wrong',
      errors: json['errors'] ?? const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'error': error, 'errors': errors};
  }

  @override
  List<Object?> get props => [code, error, errors];
}
