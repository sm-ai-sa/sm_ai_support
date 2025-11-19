import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/network/error/error_handler.dart';
import 'package:sm_ai_support/src/core/network/network_services.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

/// Repository class that handles authentication-related API calls
/// This class encapsulates all authentication methods including OTP sending and verification
class AuthRepo {
  //! Authentication API Methods -----------------------------------

  /// Send OTP to phone number
  /// Sends a verification code to the provided phone number
  /// [phone] - The phone number to send OTP to (with country code)
  /// [name] - Optional name parameter for registration flow
  ///
  /// Returns [NetworkResult<SendOtpResponse>] containing:
  /// - Success: SendOtpResponse with temporary token
  /// - Error: ErrorModel with failure details
  Future<NetworkResult<SendOtpResponse>> sendOtp({required String phone, String? name}) async {
    try {
      final response = await networkServices.sendOtp(phone: phone, name: name);

      if (response.statusCode?.isSuccess ?? false) {
        final otpResponse = SendOtpResponse.fromJson(response.data);
        smPrint('Send OTP Response: Success - Token received for $phone');
        return Success(otpResponse);
      } else {
        smPrint('Send OTP Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Send OTP Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Verify OTP code
  /// Verifies the OTP code and authenticates the user
  /// [phone] - The phone number the OTP was sent to
  /// [otp] - The OTP code to verify
  /// [sessionId] - Optional session ID to link with existing session
  ///
  /// Returns [NetworkResult<VerifyOtpResponse>] containing:
  /// - Success: VerifyOtpResponse with authentication token and customer data
  /// - Error: ErrorModel with failure details
  Future<NetworkResult<VerifyOtpResponse>> verifyOtp({
    required String phone,
    required String otp,
    required String tempToken,
    String? sessionId,
  }) async {
    try {
      final response =
          await networkServices.verifyOtp(phone: phone, otp: otp, sessionId: sessionId, tempToken: tempToken);

      if (response.statusCode?.isSuccess ?? false) {
        final verifyResponse = VerifyOtpResponse.fromJson(response.data);

        return Success(verifyResponse);
      } else {
        smPrint('Verify OTP Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Verify OTP Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Auto-login with customer data
  /// Automatically authenticates the user without OTP flow
  /// [customer] - Customer data containing phone and name
  ///
  /// Returns [NetworkResult<VerifyOtpResponse>] containing:
  /// - Success: VerifyOtpResponse with authentication token and customer data
  /// - Error: ErrorModel with failure details
  Future<NetworkResult<VerifyOtpResponse>> autoLogin({required CustomerData customer}) async {
    try {
      final response = await networkServices.autoLogin(customer: customer);

      if (response.statusCode?.isSuccess ?? false) {
        final loginResponse = VerifyOtpResponse.fromJson(response.data);

        return Success(loginResponse);
      } else {
        smPrint('Auto Login Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Auto Login Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }
}
