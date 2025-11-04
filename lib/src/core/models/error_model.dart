import 'package:equatable/equatable.dart';

class ApiErrorModel extends Equatable {
  final int code;
  final String error;
  final Map<String, List<String?>> errors;
  final String? errorCode; // To store error codes like "IN_APP_CUSTOMER_NEED_REGISTER"

  const ApiErrorModel({
    this.code = 500,
    this.error = 'Something went wrong',
    this.errors = const {},
    this.errorCode,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    // Handle nested error structure from the API:
    // {
    //   "error": {
    //     "message": [{"field": "server", "message": "ERROR_CODE"}],
    //     "statusCode": 403,
    //     "values": []
    //   }
    // }
    if (json.containsKey('error') && json['error'] is Map) {
      final errorData = json['error'] as Map<String, dynamic>;
      final statusCode = errorData['statusCode'] ?? 500;

      // Extract error message and code from the message array
      String errorMessage = 'Something went wrong';
      String? errorCodeValue;

      if (errorData.containsKey('message') && errorData['message'] is List) {
        final messageList = errorData['message'] as List;
        if (messageList.isNotEmpty && messageList.first is Map) {
          final firstMessage = messageList.first as Map<String, dynamic>;
          // The "message" field contains the error code
          errorCodeValue = firstMessage['message']?.toString();
          errorMessage = errorCodeValue ?? errorMessage;
        }
      }

      return ApiErrorModel(
        code: statusCode,
        error: errorMessage,
        errorCode: errorCodeValue,
        errors: const {},
      );
    }

    // Handle simple/legacy structure: {code: 500, error: "...", errors: {...}}
    return ApiErrorModel(
      code: json['code'] ?? 500,
      error: json['error'] ?? 'Something went wrong',
      errors: json['errors'] ?? const {},
      errorCode: json['errorCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'errors': errors,
      if (errorCode != null) 'errorCode': errorCode,
    };
  }

  @override
  List<Object?> get props => [code, error, errors, errorCode];
}
