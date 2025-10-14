# SM AI Support Package - API Implementation Documentation

## Overview

This document provides comprehensive documentation for the new support API implementation in the SM AI Support package. The implementation includes support for both anonymous and authenticated user sessions, category management, and proper error handling following a clean architecture pattern.

## ⭐ Latest Updates

### New Anonymous User Support APIs
Based on the requirements in `instructions.txt`, the following new APIs have been implemented:

1. **Anonymous Customer Send Message** - `POST /room/anonymous-customer-send-message`
   - Allows anonymous users to send messages without authentication
   - Same request/response structure as the authenticated version
   - Automatically used for sessions created through `startAnonymousSession`

2. **Customer Read Messages** - `PUT /room/customer-read-messages` 
   - Marks messages as read when the chat page is opened
   - Works for both anonymous and authenticated users
   - Called automatically in the chat page initialization

### Implementation Details
- **SingleSessionCubit** automatically detects authentication status using `AuthManager.isAuthenticated`
- **ChatPage** initialization simplified - no need to detect anonymous sessions manually
- **SupportRepo** and **NetworkServices** include both new API methods
- Message sending automatically routes to the correct endpoint based on authentication status

## Architecture Overview

The implementation follows a **separation of concerns** architecture:

### 🏗️ **NetworkServices Layer**
- **Purpose**: Pure API communication layer
- **Responsibility**: Makes HTTP requests using Dio
- **Returns**: Raw `Response` objects
- **No validation**: Does not handle success/error validation

### 🔄 **SupportRepo Layer** 
- **Purpose**: Business logic and validation layer
- **Responsibility**: Validates responses, handles errors, transforms data
- **Returns**: `NetworkResult<T>` with proper error handling
- **Validation**: Checks status codes and parses responses

## 📁 Project Structure

### New Files Created

```
lib/src/core/models/
├── category_model.dart          # Categories API response models
└── session_model.dart           # Session API request/response models

lib/src/core/network/
└── api.dart                     # Updated with new API endpoints
```

### Modified Files

```
lib/src/core/network/
└── network_services.dart        # Added new API methods

lib/src/support/data/
└── support_repo.dart           # Added validation layer methods

lib/
└── sm_ai_support.dart          # Updated exports
```

## 🌐 API Endpoints Implemented

Based on `instructions.txt`, the following APIs have been implemented:

### 1. **Get Categories**
- **Endpoint**: `GET /preset/categories-in-app`
- **Purpose**: Fetch available support categories
- **Response**: List of categories with icons and descriptions

### 2. **Start Anonymous Session**
- **Endpoint**: `POST /in-app/start-anonymous-session`
- **Purpose**: Create new session for non-authenticated users
- **Body**: `{"categoryId": int}`

### 3. **Assign Anonymous Session**
- **Endpoint**: `POST /in-app/assign-anonymous-sessions`
- **Purpose**: Assign anonymous sessions to current user
- **Body**: `{"ids": ["session_id_1", "session_id_2"]}`

### 4. **Start Authenticated Session**
- **Endpoint**: `POST /in-app/start-session`
- **Purpose**: Create new session for authenticated users
- **Body**: `{"categoryId": int}`
- **Headers**: `Authorization: Bearer <token>` (optional)

### 5. **Send OTP**
- **Endpoint**: `POST /verification/send-in-app-code`
- **Purpose**: Send verification code to phone number
- **Body**: `{"phone": "+201094222177"}`
- **Response**: `{"result": {"token": "temp_token"}, "statusCode": 200}`

### 6. **Verify OTP**
- **Endpoint**: `POST /verification/verify-in-app-code`
- **Purpose**: Verify OTP code and authenticate user
- **Body**: `{"phone": "+201094222177", "otp": "000000", "sessionId": "optional_session_id"}`
- **Response**: `{"result": {"token": "auth_token", "customer": {...}}, "statusCode": 200}`

### 7. **Get My Sessions**
- **Endpoint**: `GET /in-app/my-sessions`
- **Purpose**: Retrieve all sessions for the authenticated user
- **Authentication**: Required (Bearer token)
- **Response**: 
```json
{
  "result": [
    {
      "id": "0198b5c4-0243-7558-ba5c-c3f78cfbcdae",
      "status": "ACTIVE",
      "createdAt": "2025-08-17T02:02:58.499Z",
      "category": {
        "id": 1,
        "name": "مشاكل المدفوعات",
        "icon": "payment"
      },
      "metadata": {
        "id": "0198b5c4-0243-7558-ba5c-c3f78cfbcdae",
        "lastMessageContent": "hello, sir",
        "unreadCount": 1
      }
    }
  ],
  "statusCode": 200
}
```

### 8. **Get My Unread Sessions**
- **Endpoint**: `GET /in-app/customer-unread-sessions`
- **Purpose**: Get count of unread sessions for the authenticated user
- **Authentication**: Required (Bearer token)
- **Response**: 
```json
{
  "result": 1,
  "statusCode": 200
}
```

### 9. **Get My Session Messages**
- **Endpoint**: `GET /in-app/my-session-messages`
- **Purpose**: Retrieve all messages for a specific session
- **Authentication**: Required (Bearer token)
- **Query Parameters**: `id` (session ID)
- **Response**:
```json
{
  "result": [
    {
      "id": "0198b745-ed6c-732a-9d9d-44acc33a2658",
      "messages": [
        {
          "id": "0198b747-1b0b-70c0-9453-7d023200560a",
          "content": "hello, sir",
          "contentType": "TEXT",
          "senderType": "CUSTOMER",
          "isRead": false,
          "isDelivered": true,
          "isFailed": false,
          "reply": {
            "message": "test",
            "messageId": "ec16baa2-6ca5-406b-8181-21aa56ccb8b3",
            "contentType": "TEXT"
          },
          "createdAt": "2025-08-17T09:05:47.277Z",
          "admin": null
        }
      ]
    }
  ],
  "statusCode": 200
}
```

### 10. **Customer Send Message**
- **Endpoint**: `POST /room/customer-send-message`
- **Purpose**: Send a message from authenticated customer to support team in a session
- **Authentication**: Required (Bearer token)
- **Body**:
```json
{
  "sessionId": "0198bdb9-52ac-73ea-99c7-893e900caffd",
  "message": "hello, sir",
  "contentType": "TEXT",
  "reply": {
    "messageId": "ec16baa2-6ca5-406b-8181-21aa56ccb8b3",
    "message": "test",
    "contentType": "TEXT"
  }
}
```
- **Note**: The `reply` field is optional and should only be included when replying to a specific message
- **Response**:
```json
{
  "result": {
    "createdAt": "2025-07-30T17:35:45.455Z",
    "updatedAt": "2025-07-30T17:35:45.456Z",
    "isRead": false,
    "isDelivered": false,
    "isFailed": false,
    "id": "01985c67-872c-73d1-b070-a4657fec2a20",
    "externalId": "01985c67-872c-73d1-b070-a4657fec2a20",
    "sessionId": "edd498a2-aae3-494b-b214-b759c4e9e111",
    "tenantId": 1,
    "content": "hello, sir",
    "contentType": "TEXT",
    "senderType": "CUSTOMER",
    "senderId": null,
    "deletedAt": null
  },
  "statusCode": 200
}
```

### 11. **Anonymous Customer Send Message**
- **Endpoint**: `POST /room/anonymous-customer-send-message`
- **Purpose**: Send a message from anonymous customer to support team in a session
- **Authentication**: Not required (for anonymous users)
- **Body**:
```json
{
  "sessionId": "0198bdde-2cca-7718-826d-e32ecd9e31eb",
  "message": "hello, sir",
  "contentType": "TEXT",
  "reply": {
    "messageId": "ec16baa2-6ca5-406b-8181-21aa56ccb8b3",
    "message": "test",
    "contentType": "TEXT"
  }
}
```
- **Note**: Same body structure as customer-send-message but for anonymous users
- **Response**: Same response structure as customer-send-message
```json
{
  "result": {
    "createdAt": "2025-07-30T17:35:45.455Z",
    "updatedAt": "2025-07-30T17:35:45.456Z",
    "isRead": false,
    "isDelivered": false,
    "isFailed": false,
    "id": "01985c67-872c-73d1-b070-a4657fec2a20",
    "externalId": "01985c67-872c-73d1-b070-a4657fec2a20",
    "sessionId": "edd498a2-aae3-494b-b214-b759c4e9e111",
    "tenantId": 1,
    "content": "hello, sir",
    "contentType": "TEXT",
    "senderType": "ADMIN",
    "senderId": null,
    "deletedAt": null
  },
  "statusCode": 200
}
```

### 12. **Customer Read Messages**
- **Endpoint**: `PUT /room/customer-read-messages`
- **Purpose**: Mark messages in a session as read by the customer
- **Authentication**: Optional (works for both anonymous and authenticated users)
- **Body**:
```json
{
  "id": "01984acd-f669-72fd-a352-8889d2d73055"
}
```
- **Response**: Dynamic response structure
- **Usage**: Called automatically when the chat page is opened to mark messages as read

## 📋 Models Documentation

### CategoryModel
```dart
class CategoryModel {
  final int id;              // Category unique identifier
  final String description;  // Category description text
  final String icon;         // Icon name (matches assets/icons/category/)
}
```

### SessionModel
```dart
class SessionModel {
  final String id;               // Unique session identifier
  final String status;           // Session status (ACTIVE, etc.)
  final String customerId;       // Customer/user identifier
  final int categoryId;          // Associated category ID
  final String viewId;           // Human-readable session ID (e.g., #C00000080)
  // ... additional session fields
}
```

### Authentication Models
```dart
class CustomerModel {
  final String id;               // Customer unique identifier
  final String? name;            // Customer name (optional)
  final String? email;           // Customer email (optional)
  final String phone;            // Customer phone number
}

class SendOtpRequest {
  final String phone;            // Phone number with country code
}

class SendOtpResponse {
  final String token;            // Temporary token for verification
  final int statusCode;          // HTTP status code
}

class VerifyOtpRequest {
  final String phone;            // Phone number with country code
  final String otp;              // OTP code to verify
  final String? sessionId;       // Optional session ID to link
}

class VerifyOtpResponse {
  final VerifyOtpResult result;  // Verification result
  final int statusCode;          // HTTP status code
}

class VerifyOtpResult {
  final String token;            // Final authentication token
  final CustomerModel customer;  // Customer information
}
```

### Request Models
```dart
class StartSessionRequest {
  final int categoryId;
}

class AssignAnonymousSessionRequest {
  final List<String> ids;
}
```

### Response Wrappers
```dart
class CategoriesResponse {
  final List<CategoryModel> result;
  final int statusCode;
}

class SessionResponse {
  final SessionModel result;
  final int statusCode;
}
```

### New Session Management Models

#### MySessionModel
```dart
class MySessionModel {
  final String id;                    // Session unique identifier
  final String status;                // Session status (ACTIVE, etc.)
  final String createdAt;             // Session creation timestamp
  final CategoryModel category;       // Associated category information
  final MySessionMetadata metadata;   // Session metadata
}

class MySessionMetadata {
  final String id;                    // Metadata identifier
  final String lastMessageContent;   // Last message preview
  final int unreadCount;              // Number of unread messages
}

class MySessionsResponse {
  final List<MySessionModel> result; // List of user sessions
  final int statusCode;               // HTTP status code
}
```

#### Session Messages Models
```dart
class SessionMessage {
  final String id;                    // Message unique identifier
  final String content;               // Message content
  final String contentType;           // Content type (TEXT, IMAGE, etc.)
  final String senderType;            // Sender type (CUSTOMER, ADMIN)
  final bool isRead;                  // Message read status
  final bool isDelivered;             // Message delivery status
  final bool isFailed;                // Message failure status
  final SessionMessageReply? reply;   // Optional reply information
  final String createdAt;             // Message creation timestamp
  final dynamic admin;                // Admin information (if applicable)
}

class SessionMessageReply {
  final String message;               // Reply message content
  final String messageId;             // Original message ID
  final String contentType;           // Reply content type
}

class SessionMessagesDoc {
  final String id;                    // Document identifier
  final List<SessionMessage> messages; // Messages in this document
}

class SessionMessagesResponse {
  final List<SessionMessagesDoc> result; // List of message documents
  final int statusCode;                   // HTTP status code
}
```

#### Unread Sessions Model
```dart
class UnreadSessionsResponse {
  final int result;         // Count of unread sessions
  final int statusCode;     // HTTP status code
}
```

## 🔧 Implementation Details

### NetworkServices Methods

All methods in `NetworkServices` are **pure API calls** with no validation:

```dart
// Raw API call - no validation
Future<Response> getCategories() async {
  return await dio.get(Apis.getCategories);
}

// Raw API call with request body
Future<Response> startAnonymousSession({required int categoryId}) async {
  final request = StartSessionRequest(categoryId: categoryId);
  return await dio.post(Apis.startAnonymousSession, data: request.toJson());
}

// Raw API call with optional auth header
Future<Response> startSession({required int categoryId, String? authToken}) async {
  final request = StartSessionRequest(categoryId: categoryId);
  final options = authToken != null 
      ? Options(headers: {'Authorization': 'Bearer $authToken'})
      : null;
  return await dio.post(Apis.startSession, data: request.toJson(), options: options);
}
```

### SupportRepo Methods

All methods in `SupportRepo` handle **validation and error handling**:

```dart
Future<NetworkResult<CategoriesResponse>> getCategories() async {
  try {
    final response = await networkServices.getCategories();
    
    if (response.statusCode == 200) {
      final categoriesResponse = CategoriesResponse.fromJson(response.data);
      smPrint('Fetch Categories Response: Success - ${categoriesResponse.result.length} categories');
      return Success(categoriesResponse);
    } else {
      smPrint('Fetch Categories Error: ${response.statusCode}');
      return Error(ErrorHandler.handle(response));
    }
  } catch (e) {
    smPrint('Fetch Categories Error: $e');
    return Error(ErrorHandler.handle(e));
  }
}
```

## 📱 Usage Examples

### 1. Fetching Categories
```dart
final supportRepo = SupportRepo();
final result = await supportRepo.getCategories();

result.when(
  success: (categoriesResponse) {
    final categories = categoriesResponse.result;
    // Display categories in UI
    for (final category in categories) {
      print('${category.description} - Icon: ${category.icon}');
    }
  },
  error: (errorHandler) {
    // Handle error
    print('Error: ${errorHandler.message}');
  },
);
```

### 2. Starting Anonymous Session
```dart
final supportRepo = SupportRepo();
final result = await supportRepo.startAnonymousSession(categoryId: 1);

result.when(
  success: (sessionResponse) {
    final session = sessionResponse.result;
    print('Session created: ${session.viewId}');
    // Navigate to chat page with session.id
  },
  error: (errorHandler) {
    // Handle error
    print('Failed to create session: ${errorHandler.message}');
  },
);
```

### 3. Starting Authenticated Session
```dart
final supportRepo = SupportRepo();
final result = await supportRepo.startSession(
  categoryId: 2,
  authToken: 'your_auth_token_here', // Optional
);

result.when(
  success: (sessionResponse) {
    final session = sessionResponse.result;
    print('Authenticated session: ${session.viewId}');
  },
  error: (errorHandler) {
    // Handle authentication or other errors
  },
);
```

### 4. Assigning Anonymous Sessions
```dart
final supportRepo = SupportRepo();
final result = await supportRepo.assignAnonymousSession(
  sessionIds: ['session_id_1', 'session_id_2'],
);

result.when(
  success: (data) {
    print('Sessions assigned successfully');
  },
  error: (errorHandler) {
    print('Assignment failed: ${errorHandler.message}');
  },
);
```

### 5. Send OTP for Authentication
```dart
final supportRepo = SupportRepo();
final result = await supportRepo.sendOtp(phone: '+201094222177');

result.when(
  success: (otpResponse) {
    final tempToken = otpResponse.token;
    print('OTP sent successfully. Temp token: $tempToken');
    // Store temp token for verification step
  },
  error: (errorHandler) {
    print('Failed to send OTP: ${errorHandler.message}');
  },
);
```

### 6. Verify OTP and Authenticate
```dart
final supportRepo = SupportRepo();
final result = await supportRepo.verifyOtp(
  phone: '+201094222177',
  otp: '000000',
  sessionId: 'optional_session_id', // Link to existing anonymous session
);

result.when(
  success: (verifyResponse) {
    final authToken = verifyResponse.result.token;
    final customer = verifyResponse.result.customer;
    print('Authentication successful!');
    print('Customer: ${customer.id} - ${customer.phone}');
    print('Auth token: $authToken');
    // Store auth token for future authenticated requests
  },
  error: (errorHandler) {
    print('OTP verification failed: ${errorHandler.message}');
  },
);
```

## 🚦 User Flows Supported

### Anonymous User Flow
1. **Get Categories** → Display category selection
2. **Start Anonymous Session** → Create session for selected category
3. **Begin Chat** → Use session ID for messaging
4. **Optional: Assign Session** → Link to user account later

### Authentication Flow
1. **Send OTP** → Send verification code to phone number
2. **Verify OTP** → Validate code and get authentication token
3. **Optional: Link Session** → Pass sessionId to verify OTP to link anonymous session

### Authenticated User Flow
1. **Get Categories** → Display category selection
2. **Start Session** (with auth token) → Create authenticated session
3. **Begin Chat** → Use session ID for messaging

### Full Authentication + Session Flow
1. **Get Categories** → Display category selection
2. **Send OTP** → Request verification code
3. **Verify OTP** → Authenticate user and get token
4. **Start Session** (with auth token) → Create authenticated session
5. **Begin Chat** → Use session ID for messaging

### Anonymous to Authenticated Flow
1. **Get Categories** → Display category selection
2. **Start Anonymous Session** → Create anonymous session (automatically stored locally)
3. **Begin Chat** → Start chatting anonymously using customer-send-message API
4. **Send OTP** → Request authentication
5. **Verify OTP** → Authenticate user and automatically assign stored anonymous sessions
6. **Continue Chat** → Session now linked to authenticated user

## 🎯 Key Features

### ✅ **Separation of Concerns**
- NetworkServices: Pure API calls
- SupportRepo: Business logic & validation

### ✅ **Proper Error Handling**
- Uses existing `ErrorHandler` for consistent error processing
- Detailed logging with `smPrint`
- Returns structured `NetworkResult<T>`

### ✅ **Type Safety**
- Strongly typed models for all API requests/responses
- Proper null safety implementation
- Compile-time type checking

### ✅ **Authentication Support**
- Anonymous user sessions
- Authenticated user sessions with token support
- Flexible authentication header handling

### ✅ **Consistent API Structure**
- Follows existing codebase patterns
- Uses established dependency injection
- Maintains consistent naming conventions

### ✅ **State Management**
- Complete Cubit integration with BLoC pattern
- Reactive state updates for UI components
- Proper loading, success, and error states
- Persistent authentication state with SharedPreferences

### ✅ **Authentication Management**
- Global `isAuthenticated` boolean accessible throughout the app
- Automatic token persistence and restoration
- Automatic token injection for all API calls
- Token expiration handling with automatic logout

### ✅ **Icon Integration**
- Category icons map to `assets/icons/category/` folder
- Icon names returned from API match asset filenames

### ✅ **Anonymous Session Management**
- Automatic local storage of anonymous session IDs
- Seamless session assignment during authentication
- Persistent session tracking across app restarts
- Automatic cleanup after successful assignment

### ✅ **Real-time Messaging**
- Customer send message API integration
- Support for text messages and replies
- Automatic message appending to session
- Loading states and error handling for message sending

## 🔧 Configuration

### Base URL
```dart
static const String baseUrl = 'https://partner.withsm.ai/api/core';
```

### Available Icons
The API returns icon names that correspond to files in:
```
assets/icons/category/
├── payment.svg       # For payment-related issues
├── issue.svg         # For service issues  
├── download.svg      # For app download/update issues
└── ... (other category icons)
```

## 📝 Notes

### Error Handling Strategy
- **NetworkServices**: Throws exceptions, returns raw responses
- **SupportRepo**: Catches exceptions, validates responses, returns `NetworkResult`
- **UI Layer**: Uses `.when()` method to handle success/error cases

### Logging
All methods include detailed logging using `smPrint()`:
- Success logs include relevant data (count, IDs, etc.)
- Error logs include status codes and error messages
- Helps with debugging and monitoring

### Future Enhancements
The current implementation provides a solid foundation for:
- Adding more API endpoints
- Implementing real-time chat features
- Adding file upload capabilities
- Extending authentication mechanisms

## 🔐 Authentication Management System

### Overview

The package now includes a comprehensive authentication management system that handles:
- **Token Storage**: Secure persistence using SharedPreferences
- **Global Authentication State**: Accessible `isAuthenticated` boolean throughout the app
- **Automatic Token Injection**: All API calls automatically include auth tokens
- **Token Expiration Handling**: Automatic logout on 401 errors

### Key Components

#### 1. **AuthManager** - Global Authentication Controller
```dart
// Check authentication status anywhere in your app
bool isLoggedIn = AuthManager.isAuthenticated;

// Get current user data
CustomerModel? user = AuthManager.currentCustomer;
String? token = AuthManager.authToken;

// Logout user
await AuthManager.logout();
```

#### 2. **SharedPrefHelper** - Persistent Storage
```dart
// The AuthManager uses this internally, but you can access it directly if needed
String? token = SharedPrefHelper.getAuthToken();
bool isAuth = SharedPrefHelper.isAuthenticated;
```

#### 3. **DioFactory** - Automatic Token Injection
All API calls automatically include the auth token when user is authenticated. No need to manually add Authorization headers.

### Authentication Initialization

**IMPORTANT**: Initialize the authentication system when your app starts:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize authentication system
  await AuthManager.init();
  
  runApp(MyApp());
}
```

Or if using the Cubit:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cubit which will init AuthManager
  await smCubit.initializeAuth();
  
  runApp(MyApp());
}
```

### Global Authentication Access

You can check authentication status anywhere in your app:

```dart
// Method 1: Using AuthManager directly
if (AuthManager.isAuthenticated) {
  // User is logged in
  final user = AuthManager.currentCustomer;
  print('Welcome ${user?.name ?? user?.phone}');
}

// Method 2: Using Cubit state
BlocBuilder<SMSupportCubit, SMSupportState>(
  builder: (context, state) {
    if (state.isAuthenticated) {
      return AuthenticatedWidget();
    } else {
      return LoginWidget();
    }
  },
)
```

### Token Management

#### Automatic Token Persistence
```dart
// When user successfully verifies OTP, token is automatically saved
await cubit.verifyOtp(phone: '+1234567890', otp: '123456');
// Token is now persisted and will be restored on app restart

// Check if user is authenticated
bool isLoggedIn = AuthManager.isAuthenticated; // true
```

#### Automatic Token Injection
```dart
// All these calls automatically include auth token if user is authenticated
await cubit.getCategories();
await cubit.startSession(categoryId: 1);
// No need to manually add Authorization headers
```

#### Token Expiration Handling
```dart
// If API returns 401 (unauthorized), user is automatically logged out
// This happens transparently in the DioFactory interceptor
```

#### Manual Logout
```dart
// Logout user and clear all auth data
await cubit.logout();
// or
await AuthManager.logout();

// After logout:
AuthManager.isAuthenticated // false
AuthManager.currentCustomer // null
AuthManager.authToken // null
```

## 📱 Cubit Usage Examples

### Using the Cubit for State Management

```dart
// 1. Access the Cubit
final cubit = smCubit; // or context.read<SMSupportCubit>()

// 2. Fetch categories
await cubit.getCategories();

// 3. Listen to state changes
BlocBuilder<SMSupportCubit, SMSupportState>(
  builder: (context, state) {
    if (state.getCategoriesStatus.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (state.getCategoriesStatus.isSuccess) {
      return ListView.builder(
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return ListTile(
            title: Text(category.description),
            leading: Icon(getIconByName(category.icon)),
            onTap: () => cubit.startAnonymousSession(categoryId: category.id),
          );
        },
      );
    }
    
    return Text('Failed to load categories');
  },
)
```

### Sending Messages with SingleSessionCubit

```dart
// 1. Initialize SingleSessionCubit for a specific session
final sessionCubit = SingleSessionCubit(sessionId: 'your-session-id');

// 2. Send a text message
await sessionCubit.sendMessage(
  message: 'Hello, I need help with my order',
  contentType: 'TEXT',
);

// 3. Send a reply to a specific message
await sessionCubit.sendMessage(
  message: 'Thank you for the clarification',
  contentType: 'TEXT',
  reply: SessionMessageReply(
    messageId: 'message-id-to-reply-to',
    message: 'Original message content',
    contentType: 'TEXT',
  ),
);

// 4. Listen to send message status
BlocListener<SingleSessionCubit, SingleSessionState>(
  listener: (context, state) {
    if (state.sendMessageStatus.isSuccess) {
      // Message sent successfully, UI will automatically update
      print('Message sent successfully!');
    } else if (state.sendMessageStatus.isFailure) {
      // Handle error
      print('Failed to send message');
    }
  },
  child: BlocBuilder<SingleSessionCubit, SingleSessionState>(
    builder: (context, state) {
      return Column(
        children: [
          // Display messages
          Expanded(
            child: ListView.builder(
              itemCount: state.sessionMessages.length,
              itemBuilder: (context, index) {
                final message = state.sessionMessages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          // Send message input
          MessageInput(
            enabled: !state.sendMessageStatus.isLoading,
            onSend: (text) => sessionCubit.sendMessage(
              message: text,
              contentType: 'TEXT',
            ),
          ),
        ],
      );
    },
  ),
);
```

### Authentication Flow with Cubit

```dart
// Send OTP
await cubit.sendOtp(phone: '+201094222177');

// Listen to OTP status
BlocListener<SMSupportCubit, SMSupportState>(
  listener: (context, state) {
    if (state.sendOtpStatus.isSuccess) {
      // Navigate to OTP verification screen
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(phone: state.phoneNumber!),
      ));
    }
  },
  child: YourWidget(),
)

// Verify OTP
await cubit.verifyOtp(
  phone: '+201094222177',
  otp: '000000',
  sessionId: state.currentSessionId, // Link to existing session if any
);
```

### Anonymous Session Management

The package automatically manages anonymous sessions with persistent local storage:

```dart
// 1. Start an anonymous session (automatically stored locally)
await cubit.startAnonymousSession(categoryId: 1);

// 2. Use the session for messaging
final sessionCubit = SingleSessionCubit(sessionId: state.currentSession!.id);
await sessionCubit.sendMessage(message: 'Hello!', contentType: 'TEXT');

// 3. Later, when user authenticates, sessions are automatically assigned
await cubit.sendOtp(phone: '+201094222177');
await cubit.verifyOtp(phone: '+201094222177', otp: '000000');
// Anonymous sessions are now automatically linked to the authenticated user

// 4. Access stored anonymous session IDs (for debugging)
final storedSessionIds = SharedPrefHelper.getAnonymousSessionIds();
print('Stored anonymous sessions: $storedSessionIds');

// 5. Check if there are pending anonymous sessions
final hasPendingSessions = SharedPrefHelper.hasAnonymousSessionIds();
if (hasPendingSessions) {
  print('There are anonymous sessions waiting to be assigned');
}
```

### State Properties Access

```dart
BlocBuilder<SMSupportCubit, SMSupportState>(
  builder: (context, state) {
    // Authentication state
    final isAuthenticated = state.isAuthenticated;
    final currentUser = state.currentCustomer;
    final authToken = state.authToken;
    
    // Session state
    final hasActiveSession = state.hasActiveSession;
    final sessionId = state.currentSessionId;
    final sessionViewId = state.currentSessionViewId;
    
    // Loading states
    final isLoadingAuth = state.isLoadingAuth;
    final isLoadingSession = state.isLoadingSession;
    
    // Categories
    final categories = state.categories;
    final categoryById = state.getCategoryById(1);
    
    // My Sessions (new)
    final mySessions = state.mySessions;
    final unreadSessionsCount = state.myUnreadSessionsCount;
    
    return YourUIWidget();
  },
)
```

### New Session Management APIs (Added)

#### Get User Sessions
```dart
// Fetch all sessions for authenticated user
await cubit.getMySessions();

// Access sessions from state
BlocBuilder<SMSupportCubit, SMSupportState>(
  builder: (context, state) {
    if (state.getMySessionsStatus.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (state.getMySessionsStatus.isSuccess) {
      return ListView.builder(
        itemCount: state.mySessions.length,
        itemBuilder: (context, index) {
          final session = state.mySessions[index];
          return ListTile(
            title: Text(session.category.name),
            subtitle: Text(session.metadata.lastMessageContent),
            trailing: session.metadata.unreadCount > 0 
                ? Badge(label: Text('${session.metadata.unreadCount}'))
                : null,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ChatScreen(sessionId: session.id),
            )),
          );
        },
      );
    }
    
    return Text('Failed to load sessions');
  },
)
```

#### Get Unread Sessions Count
```dart
// Fetch unread sessions count
await cubit.getMyUnreadSessions();

// Access count from state
final unreadCount = state.myUnreadSessionsCount;
```

## 🔄 SingleSessionCubit - Individual Session Management

For managing individual chat sessions, use the `SingleSessionCubit`. This cubit is designed for:
- Managing a single session's messages
- Future socket streaming implementation
- Session-specific state management

### Using SingleSessionCubit

#### 1. Create Cubit Instance
```dart
// Using dependency injection
final sessionCubit = sl<SingleSessionCubit>(param1: sessionId);

// Or create directly
final sessionCubit = SingleSessionCubit(sessionId: 'your-session-id');
```

#### 2. Get Session Messages
```dart
class ChatScreen extends StatefulWidget {
  final String sessionId;
  
  const ChatScreen({required this.sessionId});
  
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late SingleSessionCubit sessionCubit;
  
  @override
  void initState() {
    super.initState();
    sessionCubit = sl<SingleSessionCubit>(param1: widget.sessionId);
    sessionCubit.getSessionMessages(); // Load messages
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: BlocBuilder<SingleSessionCubit, SingleSessionState>(
        bloc: sessionCubit,
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state.hasError) {
            return Center(child: Text('Failed to load messages'));
          }
          
          return ListView.builder(
            itemCount: state.sessionMessages.length,
            itemBuilder: (context, index) {
              final message = state.sessionMessages[index];
              return MessageBubble(message: message);
            },
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    sessionCubit.clearSession(); // Clean up when leaving
    super.dispose();
  }
}
```

#### 3. SingleSessionCubit Methods
```dart
// Load/refresh messages
await sessionCubit.getSessionMessages();
await sessionCubit.refreshMessages();

// Session management
sessionCubit.updateSessionId('new-session-id');
sessionCubit.clearSession();

// Future features (placeholders)
await sessionCubit.markMessagesAsRead();
await sessionCubit.sendTypingIndicator(true);

// State access
final unreadCount = sessionCubit.unreadMessagesCount;
final lastMessage = sessionCubit.lastMessage;
final hasFailedMessages = sessionCubit.hasFailedMessages;
final customerMessages = sessionCubit.getMessagesBySender('CUSTOMER');
final messageById = sessionCubit.findMessageById('message-id');
```

#### 4. SingleSessionState Properties
```dart
BlocBuilder<SingleSessionCubit, SingleSessionState>(
  builder: (context, state) {
    // Basic state
    final sessionId = state.sessionId;
    final isLoading = state.isLoading;
    final hasError = state.hasError;
    final hasMessages = state.hasMessages;
    
    // Messages
    final allMessages = state.sessionMessages;
    final customerMessages = state.customerMessages;
    final adminMessages = state.adminMessages;
    final failedMessages = state.failedMessages;
    
    // Convenience getters
    final unreadCount = state.unreadCount;
    final lastMessage = state.lastMessage;
    final firstMessage = state.firstMessage;
    final hasUnreadMessages = state.hasUnreadMessages;
    final hasFailedMessages = state.hasFailedMessages;
    
    return YourChatUI();
  },
)
```

### Future Socket Implementation

The `SingleSessionCubit` is designed to support future WebSocket implementation:

```dart
// Future implementation concept
class SingleSessionCubit extends Cubit<SingleSessionState> {
  StreamSubscription? _socketSubscription;
  
  void connectToSession(String sessionId) {
    // Connect to WebSocket for real-time messages
    _socketSubscription = socketService.connect(sessionId).listen((message) {
      // Update state with new messages
      final updatedMessages = [...state.sessionMessages, message];
      emit(state.copyWith(sessionMessages: updatedMessages));
    });
  }
  
  @override
  Future<void> close() {
    _socketSubscription?.cancel(); // Clean up socket connection
    return super.close();
  }
}
```

## 🚀 Getting Started

### 1. **Add Dependencies**

Add to your `pubspec.yaml`:
```yaml
dependencies:
  sm_ai_support: ^1.0.0
  shared_preferences: ^2.2.2  # Required for auth persistence
```

### 2. **Import the Package**
```dart
import 'package:sm_ai_support/sm_ai_support.dart';
```

### 3. **Initialize Authentication System**

**CRITICAL**: Initialize the authentication system in your `main()` function:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the authentication system
  await AuthManager.init();
  
  runApp(MyApp());
}
```

### 4. **Initialize Cubit (Recommended)**

In your app initialization or when first accessing support:

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeSupport();
  }
  
  Future<void> _initializeSupport() async {
    // This will restore any existing authentication
    await smCubit.initializeAuth();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<SMSupportCubit, SMSupportState>(
        builder: (context, state) {
          // Global authentication check
          if (AuthManager.isAuthenticated) {
            return AuthenticatedHomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
```

### 5. **Start Using the APIs**

```dart
// Check authentication status anywhere
bool isLoggedIn = AuthManager.isAuthenticated;

// Fetch categories
await smCubit.getCategories();

// Anonymous user flow
await smCubit.startAnonymousSession(categoryId: 1);

// Authentication flow
await smCubit.sendOtp(phone: '+1234567890');
await smCubit.verifyOtp(phone: '+1234567890', otp: '123456');

// Authenticated session (auth token automatically included)
await smCubit.startSession(categoryId: 1);

// Logout
await smCubit.logout();
```

This implementation provides a robust foundation for the support system with clear separation of concerns, proper error handling, type-safe API interactions, and reactive state management through BLoC/Cubit pattern.
