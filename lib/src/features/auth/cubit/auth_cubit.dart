import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_state.dart';
import 'package:sm_ai_support/src/features/auth/data/auth_repo.dart';

/// Global instance to access AuthCubit
AuthCubit get authCubit => sl<AuthCubit>();

/// Authentication Cubit that manages all authentication-related state and operations
/// This cubit handles OTP sending, verification, user authentication, and logout functionality
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  //! Initialization -----------------------------------

  /// Initialize authentication state with stored data
  /// Checks for existing authentication data in persistent storage and restores it
  /// This method should be called when the app starts to restore user session
  // Future<void> initializeAuth() async {
  //   smPrint('Initializing authentication...');
  //   await AuthManager.init();

  //   if (AuthManager.isAuthenticated && AuthManager.hasValidAuthData) {
  //     // Load stored auth data into state
  //     emit(state.copyWith(authToken: AuthManager.authToken, currentCustomer: AuthManager.currentCustomer));
  //     smPrint('Authentication restored from storage for user: ${AuthManager.currentCustomer?.id}');
  //     smPrint('Auth Token: ${AuthManager.authToken}');
  //   } else {
  //     // Clear any partial auth data
  //     await AuthManager.logout();
  //     smPrint('No valid authentication found, cleared storage');
  //   }
  // }

  //! Registration Methods -----------------------------------

  /// Reset authentication state and initialize registration
  /// Clears all auth data and sets up initial registration body
  void reset() {
    smPrint('Resetting authentication state for registration');
    emit(
      state.copyWith(
        registrationBody: const UserModel(countryCode: '+966'), // Set default country code
        currentRegistrationStep: 0,
        registerStatus: BaseStatus.initial,
        sendOtpStatus: BaseStatus.initial,
        verifyOtpStatus: BaseStatus.initial,
        tempToken: null,
        isResetTempToken: true,
        phoneNumber: null,
        isResetPhoneNumber: true,
      ),
    );
  }

  /// Navigate to registration step 1
  void toRegistrationStep1() {
    smPrint('Navigating to registration step 1');
    emit(state.copyWith(currentRegistrationStep: 0));
  }

  /// Update registration body
  void updateRegistrationBody(UserModel registrationBody) {
    smPrint('Updating registration body');
    emit(state.copyWith(registrationBody: registrationBody));
  }

  /// Register new customer
  /// Sends OTP with name parameter for registration
  /// [sessionId] - Optional session ID to link with existing session
  ///
  /// On success: Updates state with temp token and proceeds to OTP verification
  /// On error: Shows error message and updates status to failure
  Future<void> register({String? sessionId}) async {
    final registrationBody = state.registrationBody;

    if (registrationBody == null) {
      smPrint('Register Error: Registration body is null');
      primarySnackBar(smNavigatorKey.currentContext!, message: 'Registration data is missing');
      return;
    }

    smPrint('Registering user: ${registrationBody.fullName} - ${registrationBody.fullPhoneNumber}');
    emit(state.copyWith(registerStatus: BaseStatus.loading));

    try {
      // Use sendOtp with name parameter for registration
      final result = await sl<AuthRepo>().sendOtp(
        phone: registrationBody.fullPhoneNumber,
        name: registrationBody.fullName,
      );

      result.when(
        success: (data) {
          smPrint('Register Success - Temp token received');
          emit(
            state.copyWith(
              registerStatus: BaseStatus.success,
              tempToken: data.token,
              phoneNumber: registrationBody.fullPhoneNumber,
              sessionId: sessionId,
            ),
          );
        },
        error: (error) {
          smPrint('Register Error: ${error.failure.error}');
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(registerStatus: BaseStatus.failure, errorMessage: error.failure.error));
        },
      );
    } catch (e) {
      smPrint('Register Exception: $e');
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(registerStatus: BaseStatus.failure, errorMessage: e.toString()));
    }
  }

  //! Auto-login Methods -----------------------------------

  /// Auto-login with customer data
  /// Automatically authenticates the user without OTP flow
  /// [customer] - Customer data containing phone and name
  ///
  /// On success:
  /// - Saves authentication data to persistent storage
  /// - Assigns any anonymous sessions to the authenticated user
  /// - Updates state with auth token and customer data
  /// On error: Shows error message and updates status to failure
  Future<void> autoLogin({required CustomerData customer}) async {
    smPrint('Auto-login for: ${customer.name} - ${customer.fullPhoneNumber}');
    emit(state.copyWith(verifyOtpStatus: BaseStatus.loading));

    try {
      final result = await sl<AuthRepo>().autoLogin(customer: customer);

      result.when(
        success: (data) async {
          smPrint('Auto Login Success - User authenticated: ${data.result.customer.id}');

          // Save authentication data to persistent storage
          await AuthManager.saveAuthData(token: data.result.token, customer: data.result.customer);

          // Check if there are anonymous session IDs to assign
          final List<String> anonymousSessionIds = SharedPrefHelper.getAnonymousSessionIds();
          if (anonymousSessionIds.isNotEmpty) {
            smPrint('Found ${anonymousSessionIds.length} anonymous sessions to assign');

            // Assign anonymous sessions to the authenticated user
            await _assignAnonymousSessionsToUser(anonymousSessionIds);

            // Clear the stored anonymous session IDs and category mappings after assignment
            await SharedPrefHelper.clearAnonymousSessionCategoryMap();
            smPrint('Cleared anonymous session IDs and category mappings from storage');
          }

          emit(
            state.copyWith(
              verifyOtpStatus: BaseStatus.success,
              currentCustomer: data.result.customer,
              tempToken: null,
              isResetTempToken: true,
            ),
          );
        },
        error: (error) {
          smPrint('Auto Login Error: ${error.failure.error}');
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(verifyOtpStatus: BaseStatus.failure, errorMessage: error.failure.error));
        },
      );
    } catch (e) {
      smPrint('Auto Login Exception: $e');
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(verifyOtpStatus: BaseStatus.failure, errorMessage: e.toString()));
    }
  }

  //! Authentication API Methods -----------------------------------

  /// Send OTP to phone number
  /// Initiates the authentication process by sending a verification code to the provided phone number
  /// [phone] - The phone number without country code
  /// [countryCode] - The country code (e.g., +966)
  ///
  /// On success: Updates state with temp token and phone number
  /// On error: Shows error message and updates status to failure
  Future<void> sendOtp({required String phone, required String countryCode, String? sessionId}) async {
    // Format phone number with country code
    if (phone.startsWith("0")) {
      phone = phone.substring(1);
    }
    final fullPhoneNumber = '$countryCode$phone';
    smPrint('Sending OTP to: $fullPhoneNumber');
    emit(state.copyWith(sendOtpStatus: BaseStatus.loading));

    try {
      final result = await sl<AuthRepo>().sendOtp(phone: fullPhoneNumber);

      result.when(
        success: (data) {
          smPrint('Send OTP Success - Temp token received');
          emit(
            state.copyWith(
              sendOtpStatus: BaseStatus.success,
              tempToken: data.token,
              phoneNumber: fullPhoneNumber,
              sessionId: sessionId,
            ),
          );
        },
        error: (error) {
          smPrint('Send OTP Error: ${error.failure.error}');

          // Check if error is about customer needing to register
          String errorMessage = error.failure.error;
          // Check both errorCode and error message for the error code
          if (error.failure.errorCode == 'IN_APP_CUSTOMER_NEED_REGISTER' ||
              errorMessage.contains('IN_APP_CUSTOMER_NEED_REGISTER')) {
            errorMessage = SMText.thisNumberDoesNotExistPleaseRegisterFirst;
          }

          primarySnackBar(smNavigatorKey.currentContext!, message: errorMessage);
          emit(state.copyWith(sendOtpStatus: BaseStatus.failure, errorMessage: errorMessage));
        },
      );
    } catch (e) {
      smPrint('Send OTP Exception: $e');
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(sendOtpStatus: BaseStatus.failure, errorMessage: e.toString()));
    }
  }

  /// Verify OTP code and complete authentication
  /// Verifies the OTP code and authenticates the user
  /// [phone] - The phone number that received the OTP
  /// [otp] - The verification code entered by the user
  /// [sessionId] - Optional session ID to link with existing session
  ///
  /// On success:
  /// - Saves authentication data to persistent storage
  /// - Assigns any anonymous sessions to the authenticated user
  /// - Updates state with auth token and customer data
  /// On error: Shows error message and updates status to failure
  Future<void> verifyOtp({required String otp, String? sessionId}) async {
    smPrint('Verifying OTP for: ${state.phoneNumber}');
    emit(state.copyWith(verifyOtpStatus: BaseStatus.loading));

    try {
      // Use the provided sessionId or fall back to the one stored in state
      final actualSessionId = sessionId ?? state.sessionId;

      final result = await sl<AuthRepo>().verifyOtp(
        phone: state.phoneNumber!,
        otp: otp,
        sessionId: actualSessionId,
        tempToken: state.tempToken!,
      );

      result.when(
        success: (data) async {
          smPrint('Verify OTP Success - User authenticated: ${data.result.customer.id}');

          // Save authentication data to persistent storage
          await AuthManager.saveAuthData(token: data.result.token, customer: data.result.customer);

          // Check if there are anonymous session IDs to assign
          final List<String> anonymousSessionIds = SharedPrefHelper.getAnonymousSessionIds();
          if (anonymousSessionIds.isNotEmpty) {
            smPrint('Found ${anonymousSessionIds.length} anonymous sessions to assign');

            // Assign anonymous sessions to the authenticated user
            await _assignAnonymousSessionsToUser(anonymousSessionIds);

            // Clear the stored anonymous session IDs and category mappings after assignment
            await SharedPrefHelper.clearAnonymousSessionCategoryMap();
            smPrint('Cleared anonymous session IDs and category mappings from storage');
          }

          emit(
            state.copyWith(
              verifyOtpStatus: BaseStatus.success,
              // authToken: data.result.token,
              currentCustomer: data.result.customer,
              tempToken: null,
              isResetTempToken: true,
            ),
          );
        },
        error: (error) {
          smPrint('Verify OTP Error: ${error.failure.error}');

          // Check if the error is "customer needs to register"
          String errorMessage = error.failure.error;
          // Check both errorCode and error message for the error code
          if (error.failure.errorCode == 'IN_APP_CUSTOMER_NEED_REGISTER' ||
              errorMessage.contains('IN_APP_CUSTOMER_NEED_REGISTER')) {
            errorMessage = SMText.thisNumberDoesNotExistPleaseRegisterFirst;
          }

          primarySnackBar(smNavigatorKey.currentContext!, message: errorMessage);
          emit(state.copyWith(verifyOtpStatus: BaseStatus.failure, errorMessage: errorMessage));
        },
      );
    } catch (e) {
      smPrint('Verify OTP Exception: $e');
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(verifyOtpStatus: BaseStatus.failure, errorMessage: e.toString()));
    }
  }

  //! Session Management -----------------------------------

  /// Clear authentication data and log out user
  /// Removes all authentication data from both state and persistent storage
  /// This method ensures complete cleanup of user session
  Future<void> logout() async {
    smPrint('Logging out user...');
    emit(state.copyWith(logoutStatus: BaseStatus.loading));

    try {
      // Clear persistent storage
      await AuthManager.logout();

      // Clear state
      emit(
        state.copyWith(
          logoutStatus: BaseStatus.success,
          // authToken: null,
          isResetAuthToken: true,
          currentCustomer: null,
          isResetCurrentCustomer: true,
          tempToken: null,
          isResetTempToken: true,
          phoneNumber: null,
          isResetPhoneNumber: true,
          sessionId: null,
          isResetSessionId: true,
        ),
      );

      smPrint('User logged out successfully');
    } catch (e) {
      smPrint('Logout Exception: $e');
      emit(state.copyWith(logoutStatus: BaseStatus.failure));
    }
  }

  /// Clear authentication data (deprecated - use logout instead)
  @Deprecated('Use logout() instead')
  void clearAuth() {
    logout();
  }

  //! State Management Helpers -----------------------------------

  /// Sync registration data from local cubit instance to global instance
  /// Used when transitioning from registration to OTP verification
  void syncRegistrationData({
    required String? phoneNumber,
    required String? tempToken,
    String? sessionId,
  }) {
    emit(state.copyWith(
      phoneNumber: phoneNumber,
      tempToken: tempToken,
      sessionId: sessionId,
    ));
  }

  /// Reset OTP sending status
  /// Resets the send OTP status to initial state
  void resetSendOtpStatus() {
    emit(state.copyWith(sendOtpStatus: BaseStatus.initial));
  }

  /// Reset OTP verification status
  /// Resets the verify OTP status to initial state
  void resetVerifyOtpStatus() {
    emit(state.copyWith(verifyOtpStatus: BaseStatus.initial));
  }

  /// Reset logout status
  /// Resets the logout status to initial state
  void resetLogoutStatus() {
    emit(state.copyWith(logoutStatus: BaseStatus.initial));
  }

  /// Reset all authentication statuses
  /// Resets all operation statuses to initial state
  void resetAllStatuses() {
    emit(
      state.copyWith(
        sendOtpStatus: BaseStatus.initial,
        verifyOtpStatus: BaseStatus.initial,
        logoutStatus: BaseStatus.initial,
      ),
    );
  }

  //! Private Helper Methods -----------------------------------

  /// Assign anonymous sessions to the authenticated user
  /// This is called internally after successful OTP verification
  /// [sessionIds] - List of anonymous session IDs to assign
  Future<void> _assignAnonymousSessionsToUser(List<String> sessionIds) async {
    try {
      smPrint('Assigning ${sessionIds.length} anonymous sessions to authenticated user');
      final result = await sl<SupportRepo>().assignAnonymousSession(sessionIds: sessionIds);

      result.when(
        success: (data) {
          smPrint('Successfully assigned anonymous sessions to user');
        },
        error: (error) {
          smPrint('Failed to assign anonymous sessions: ${error.failure.error}');
          // Don't throw error here as it's not critical to the auth flow
        },
      );
    } catch (e) {
      smPrint('Exception while assigning anonymous sessions: $e');
      // Don't throw error here as it's not critical to the auth flow
    }
  }
}
