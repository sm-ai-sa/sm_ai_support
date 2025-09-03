# Authentication Feature Documentation

## Overview

The Authentication feature handles all user authentication operations in the SM AI Support package. This feature has been refactored to separate authentication concerns from the support functionality, providing better code organization and maintainability.

## Architecture

The authentication feature follows a clean architecture pattern with the following components:

### 1. Data Layer (`lib/src/features/auth/data/`)
- **AuthRepo**: Repository class that handles authentication-related API calls
- Encapsulates all authentication methods including OTP sending and verification
- Provides a clean interface between the business logic and network services

### 2. Business Logic Layer (`lib/src/features/auth/cubit/`)
- **AuthCubit**: Manages all authentication-related state and operations
- **AuthState**: Immutable state class that holds authentication data and status
- Handles OTP flow, user authentication, session management, and logout functionality

### 3. Presentation Layer (`lib/src/features/auth/views/`)
- **LoginByPhone**: UI widget for phone-based authentication (existing)
- Contains authentication-related UI components

## Key Components

### AuthRepo

The `AuthRepo` class provides the following methods:

#### `sendOtp({required String phone})`
- Sends OTP to the provided phone number
- Returns `NetworkResult<SendOtpResponse>` with temporary token
- Phone number should include country code

#### `verifyOtp({required String phone, required String otp, String? sessionId})`
- Verifies the OTP code and authenticates the user
- Returns `NetworkResult<VerifyOtpResponse>` with auth token and customer data
- Optional sessionId parameter for linking with existing sessions

### AuthCubit

The `AuthCubit` class manages authentication state and provides the following methods:

#### Initialization
- `initializeAuth()`: Restores authentication state from persistent storage on app start

#### Authentication Operations
- `sendOtp({required String phone})`: Initiates OTP sending process
- `verifyOtp({required String phone, required String otp, String? sessionId})`: Verifies OTP and completes authentication
- `logout()`: Clears authentication data and logs out user

#### State Management
- `resetSendOtpStatus()`: Resets OTP sending status
- `resetVerifyOtpStatus()`: Resets OTP verification status
- `resetLogoutStatus()`: Resets logout status
- `resetAllStatuses()`: Resets all operation statuses

### AuthState

The `AuthState` class contains:

#### Authentication Properties
- `authToken`: Current authentication token
- `currentCustomer`: Customer information
- `tempToken`: Temporary token from OTP sending
- `phoneNumber`: Phone number used for authentication

#### Status Properties
- `sendOtpStatus`: Status of OTP sending operation
- `verifyOtpStatus`: Status of OTP verification operation
- `logoutStatus`: Status of logout operation

#### Computed Properties
- `isAuthenticated`: Boolean indicating if user is authenticated
- `isVerifyingOtp`: Boolean indicating if OTP verification is in progress
- `isSendingOtp`: Boolean indicating if OTP sending is in progress
- `isLoggingOut`: Boolean indicating if logout is in progress
- `isLoading`: Boolean indicating if any auth operation is in progress

## Dependency Injection

The authentication feature is properly integrated with the dependency injection system:

### Repository Registration (`repo_injector.dart`)
```dart
if (!instance.isRegistered<AuthRepo>()) {
  instance.registerLazySingleton(() => AuthRepo());
}
```

### Cubit Registration (`bloc_injector.dart`)
```dart
if (!instance.isRegistered<AuthCubit>()) {
  instance.registerLazySingleton(() => AuthCubit());
}
```

## Global Access

The authentication cubit can be accessed globally using:
```dart
AuthCubit get authCubit => sl<AuthCubit>();
```

## Usage Examples

### Initialize Authentication
```dart
await authCubit.initializeAuth();
```

### Send OTP
```dart
await authCubit.sendOtp(phone: "+1234567890");
```

### Verify OTP
```dart
await authCubit.verifyOtp(
  phone: "+1234567890",
  otp: "123456",
  sessionId: "optional-session-id",
);
```

### Logout
```dart
await authCubit.logout();
```

### Listen to Authentication State
```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state.isAuthenticated) {
      return AuthenticatedWidget();
    } else if (state.isSendingOtp) {
      return LoadingWidget();
    } else {
      return LoginWidget();
    }
  },
)
```

## Integration with Support Features

The authentication feature seamlessly integrates with support features:

1. **Anonymous Session Assignment**: After successful OTP verification, any existing anonymous sessions are automatically assigned to the authenticated user
2. **Persistent Storage**: Authentication data is stored securely using `AuthManager`
3. **Automatic Token Management**: The DioFactory interceptor automatically adds auth tokens to API requests

## Error Handling

The authentication feature provides comprehensive error handling:

- Network errors are handled gracefully with user-friendly messages
- Failed operations update the state with appropriate error status
- Errors are displayed using `primarySnackBar` for consistent UI feedback
- Non-critical operations (like anonymous session assignment) don't interrupt the auth flow

## Security Considerations

1. **Token Storage**: Authentication tokens are stored securely using `AuthManager`
2. **Session Management**: Proper cleanup of authentication data on logout
3. **Validation**: Phone number and OTP validation before API calls
4. **Error Logging**: Detailed logging for debugging while maintaining security

## Migration Notes

When migrating from the old authentication system:

1. Replace `smCubit.sendOtp()` with `authCubit.sendOtp()`
2. Replace `smCubit.verifyOtp()` with `authCubit.verifyOtp()`
3. Replace `smCubit.logout()` with `authCubit.logout()`
4. Update state listeners to use `AuthState` instead of `SMSupportState`
5. Initialize auth cubit separately: `await authCubit.initializeAuth()`

## Future Enhancements

Potential future improvements:

1. **Biometric Authentication**: Add fingerprint/face ID support
2. **Social Login**: Integrate with social media authentication
3. **Multi-factor Authentication**: Add additional security layers
4. **Password Authentication**: Add traditional email/password login
5. **Session Refresh**: Automatic token refresh mechanism

## Testing

The authentication feature should be tested with:

1. **Unit Tests**: Test all cubit methods and state transitions
2. **Integration Tests**: Test API integration and error scenarios
3. **Widget Tests**: Test UI components and user interactions
4. **End-to-End Tests**: Test complete authentication flows

## Troubleshooting

Common issues and solutions:

1. **OTP Not Received**: Check phone number format and network connectivity
2. **Invalid OTP**: Verify OTP code and check expiration
3. **Session Assignment Failure**: Check network connection and user permissions
4. **State Not Updating**: Ensure proper BlocBuilder usage and state listening

For more technical details, refer to the individual code files and their documentation comments.
