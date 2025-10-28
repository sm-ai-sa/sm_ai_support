import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/network/error/error_handler.dart';
import 'package:sm_ai_support/src/core/network/network_services.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class SupportRepo {
  //! New Support API Methods -----------------------------------

  /// Get tenant information by ID
  /// Returns tenant configuration data including theme colors, name, and logo
  Future<NetworkResult<TenantResponse>> getTenant({required String tenantId}) async {
    try {
      final response = await networkServices.getTenant(tenantId: tenantId);

      if (response.statusCode?.isSuccess ?? false) {
        final tenantResponse = TenantResponse.fromJson(response.data);
        smPrint('Fetch Tenant Response: Success - Tenant ID: ${tenantResponse.tenant.tenantId}');
        return Success(tenantResponse);
      } else {
        smPrint('Fetch Tenant Error: ${response.statusCode} - ${response.data}');
        // // Return dummy tenant for error cases
        // final dummyTenant = TenantResponse(tenant: TenantModel.dummy());
        // smPrint('Using dummy tenant data');
        // return Success(dummyTenant);
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Fetch Tenant Error: $e');
      // // Return dummy tenant for error cases
      // final dummyTenant = TenantResponse(tenant: TenantModel.dummy());
      // smPrint('Using dummy tenant data due to exception');
      // return Success(dummyTenant);
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Get support categories
  /// Returns a list of available support categories with their icons and descriptions
  Future<NetworkResult<CategoriesResponse>> getCategories({required String tenantId}) async {
    try {
      final response = await networkServices.getCategories(tenantId: tenantId);

      if (response.statusCode?.isSuccess ?? false) {
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

  /// Start a new anonymous support session
  /// Creates a new session for users who are not authenticated
  /// [categoryId] - The category ID for the support request
  Future<NetworkResult<SessionResponse>> startAnonymousSession({required int categoryId}) async {
    try {
      final response = await networkServices.startAnonymousSession(categoryId: categoryId);

      if (response.statusCode?.isSuccess ?? false) {
        final sessionResponse = SessionResponse.fromJson(response.data);
        smPrint('Start Anonymous Session Response: Success - Session ID: ${sessionResponse.result.id}');
        return Success(sessionResponse);
      } else {
        smPrint('Start Anonymous Session Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Start Anonymous Session Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Assign anonymous session to current user
  /// Links previously created anonymous sessions to the current user
  /// [sessionIds] - List of session IDs to assign to the current user
  Future<NetworkResult<dynamic>> assignAnonymousSession({required List<String> sessionIds}) async {
    try {
      final response = await networkServices.assignAnonymousSession(sessionIds: sessionIds);

      if (response.statusCode?.isSuccess ?? false) {
        smPrint('Assign Anonymous Session Response: Success - Assigned ${sessionIds.length} sessions');
        return Success(response.data);
      } else {
        smPrint('Assign Anonymous Session Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Assign Anonymous Session Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Start a new authenticated support session
  /// Creates a new session for authenticated users
  /// [categoryId] - The category ID for the support request
  /// [authToken] - Optional authentication token for the request
  Future<NetworkResult<SessionResponse>> startSession({required int categoryId, String? authToken}) async {
    try {
      final response = await networkServices.startSession(categoryId: categoryId, authToken: authToken);

      if (response.statusCode?.isSuccess ?? false) {
        final sessionResponse = SessionResponse.fromJson(response.data);
        smPrint('Start Session Response: Success - Session ID: ${sessionResponse.result.id}');
        return Success(sessionResponse);
      } else {
        smPrint('Start Session Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Start Session Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Get user's sessions
  /// Returns a list of sessions for the authenticated user
  Future<NetworkResult<MySessionsResponse>> getMySessions() async {
    try {
      final response = await networkServices.getMySessions();

      if (response.statusCode?.isSuccess ?? false) {
        final sessionsResponse = MySessionsResponse.fromJson(response.data);
        smPrint('Get My Sessions Response: Success - ${sessionsResponse.result.length} sessions');
        return Success(sessionsResponse);
      } else {
        smPrint('Get My Sessions Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Get My Sessions Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Get user's unread sessions count
  /// Returns the count of unread sessions for the authenticated user
  Future<NetworkResult<UnreadSessionsResponse>> getMyUnreadSessions() async {
    try {
      final response = await networkServices.getMyUnreadSessions();

      if (response.statusCode?.isSuccess ?? false) {
        final unreadResponse = UnreadSessionsResponse.fromJson(response.data);
        smPrint('Get My Unread Sessions Response: Success - ${unreadResponse.result} unread sessions');
        return Success(unreadResponse);
      } else {
        smPrint('Get My Unread Sessions Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Get My Unread Sessions Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Get messages for a specific session
  /// Returns all messages for the specified session ID
  /// [sessionId] - The ID of the session to get messages for
  Future<NetworkResult<SessionMessagesResponse>> getMySessionMessages({required String sessionId}) async {
    try {
      final response = await networkServices.getMySessionMessages(sessionId: sessionId);

      if (response.statusCode?.isSuccess ?? false) {
        final messagesResponse = SessionMessagesResponse.fromJson(response.data);
        smPrint('Get My Session Messages Response: Success - ${messagesResponse.result.length} message documents');
        return Success(messagesResponse);
      } else {
        smPrint('Get My Session Messages Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Get My Session Messages Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Send a message in a customer session
  /// Sends a message from the customer to the support team
  /// [sessionId] - The ID of the session to send the message to
  /// [message] - The message content to send
  /// [contentType] - The type of content being sent (e.g., TEXT)
  /// [reply] - Optional reply to a specific message
  Future<NetworkResult<CustomerSendMessageResponse>> customerSendMessage({
    required String sessionId,
    required String message,
    required String contentType,
    SessionMessageReply? reply,
  }) async {
    try {
      final response = await networkServices.customerSendMessage(
        sessionId: sessionId,
        message: message,
        contentType: contentType,
        reply: reply,
      );

      if (response.statusCode?.isSuccess ?? false) {
        final sendMessageResponse = CustomerSendMessageResponse.fromJson(response.data);
        smPrint('Customer Send Message Response: Success - Message ID: ${sendMessageResponse.result.id}');
        return Success(sendMessageResponse);
      } else {
        smPrint('Customer Send Message Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Customer Send Message Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Send a message in an anonymous customer session
  /// Sends a message from an anonymous customer to the support team
  /// [sessionId] - The ID of the session to send the message to
  /// [message] - The message content to send
  /// [contentType] - The type of content being sent (e.g., TEXT)
  /// [reply] - Optional reply to a specific message
  Future<NetworkResult<CustomerSendMessageResponse>> anonymousCustomerSendMessage({
    required String sessionId,
    required String message,
    required String contentType,
    SessionMessageReply? reply,
  }) async {
    try {
      final response = await networkServices.anonymousCustomerSendMessage(
        sessionId: sessionId,
        message: message,
        contentType: contentType,
        reply: reply,
      );

      if (response.statusCode?.isSuccess ?? false) {
        final sendMessageResponse = CustomerSendMessageResponse.fromJson(response.data);
        smPrint('Anonymous Customer Send Message Response: Success - Message ID: ${sendMessageResponse.result.id}');
        return Success(sendMessageResponse);
      } else {
        smPrint('Anonymous Customer Send Message Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Anonymous Customer Send Message Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Mark customer messages as read
  /// Marks messages in a session as read by the customer
  /// [sessionId] - The ID of the session to mark messages as read
  Future<NetworkResult<dynamic>> readMessages({required String sessionId}) async {
    try {
      final response = AuthManager.isAuthenticated
          ? await networkServices.customerReadMessages(sessionId: sessionId)
          : await networkServices.anonymousCustomerReadMessages(sessionId: sessionId);

      if (response.statusCode?.isSuccess ?? false) {
        smPrint('Customer Read Messages Response: Success for session $sessionId');
        return Success(response.data);
      } else {
        smPrint('Customer Read Messages Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Customer Read Messages Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Rate a session
  /// Submits a rating and optional comment for a support session
  /// [sessionId] - The ID of the session to rate
  /// [rating] - The rating value (typically 1-5)
  /// [comment] - Optional comment about the session
  Future<NetworkResult<RateSessionResponse>> rateSession({
    required String sessionId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await networkServices.rateSession(sessionId: sessionId, rating: rating, comment: comment);

      if (response.statusCode?.isSuccess ?? false) {
        final rateResponse = RateSessionResponse.fromJson(response.data);
        smPrint('Rate Session Response: Success - ${rateResponse.message}');
        return Success(rateResponse);
      } else {
        smPrint('Rate Session Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Rate Session Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Reopen a closed session
  /// Reopens a previously closed support session
  /// [sessionId] - The ID of the session to reopen
  Future<NetworkResult<bool>> reopenSession({required String sessionId}) async {
    try {
      final response = await networkServices.reopenSession(sessionId: sessionId);

      if (response.statusCode?.isSuccess ?? false) {
        return Success(true);
      } else {
        smPrint('Reopen Session Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Reopen Session Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  //! Storage/Upload API Methods -----------------------------------

  /// Request storage upload presigned URL
  /// [category] - Upload category (MESSAGE_IMAGE, SESSION_AUDIO)
  /// [referenceId] - Session ID for the upload
  /// [filesName] - List of file names to upload
  Future<NetworkResult<StorageUploadResponse>> requestStorageUpload({
    required String category,
    required String referenceId,
    required List<String> filesName,
  }) async {
    try {
      final response = await networkServices.requestStorageUpload(
        category: category,
        referenceId: referenceId,
        filesName: filesName,
      );

      if (response.statusCode?.isSuccess ?? false) {
        final uploadResponse = StorageUploadResponse.fromJson(response.data);
        smPrint('Request Storage Upload Response: Success - ${uploadResponse.result.length} upload URLs');
        return Success(uploadResponse);
      } else {
        smPrint('Request Storage Upload Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Request Storage Upload Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Request download URLs for files
  /// [category] - Download category (MESSAGE_IMAGE, SESSION_AUDIO)
  /// [referenceId] - Session ID for the download
  /// [filesName] - List of file names to download
  Future<NetworkResult<StorageDownloadResponse>> requestStorageDownload({
    required String category,
    required String referenceId,
    required List<String> filesName,
  }) async {
    try {
      final response = await networkServices.requestStorageDownload(
        category: category,
        referenceId: referenceId,
        filesName: filesName,
      );

      if (response.statusCode?.isSuccess ?? false) {
        final downloadResponse = StorageDownloadResponse.fromJson(response.data);
        smPrint('Request Storage Download Response: Success - ${downloadResponse.result.length} download URLs');
        return Success(downloadResponse);
      } else {
        smPrint('Request Storage Download Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Request Storage Download Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }

  /// Upload file to cloud storage using presigned URL
  /// [uploadUrl] - The presigned URL for upload
  /// [fields] - Form fields from the upload request
  /// [filePath] - Local file path to upload
  /// [fileName] - Name of the file
  Future<NetworkResult<dynamic>> uploadToCloud({
    required String uploadUrl,
    required Map<String, String> fields,
    required String filePath,
    required String fileName,
  }) async {
    try {
      smPrint('Upload to Cloud Request: $uploadUrl');
      // print the fields
      smPrint('Upload to Cloud Fields: $fields');
      // print the filePath
      smPrint('Upload to Cloud File Path: $filePath');
      // print the fileName
      smPrint('Upload to Cloud File Name: $fileName');

      final response = await networkServices.uploadToCloud(
        uploadUrl: uploadUrl,
        fields: fields,
        filePath: filePath,
        fileName: fileName,
      );

      if (response.statusCode?.isSuccess ?? false) {
        smPrint('Upload to Cloud Response: Success for file $fileName');
        return Success(response.data);
      } else {
        smPrint('Upload to Cloud Error: ${response.statusCode}');
        return Error(ErrorHandler.handle(response));
      }
    } catch (e) {
      smPrint('Upload to Cloud Error: $e');
      return Error(ErrorHandler.handle(e));
    }
  }
}
