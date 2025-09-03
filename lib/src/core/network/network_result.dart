import 'package:sm_ai_support/src/core/network/error/error_handler.dart';

abstract class NetworkResult<T> {
  R when<R>({required R Function(T data) success, required R Function(ErrorHandler firebaseError) error});
}

class Success<T> extends NetworkResult<T> {
  final T data;

  Success(this.data);

  @override
  R when<R>({required R Function(T data) success, required R Function(ErrorHandler firebaseError) error}) {
    return success(data);
  }
}

class Error<T> extends NetworkResult<T> {
  final ErrorHandler firebaseError;

  Error(this.firebaseError);

  @override
  R when<R>({required R Function(T data) success, required R Function(ErrorHandler firebaseError) error}) {
    return error(firebaseError);
  }
}
