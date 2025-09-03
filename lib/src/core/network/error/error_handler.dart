// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/models/error_model.dart';
import 'package:sm_ai_support/src/core/network/error/error_strings.dart';

class ErrorHandler implements Exception {
  late ApiErrorModel failure;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      _handleDioError(error);
    } else if (error is SocketException) {
      _handleSocketError(error);
    } else if (error is FormatException) {
      _handleFormatError(error);
    } else if (error is TypeError) {
      _handleTypeError(error);
    } else {
      _handleGenericError(error);
    }
  }

  /// Handle Dio-specific errors
  void _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        failure = ApiErrorModel(
          code: 408,
          error: ErrorStrings.timeoutError,
        );
        break;
      case DioExceptionType.sendTimeout:
        failure = ApiErrorModel(
          code: 408,
          error: ErrorStrings.timeoutError,
        );
        break;
      case DioExceptionType.receiveTimeout:
        failure = ApiErrorModel(
          code: 408,
          error: ErrorStrings.timeoutError,
        );
        break;
      case DioExceptionType.badResponse:
        _handleBadResponse(error);
        break;
      case DioExceptionType.cancel:
        failure = ApiErrorModel(
          code: 499,
          error: 'Request was cancelled',
        );
        break;
      case DioExceptionType.connectionError:
        failure = ApiErrorModel(
          code: 503,
          error: ErrorStrings.noInternetError,
        );
        break;
      case DioExceptionType.badCertificate:
        failure = ApiErrorModel(
          code: 495,
          error: 'SSL certificate error',
        );
        break;
      case DioExceptionType.unknown:
        failure = ApiErrorModel(
          code: 500,
          error: ErrorStrings.unknownError,
        );
        break;
    }
  }

  /// Handle bad response errors (4xx, 5xx)
  void _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode ?? 500;
    
    switch (statusCode) {
      case 400:
        failure = _parseErrorResponse(error.response, ErrorStrings.badRequestError, 400);
        break;
      case 401:
        failure = _parseErrorResponse(error.response, ErrorStrings.unauthorizedError, 401);
        break;
      case 403:
        failure = _parseErrorResponse(error.response, ErrorStrings.forbiddenError, 403);
        break;
      case 404:
        failure = _parseErrorResponse(error.response, ErrorStrings.notFoundError, 404);
        break;
      case 409:
        failure = _parseErrorResponse(error.response, ErrorStrings.conflictError, 409);
        break;
      case 422:
        failure = _parseErrorResponse(error.response, 'Validation error', 422);
        break;
      case 429:
        failure = _parseErrorResponse(error.response, ErrorStrings.tooManyRequests, 429);
        break;
      case 500:
        failure = _parseErrorResponse(error.response, ErrorStrings.internalServerError, 500);
        break;
      case 502:
        failure = ApiErrorModel(code: 502, error: 'Bad Gateway');
        break;
      case 503:
        failure = ApiErrorModel(code: 503, error: 'Service Unavailable');
        break;
      case 504:
        failure = ApiErrorModel(code: 504, error: 'Gateway Timeout');
        break;
      default:
        failure = _parseErrorResponse(error.response, ErrorStrings.unknownError, statusCode);
        break;
    }
  }

  /// Parse error response from server
  ApiErrorModel _parseErrorResponse(Response? response, String fallbackMessage, int statusCode) {
    if (response?.data != null) {
      try {
        if (response!.data is Map<String, dynamic>) {
          return ApiErrorModel.fromJson(response.data);
        } else if (response.data is String) {
          return ApiErrorModel(
            code: statusCode,
            error: response.data.toString(),
          );
        }
      } catch (e) {
        // If parsing fails, use fallback
      }
    }
    
    return ApiErrorModel(
      code: statusCode,
      error: fallbackMessage,
    );
  }

  /// Handle socket/network errors
  void _handleSocketError(SocketException error) {
    failure = ApiErrorModel(
      code: 503,
      error: ErrorStrings.noInternetError,
    );
  }

  /// Handle format/parsing errors
  void _handleFormatError(FormatException error) {
    failure = ApiErrorModel(
      code: 422,
      error: 'Invalid data format: ${error.message}',
    );
  }

  /// Handle type casting errors
  void _handleTypeError(TypeError error) {
    String errorMessage = SMText.dataParsingError;
    
    // Extract more meaningful error message from TypeError
    final errorString = error.toString();
    if (errorString.contains('is not a subtype of type')) {
      errorMessage = SMText.dataParsingError;
    } else if (errorString.contains('Null check operator')) {
      errorMessage = SMText.missingDataError;
    }
    
    failure = ApiErrorModel(
      code: 422,
      error: errorMessage,
    );
  }

  /// Handle generic errors
  void _handleGenericError(dynamic error) {
    String errorMessage = ErrorStrings.unknownError;
    int errorCode = 500;
    
    if (error is String) {
      errorMessage = error;
      // Check for common casting error patterns in string
      if (error.contains('is not a subtype of type')) {
        errorMessage = SMText.dataParsingError;
        errorCode = 422;
      } else if (error.contains('Null check operator')) {
        errorMessage = SMText.missingDataError;
        errorCode = 422;
      }
    } else if (error != null) {
      final errorString = error.toString();
      // Check for casting errors in any error object
      if (errorString.contains('is not a subtype of type')) {
        errorMessage = SMText.dataParsingError;
        errorCode = 422;
      } else if (errorString.contains('Null check operator')) {
        errorMessage = SMText.missingDataError;
        errorCode = 422;
      } else {
        errorMessage = errorString;
      }
    }

    failure = ApiErrorModel(
      code: errorCode,
      error: errorMessage,
    );
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage() {
    // Return localized, user-friendly error messages
    switch (failure.code) {
      case 400:
        return ErrorStrings.badRequestError;
      case 401:
        return ErrorStrings.unauthorizedError;
      case 403:
        return ErrorStrings.forbiddenError;
      case 404:
        return ErrorStrings.notFoundError;
      case 408:
        return ErrorStrings.timeoutError;
      case 409:
        return ErrorStrings.conflictError;
      case 422:
        return ErrorStrings.formatError;
      case 429:
        return ErrorStrings.tooManyRequests;
      case 500:
        return ErrorStrings.internalServerError;
      case 503:
        return ErrorStrings.noInternetError;
      default:
        return failure.error.isNotEmpty ? failure.error : ErrorStrings.defaultError;
    }
  }
}
