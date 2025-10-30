import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/network/api.dart';
import 'package:sm_ai_support/src/core/network/dio_factory.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

NetworkServices get networkServices => sl<NetworkServices>();

class NetworkServices {
  // Use getter instead of final field to ensure fresh Dio instance
  Dio get dio {
    final dioInstance = DioFactory.ensureDioInstance();
    return dioInstance;
  }

  //! Support API Methods -----------------------------------

  /// Get tenant information by ID
  Future<Response> getTenant({required String tenantId}) async {
    smPrint('🌐 Making tenant API request to: ${Apis.getTenant}?id=$tenantId');
    try {
      final response = await dio.get(Apis.getTenant, queryParameters: {'id': tenantId});
      smPrint('🌐 Tenant API response: ${response.statusCode}');
      return response;
    } catch (e) {
      smPrint('🌐 Tenant API error: $e');
      rethrow;
    }
  }

  /// Get categories for support
  Future<Response> getCategories({required String tenantId}) async {
    return await dio.get(Apis.getCategories);
  }

  /// Start a new anonymous session
  Future<Response> startAnonymousSession({required int categoryId}) async {
    final request = StartSessionRequest(categoryId: categoryId);
    return await dio.post(Apis.startAnonymousSession, data: request.toJson());
  }

  /// Assign anonymous session to current user
  Future<Response> assignAnonymousSession({required List<String> sessionIds}) async {
    final request = AssignAnonymousSessionRequest(ids: sessionIds);
    return await dio.post(Apis.assignAnonymousSession, data: request.toJson());
  }

  /// Start a new session for authenticated user
  Future<Response> startSession({required int categoryId, String? authToken}) async {
    final request = StartSessionRequest(categoryId: categoryId);

    // Add auth header if token is provided
    final options = authToken != null ? Options(headers: {'Authorization': 'Bearer $authToken'}) : null;

    return await dio.post(Apis.startSession, data: request.toJson(), options: options);
  }

  /// Get user's sessions
  Future<Response> getMySessions() async {
    return await dio.get(Apis.mySessions);
  }

  /// Get user's unread sessions count
  Future<Response> getMyUnreadSessions() async {
    return await dio.get(Apis.myUnreadSessions);
  }

  /// Get messages for a specific session
  Future<Response> getMySessionMessages({required String sessionId}) async {
    return await dio.get(Apis.mySessionMessages, queryParameters: {'id': sessionId});
  }

  /// Send a message in a customer session
  Future<Response> customerSendMessage({
    required String sessionId,
    required String message,
    required String contentType,
    SessionMessageReply? reply,
  }) async {
    final request = CustomerSendMessageRequest(
      sessionId: sessionId,
      message: message,
      contentType: contentType,
      reply: reply,
    );
    return await dio.post(Apis.customerSendMessage, data: request.toJson());
  }

  /// Send a message in an anonymous customer session
  Future<Response> anonymousCustomerSendMessage({
    required String sessionId,
    required String message,
    required String contentType,
    SessionMessageReply? reply,
  }) async {
    final request = CustomerSendMessageRequest(
      sessionId: sessionId,
      message: message,
      contentType: contentType,
      reply: reply,
    );
    return await dio.post(Apis.anonymousCustomerSendMessage, data: request.toJson());
  }

  /// Mark customer messages as read
  Future<Response> customerReadMessages({required String sessionId}) async {
    final request = {'id': sessionId};
    return await dio.put(Apis.customerReadMessages, data: request);
  }

  /// Mark anonymous customer messages as read
  Future<Response> anonymousCustomerReadMessages({required String sessionId}) async {
    final request = {'id': sessionId};
    return await dio.put(Apis.anonymousCustomerReadMessage, data: request);
  }

  /// Rate a session
  Future<Response> rateSession({required String sessionId, required int rating, String? comment}) async {
    final request = RateSessionRequest(sessionId: sessionId, rating: rating, comment: comment);
    return await dio.post(
      AuthManager.isAuthenticated ? Apis.rateSession : Apis.rateSessionAnonymous,
      data: request.toJson(),
    );
  }

  /// Reopen a closed session
  Future<Response> reopenSession({required String sessionId}) async {
    final request = ReopenSessionRequest(id: sessionId);
    return await dio.post(Apis.reopenSession, data: request.toJson());
  }

  //! Authentication API Methods -----------------------------------

  /// Send OTP to phone number
  Future<Response> sendOtp({required String phone}) async {
    final request = SendOtpRequest(phone: phone);
    return await dio.post(Apis.sendOtp, data: request.toJson());
  }

  /// Verify OTP code
  Future<Response> verifyOtp({
    required String phone,
    required String otp,
    required String tempToken,
    String? sessionId,
  }) async {
    final request = VerifyOtpRequest(phone: phone, otp: otp, sessionId: sessionId);

    final options = Options(headers: {'Authorization': 'Bearer $tempToken'});
    return await dio.post(Apis.verifyOtp, data: request.toJson(), options: options);
  }

  //! Storage/Upload API Methods -----------------------------------

  /// Request upload URL and presigned data
  Future<Response> requestStorageUpload({
    required String category,
    required String referenceId,
    required List<String> filesName,
  }) async {
    final request = StorageUploadRequest(category: category, referenceId: referenceId, filesName: filesName);
    return await dio.post(Apis.storageUpload, data: request.toJson());
  }

  /// Request download URL for files
  Future<Response> requestStorageDownload({
    required String category,
    required String referenceId,
    required List<String> filesName,
  }) async {
    final request = StorageDownloadRequest(category: category, referenceId: referenceId, filesName: filesName);
    return await dio.post(Apis.storageDownload, data: request.toJson());
  }

  /// Upload file to R2 cloud storage using presigned URL
  /// Uses PUT request with raw file data as per R2 requirements
  Future<Response> uploadToR2({
    required String presignedUrl,
    required String filePath,
  }) async {
    try {
      // Read file as bytes
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      
      // Detect MIME type from file path
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
      
      smPrint('📤 Uploading to R2: ${file.path}');
      smPrint('📤 File size: ${fileBytes.length} bytes');
      smPrint('📤 MIME type: $mimeType');
      smPrint('📤 Presigned URL: $presignedUrl');

      // Create a new Dio instance for cloud upload (no base URL)
      final cloudDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ));

      // Upload using PUT request with raw file bytes
      final response = await cloudDio.put(
        presignedUrl,
        data: fileBytes,
        options: Options(
          method: 'PUT',
          headers: {
            'Content-Type': mimeType,
          },
          contentType: mimeType,
        ),
      );

      smPrint('📤 Upload completed with status: ${response.statusCode}');
      return response;
    } catch (e) {
      smPrint('📤 Upload failed: $e');
      rethrow;
    }
  }

  //! Get User Tickets -----------------------------------
  // Stream<List<TicketModel>> getUserTickets() {
  //   return SMConfig.firestore
  //       .collection('support')
  //       .where(
  //         'userId',
  //         isEqualTo: SMConfig.userId,
  //       )
  //       .snapshots()
  //       .map(
  //     (value) {
  //       return value.docs.map((e) => TicketModel.fromJson(e.data())).toList();
  //     },
  //   );
  // }

  //! get user chats as stream
  // Map<String, Stream<List<ChatMessageDoc>>> getUserChatStream({
  //   required List<String> activeTickets,
  // }) {
  //   // ticketId -> chatStream
  //   final Map<String, Stream<List<ChatMessageDoc>>> chatStreamMap = {};
  //   for (final ticketId in activeTickets) {
  //     final stream = SMConfig.firestore
  //         .collection('support')
  //         .doc(ticketId)
  //         .collection('chat')
  //         .orderBy('createdAt', descending: true)
  //         .snapshots()
  //         .map(
  //           (event) => event.docs
  //               .map(
  //                 (e) => ChatMessageDoc.fromJson(e.data()),
  //               )
  //               .toList(),
  //         );
  //     chatStreamMap[ticketId] = stream;
  //   }
  //   return chatStreamMap;
  // }

  //! Open Ticket
  // Future<void> openTicket({
  //   required TicketModel ticket,
  // }) async {
  //   return await SMConfig.firestore.collection('support').doc(ticket.ticketId).set(ticket.toJson());
  // }

  //! Push message to chat
  // Future<void> pushMessage({
  //   required String ticketId,
  //   required String docId,
  //   required MessageModel message,
  //   bool isNewDoc = false,
  // }) async {
  //   ChatMessageDoc chatDoc = ChatMessageDoc(
  //     docId: docId,
  //     ticketId: ticketId,
  //     createdAt: DateTime.now(),
  //     messages: [message],
  //   );
  //   return isNewDoc
  //       ? await SMConfig.firestore
  //           .collection('support')
  //           .doc(ticketId)
  //           .collection('chat')
  //           .doc(docId)
  //           .set(chatDoc.toJson())
  //       : await SMConfig.firestore.collection('support').doc(ticketId).collection('chat').doc(docId).update({
  //           'messages': FieldValue.arrayUnion(
  //             [message.toJson()],
  //           ),
  //         });
  // }

  /// Mark Admin messages as read
  // Future<void> markAdminMessagesAsRead({required String ticketId, required List<ChatMessageDoc> updatedDocs}) async {
  //   for (final doc in updatedDocs) {
  //     await SMConfig.firestore.collection('support').doc(ticketId).collection('chat').doc(doc.docId).update({
  //       'messages': doc.messages.map((e) => e.toJson()).toList(),
  //     });
  //   }
  // }

  /// re-open closed ticket
  // Future<void> reOpenTicket({required String ticketId}) async {
  //   return await SMConfig.firestore.collection('support').doc(ticketId).update({
  //     'status': TicketStatus.active.name,
  //     'statusLogs': FieldValue.arrayUnion([
  //       StatusLog(
  //         changedToStatus: TicketStatus.active,
  //         date: DateTime.now(),
  //         changedByUserID: SMConfig.userId,
  //         changedBy: ChangedBy.customer,
  //       ).toJson(),
  //     ]),
  //   });
  // }

  /// Rate the ticket
  // Future<void> rateTicket({required String ticketId, required num rate}) async {
  //   return await SMConfig.firestore.collection('support').doc(ticketId).update({
  //     'rate': rate,
  //   });
  // }
  //! Push dummy tickets
  // Future<void> pushDummyTickets() async {
  //   final tickets = DummyDate.dummyTickets;
  //   for (final ticket in tickets) {
  //     await SMConfig.firestore.collection('support').doc(ticket.ticketId).set(ticket.toJson());
  //   }
  // }

  // Future<void> changeTypingStatus({required String ticketId, required bool isTyping}) async {
  //   return await SMConfig.firestore.collection('support').doc(ticketId).update({
  //     'isUserTyping': isTyping,
  //   });
  // }
}
