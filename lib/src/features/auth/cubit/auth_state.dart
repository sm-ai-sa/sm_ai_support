import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/src/core/models/auth_model.dart';
import 'package:sm_ai_support/src/core/utils/enums.dart';

/// Authentication state that manages all auth-related UI states
/// This class handles the state for OTP sending, verification, and user authentication
class AuthState extends Equatable {
  //! Authentication Properties -----------------------------------
  
  /// Current authentication token for API requests
  final String? authToken;
  final bool isResetAuthToken;
  
  /// Current authenticated customer information
  final CustomerModel? currentCustomer;
  final bool isResetCurrentCustomer;
  
  /// Temporary token received after sending OTP (used for verification)
  final String? tempToken;
  final bool isResetTempToken;
  
  /// Phone number that was used for authentication
  final String? phoneNumber;
  final bool isResetPhoneNumber;
  
  /// Session ID for linking anonymous sessions during authentication
  final String? sessionId;
  final bool isResetSessionId;
  
  //! Authentication Status Properties -----------------------------------
  
  /// Status for sending OTP request
  final BaseStatus sendOtpStatus;
  
  /// Status for verifying OTP request
  final BaseStatus verifyOtpStatus;
  
  /// Status for logout operation
  final BaseStatus logoutStatus;
  
  /// Error message for authentication operations
  final String? errorMessage;

  const AuthState({
    // Authentication Properties
    this.authToken,
    this.isResetAuthToken = false,
    this.currentCustomer,
    this.isResetCurrentCustomer = false,
    this.tempToken,
    this.isResetTempToken = false,
    this.phoneNumber,
    this.isResetPhoneNumber = false,
    this.sessionId,
    this.isResetSessionId = false,
    
    // Authentication Status Properties
    this.sendOtpStatus = BaseStatus.initial,
    this.verifyOtpStatus = BaseStatus.initial,
    this.logoutStatus = BaseStatus.initial,
    
    // Error message
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  AuthState copyWith({
    // Authentication Properties
    String? authToken,
    bool? isResetAuthToken,
    CustomerModel? currentCustomer,
    bool? isResetCurrentCustomer,
    String? tempToken,
    bool? isResetTempToken,
    String? phoneNumber,
    bool? isResetPhoneNumber,
    String? sessionId,
    bool? isResetSessionId,
    
    // Authentication Status Properties
    BaseStatus? sendOtpStatus,
    BaseStatus? verifyOtpStatus,
    BaseStatus? logoutStatus,
    
    // Error message
    String? errorMessage,
  }) {
    return AuthState(
      // Authentication Properties
      authToken: isResetAuthToken == true ? null : authToken ?? this.authToken,
      isResetAuthToken: false,
      currentCustomer: isResetCurrentCustomer == true ? null : currentCustomer ?? this.currentCustomer,
      isResetCurrentCustomer: false,
      tempToken: isResetTempToken == true ? null : tempToken ?? this.tempToken,
      isResetTempToken: false,
      phoneNumber: isResetPhoneNumber == true ? null : phoneNumber ?? this.phoneNumber,
      isResetPhoneNumber: false,
      sessionId: isResetSessionId == true ? null : sessionId ?? this.sessionId,
      isResetSessionId: false,
      
      // Authentication Status Properties
      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      verifyOtpStatus: verifyOtpStatus ?? this.verifyOtpStatus,
      logoutStatus: logoutStatus ?? this.logoutStatus,
      
      // Error message
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  //! Computed Properties -----------------------------------
  
  /// Check if user is currently authenticated (has valid token and customer data)
  bool get isAuthenticated => authToken != null && currentCustomer != null;
  
  /// Check if OTP verification is in progress
  bool get isVerifyingOtp => verifyOtpStatus == BaseStatus.loading;
  
  /// Check if OTP sending is in progress
  bool get isSendingOtp => sendOtpStatus == BaseStatus.loading;
  
  /// Check if logout operation is in progress
  bool get isLoggingOut => logoutStatus == BaseStatus.loading;
  
  /// Check if any authentication operation is in progress
  bool get isLoading => isSendingOtp || isVerifyingOtp || isLoggingOut;

  @override
  List<Object?> get props => [
    // Authentication Properties
    authToken,
    isResetAuthToken,
    currentCustomer,
    isResetCurrentCustomer,
    tempToken,
    isResetTempToken,
    phoneNumber,
    isResetPhoneNumber,
    sessionId,
    isResetSessionId,
    
    // Authentication Status Properties
    sendOtpStatus,
    verifyOtpStatus,
    logoutStatus,
    
    // Error message
    errorMessage,
  ];

  @override
  String toString() {
    return '''AuthState(
      authToken: $authToken,
      currentCustomer: $currentCustomer,
      phoneNumber: $phoneNumber,
      sessionId: $sessionId,
      sendOtpStatus: $sendOtpStatus,
      verifyOtpStatus: $verifyOtpStatus,
      logoutStatus: $logoutStatus,
      isAuthenticated: $isAuthenticated,
    )''';
  }
}
