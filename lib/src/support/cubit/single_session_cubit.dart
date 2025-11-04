// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/services/media_upload.dart';
import 'package:sm_ai_support/src/core/services/picker_helper.dart';
import 'package:sm_ai_support/src/core/utils/image_url_resolver.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/support/cubit/single_session_state.dart';

/// Media type enum for file picker dialog
enum MediaFileType { video, audio, document }

class SingleSessionCubit extends Cubit<SingleSessionState> {
  StreamSubscription<SessionMessage>? _messageStreamSubscription;
  StreamSubscription<bool>? _ratingRequestSubscription;
  Timer? _markAsReadDebounceTimer;

  SingleSessionCubit({required String sessionId}) : super(SingleSessionState(sessionId: sessionId));

  /// Get messages for the current session (initial load with pagination)
  Future<void> getSessionMessages({int limit = Constants.MESSAGES_LIMIT}) async {
    smPrint('Get Session Messages for: ${state.sessionId}');
    emit(state.copyWith(getSessionMessagesStatus: BaseStatus.loading, hasMoreMessages: true));
    try {
      final result = await sl<SupportRepo>().getMySessionMessages(sessionId: state.sessionId, limit: limit);
      result.when(
        success: (data) {
          smPrint('Get Session Messages Success: ${data.result.messages.length} messages');

          // Get all messages
          final List<SessionMessage> allMessages = [];
          allMessages.addAll(data.result.messages);

          // Sort messages by creation time (oldest first)
          allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          // Check if we received less than limit, meaning no more messages to load
          final hasMore = data.result.messages.length >= limit;

          emit(
            state.copyWith(
              getSessionMessagesStatus: BaseStatus.success,
              sessionMessages: allMessages,
              sessionMessageDoc: data.result,
              hasMoreMessages: hasMore,
            ),
          );
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(getSessionMessagesStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(getSessionMessagesStatus: BaseStatus.failure));
    }
  }

  /// Load more (older) messages using cursor-based pagination
  Future<void> loadMoreMessages({int limit = Constants.MESSAGES_LIMIT}) async {
    // Don't load if already loading or no more messages
    if (state.loadMoreMessagesStatus.isLoading || !state.hasMoreMessages) {
      smPrint('Skip loading more: loading=${state.loadMoreMessagesStatus.isLoading}, hasMore=${state.hasMoreMessages}');
      return;
    }

    // Get the oldest message ID as cursor
    if (state.sessionMessages.isEmpty) {
      smPrint('No messages to use as cursor, skipping load more');
      return;
    }

    final cursorId = state.sessionMessages.first.id;
    smPrint('Load More Messages - cursor: $cursorId, limit: $limit');

    emit(state.copyWith(loadMoreMessagesStatus: BaseStatus.loading));

    try {
      final result = await sl<SupportRepo>().getMySessionMessages(
        sessionId: state.sessionId,
        limit: limit,
        cursorId: cursorId,
      );

      result.when(
        success: (data) {
          smPrint('Load More Messages Success: ${data.result.messages.length} messages');

          // If empty list, we've reached the end
          if (data.result.messages.isEmpty) {
            smPrint('Reached end of messages');
            emit(state.copyWith(loadMoreMessagesStatus: BaseStatus.success, hasMoreMessages: false));
            return;
          }

          // Combine old messages with new (older) messages
          final List<SessionMessage> allMessages = [...data.result.messages, ...state.sessionMessages];

          // Sort messages by creation time (oldest first)
          allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          // Check if we received less than limit, meaning no more messages
          final hasMore = data.result.messages.length >= limit;

          emit(
            state.copyWith(
              loadMoreMessagesStatus: BaseStatus.success,
              sessionMessages: allMessages,
              hasMoreMessages: hasMore,
            ),
          );
        },
        error: (error) {
          smPrint('Load More Messages Error: ${error.failure.error}');
          emit(state.copyWith(loadMoreMessagesStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      smPrint('Load More Messages Error: $e');
      emit(state.copyWith(loadMoreMessagesStatus: BaseStatus.failure));
    }
  }

  /// Refresh session messages (convenience method)
  Future<void> refreshMessages() async {
    await getSessionMessages();
  }

  /// Clear current session data
  void clearSession() {
    emit(
      state.copyWith(
        sessionMessages: const [],
        sessionMessageDoc: const SessionMessagesDoc(id: '', messages: [], isRatingRequired: false),
        getSessionMessagesStatus: BaseStatus.initial,
        loadMoreMessagesStatus: BaseStatus.initial,
        rateSessionStatus: BaseStatus.initial,
        hasMoreMessages: true,
        repliedOn: null,
        isResetRepliedOn: true,
        isRatingRequiredFromSocket: false,
      ),
    );
  }

  /// Update session ID and clear previous data
  void updateSessionId(String newSessionId) {
    emit(
      state.copyWith(
        sessionId: newSessionId,
        sessionMessages: [],
        sessionMessageDoc: const SessionMessagesDoc(id: '', messages: [], isRatingRequired: false),
        isResetCategory: true,
      ),
    );
  }

  /// Set category for new session creation
  void setCategoryForNewSession(CategoryModel category) {
    smPrint('Setting category for new session: ${category.categoryName} (ID: ${category.id})');
    emit(state.copyWith(categoryForNewSession: category));
  }

  /// Create a new session with the specified category
  Future<String?> createSessionWithCategory(CategoryModel category) async {
    final isAuthenticated = AuthManager.isAuthenticated;
    smPrint(
      'Creating new session for category: ${category.categoryName} (ID: ${category.id}), isAuthenticated: $isAuthenticated',
    );

    emit(state.copyWith(createSessionStatus: BaseStatus.loading));

    try {
      final NetworkResult<SessionResponse> result;

      if (isAuthenticated) {
        result = await sl<SupportRepo>().startSession(
          categoryId: category.id,
          authToken: null, // Auth token automatically added by interceptor
        );
      } else {
        result = await sl<SupportRepo>().startAnonymousSession(categoryId: category.id);
      }

      return result.when(
        success: (data) async {
          smPrint('Session created successfully: ${data.result.id}');

          // Save anonymous session ID to SharedPreferences if anonymous
          if (!isAuthenticated) {
            await SharedPrefHelper.addAnonymousSessionId(data.result.id);
            smPrint('Saved anonymous session ID: ${data.result.id}');
          }

          // Update state with new session
          emit(
            state.copyWith(createSessionStatus: BaseStatus.success, sessionId: data.result.id, isResetCategory: true),
          );

          return data.result.id;
        },
        error: (error) {
          smPrint('Session creation failed: ${error.failure.error}');
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(createSessionStatus: BaseStatus.failure));
          return null;
        },
      );
    } catch (e) {
      smPrint('Session creation exception: $e');
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(createSessionStatus: BaseStatus.failure));
      return null;
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead() async {
    smPrint('Mark messages as read for session: ${state.sessionId}');
    try {
      final result = await sl<SupportRepo>().readMessages(sessionId: state.sessionId);
      result.when(
        success: (data) {
          smPrint('Mark Messages as Read Success for session: ${state.sessionId}');

          if (AuthManager.isAuthenticated) {
            // Update the unread count in SMSupportCubit after successful API call
            smCubit.updateSessionUnreadCount(state.sessionId);
          }
        },
        error: (error) {
          smPrint('Mark Messages as Read Error: ${error.failure.error}');
        },
      );
    } catch (e) {
      smPrint('Mark Messages as Read Error: $e');
    }
  }

  /// Mark messages as read with debounce to prevent multiple rapid calls
  void markMessagesAsReadDebounced({Duration delay = const Duration(seconds: 10)}) {
    smPrint('Debounced mark messages as read triggered for session: ${state.sessionId}');

    // Cancel previous timer if it exists
    _markAsReadDebounceTimer?.cancel();

    // Set new timer
    _markAsReadDebounceTimer = Timer(delay, () {
      smPrint('Executing debounced mark messages as read after delay');
      markMessagesAsRead();
    });
  }

  /// Send typing indicator (placeholder for future implementation)
  Future<void> sendTypingIndicator(bool isTyping) async {
    // TODO: Implement when typing indicator API is available
    smPrint('Send typing indicator for session: ${state.sessionId}, isTyping: $isTyping');
  }

  /// Get last message in the session
  SessionMessage? get lastMessage {
    if (state.sessionMessages.isEmpty) return null;
    return state.sessionMessages.last;
  }

  /// Check if there are any failed messages
  bool get hasFailedMessages {
    return state.sessionMessages.any((message) => message.isFailed);
  }

  /// Find message by ID
  SessionMessage? findMessageById(String messageId) {
    try {
      return state.sessionMessages.firstWhere((message) => message.id == messageId);
    } catch (e) {
      return null;
    }
  }

  /// Send a message in the current session
  /// If no session exists and category is set, creates session first
  Future<void> sendMessage({required String message, required String contentType}) async {
    final isAuthenticated = AuthManager.isAuthenticated;
    smPrint('🚀 STARTING SEND MESSAGE PROCESS');
    smPrint('Current session ID: ${state.sessionId}');
    smPrint('Message: $message');
    smPrint('Content Type: $contentType');
    smPrint('Is Authenticated: $isAuthenticated');

    // Check if we need to create a session first
    if (state.sessionId.isEmpty && state.categoryForNewSession != null) {
      smPrint('🆕 No session exists, creating new session first');
      final sessionId = await createSessionWithCategory(state.categoryForNewSession!);
      if (sessionId == null) {
        smPrint('❌ Failed to create session, aborting message send');
        return;
      }
      smPrint('✅ Session created successfully: $sessionId');
    }

    // Ensure we have a session ID
    if (state.sessionId.isEmpty) {
      smPrint('❌ No session ID available and no category set for new session');
      primarySnackBar(smNavigatorKey.currentContext!, message: 'Unable to send message: No session available');
      return;
    }

    smPrint('📤 Sending message to session: ${state.sessionId}');
    emit(state.copyWith(sendMessageStatus: BaseStatus.loading));
    try {
      final NetworkResult<CustomerSendMessageResponse> result;

      // get replied on message
      final repliedOnMessage = state.sessionMessages.firstWhereOrNull((element) => element.id == state.repliedOn);
      if (isAuthenticated) {
        result = await sl<SupportRepo>().customerSendMessage(
          sessionId: state.sessionId,
          message: message,
          contentType: contentType,
          reply: state.repliedOn != null
              ? SessionMessageReply(
                  message: repliedOnMessage?.content ?? '',
                  messageId: state.repliedOn!,
                  contentType: repliedOnMessage?.contentType.name.toUpperCase() ?? '',
                )
              : null,
        );
      } else {
        result = await sl<SupportRepo>().anonymousCustomerSendMessage(
          sessionId: state.sessionId,
          message: message,
          contentType: contentType,
          reply: state.repliedOn != null
              ? SessionMessageReply(
                  message: repliedOnMessage?.content ?? '',
                  messageId: state.repliedOn!,
                  contentType: repliedOnMessage?.contentType.name ?? '',
                )
              : null,
        );
      }

      result.when(
        success: (data) {
          smPrint('✅ Send Message Success: ${data.result.id}');
          smPrint('📝 Message content: ${data.result.content}');
          smPrint('👤 Sender type: ${data.result.senderType}');
          smPrint('📅 Created at: ${data.result.createdAt}');

          // Append the new message to the current list
          final List<SessionMessage> updatedMessages = List.from(state.sessionMessages);
          smPrint('📋 Current message count before adding: ${updatedMessages.length}');

          updatedMessages.add(data.result);
          smPrint('📋 Message count after adding: ${updatedMessages.length}');

          // Sort messages by creation time
          updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          smPrint('📋 Messages sorted by time');

          emit(
            state.copyWith(
              sendMessageStatus: BaseStatus.success,
              sessionMessages: updatedMessages,
              repliedOn: null,
              isResetRepliedOn: true,
            ),
          );

          smPrint('🎯 STATE UPDATED WITH NEW MESSAGE - UI should show ${updatedMessages.length} messages');
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(sendMessageStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(sendMessageStatus: BaseStatus.failure));
    }
  }

  /// Check if currently sending a message
  bool get isSendingMessage => state.sendMessageStatus.isLoading;

  /// Check if last send was successful
  bool get sendMessageSuccess => state.sendMessageStatus.isSuccess;

  /// Check if send message failed
  bool get sendMessageFailed => state.sendMessageStatus.isFailure;

  /// Rate the current session
  Future<void> rateSession({required int rating, String? comment}) async {
    smPrint('Rate Session: ${state.sessionId}, rating: $rating, comment: $comment');
    emit(state.copyWith(rateSessionStatus: BaseStatus.loading));
    try {
      final result = await sl<SupportRepo>().rateSession(sessionId: state.sessionId, rating: rating, comment: comment);

      result.when(
        success: (data) {
          smPrint('Rate Session Success: ${data.message}');
          List<SessionMessagesDoc> updatedSessionMessageDocs = [];
          updatedSessionMessageDocs.add(state.sessionMessageDoc.copyWith(isRatingRequired: false));

          emit(
            state.copyWith(
              rateSessionStatus: BaseStatus.success,
              isRatingRequiredFromSocket: false, // Reset WebSocket rating requirement
              sessionMessageDoc: updatedSessionMessageDocs.first,
            ),
          );

          // Update the session in SMSupportCubit to mark rating as no longer required
          smCubit.updateSessionRatingStatus(state.sessionId);
        },
        error: (error) {
          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
          emit(state.copyWith(rateSessionStatus: BaseStatus.failure));
        },
      );
    } catch (e) {
      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
      emit(state.copyWith(rateSessionStatus: BaseStatus.failure));
    }
  }

  /// Check if currently rating session
  bool get isRatingSession => state.rateSessionStatus.isLoading;

  /// Check if rating was successful
  bool get rateSessionSuccess => state.rateSessionStatus.isSuccess;

  /// Check if rating failed
  bool get rateSessionFailed => state.rateSessionStatus.isFailure;

  /// Set the message ID being replied to
  void setRepliedOn(String messageId) {
    smPrint('Setting replied on message: $messageId');
    emit(state.copyWith(repliedOn: messageId));
  }

  /// Clear the replied on message
  void clearRepliedOn() {
    smPrint('Clearing replied on message');
    emit(state.copyWith(repliedOn: null, isResetRepliedOn: true));
  }

  /// Get the message being replied to
  SessionMessage? get repliedOnMessage {
    if (state.repliedOn == null) return null;
    return findMessageById(state.repliedOn!);
  }

  /// Start WebSocket connection for real-time messages
  Future<void> startMessageStream({required String tenantId, String? customerId}) async {
    try {
      smPrint('Starting message stream for session: ${state.sessionId}');

      final webSocketService = sl<WebSocketService>();

      // Check if already connected to this session
      final expectedChannel = 'message_$tenantId${state.sessionId}${customerId ?? 'anonymous'}';
      if (webSocketService.isConnected && webSocketService.currentChannel == expectedChannel) {
        smPrint('Message stream already active for session: ${state.sessionId}');
        return;
      }

      // Connect to WebSocket
      await webSocketService.connectToSession(tenantId: tenantId, sessionId: state.sessionId, customerId: customerId);

      // Listen to incoming messages
      _messageStreamSubscription = webSocketService.messageStream?.listen(
        _onNewMessageReceived,
        onError: _onStreamError,
      );

      // Listen to rating requests
      _ratingRequestSubscription = webSocketService.ratingRequestStream?.listen(
        _onRatingRequestReceived,
        onError: _onStreamError,
      );

      smPrint('Message stream started successfully for session: ${state.sessionId}');
    } catch (e) {
      smPrint('Error starting message stream: $e');
      // primarySnackBar(smNavigatorKey.currentContext!, message: 'Failed to connect to real-time messaging');
    }
  }

  /// Handle new messages from WebSocket stream
  void _onNewMessageReceived(SessionMessage newMessage) {
    smPrint('🎉 NEW MESSAGE RECEIVED FROM WEBSOCKET STREAM!');
    smPrint('Message ID: ${newMessage.id}');
    smPrint('Message Content: ${newMessage.content}');
    smPrint('Sender Type: ${newMessage.senderType}');
    smPrint('Created At: ${newMessage.createdAt}');

    // Check if message already exists to avoid duplicates
    final existingMessage = findMessageById(newMessage.id);
    if (existingMessage != null) {
      smPrint('⚠️ Message already exists, skipping: ${newMessage.id}');
      return;
    }

    smPrint('✅ Adding new message to UI...');

    // Add the new message to the current list
    final List<SessionMessage> updatedMessages = List.from(state.sessionMessages);
    updatedMessages.add(newMessage);

    // Sort messages by creation time
    updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    smPrint('📋 Total messages after adding: ${updatedMessages.length}');

    // Update state with new message
    emit(state.copyWith(sessionMessages: updatedMessages));

    smPrint('✅ UI STATE UPDATED WITH NEW MESSAGE!');

    // Mark message as read if it's from admin and chat is active
    if (newMessage.senderType != SessionMessageSenderType.customer) {
      smPrint('📖 Marking admin message as read with debounce...');
      markMessagesAsReadDebounced();
    }
  }

  /// Handle rating requests from WebSocket stream
  void _onRatingRequestReceived(bool isRatingRequired) {
    smPrint('⭐ RATING REQUEST RECEIVED FROM WEBSOCKET STREAM!');
    smPrint('Is Rating Required: $isRatingRequired');

    // Update state with the rating requirement
    emit(state.copyWith(isRatingRequiredFromSocket: isRatingRequired));

    smPrint('✅ UI STATE UPDATED WITH RATING REQUEST!');
  }

  /// Handle stream errors
  void _onStreamError(dynamic error) {
    smPrint('❌ MESSAGE STREAM ERROR: $error');
    smPrint('Error type: ${error.runtimeType}');
    // Don't show error to user as this is background functionality
    // The app will continue to work with polling-based message updates
  }

  /// Stop WebSocket connection
  Future<void> stopMessageStream() async {
    try {
      smPrint('Stopping message stream for session: ${state.sessionId}');

      // Cancel subscriptions
      await _messageStreamSubscription?.cancel();
      _messageStreamSubscription = null;

      await _ratingRequestSubscription?.cancel();
      _ratingRequestSubscription = null;

      // Disconnect WebSocket
      final webSocketService = sl<WebSocketService>();
      await webSocketService.disconnect();

      smPrint('Message stream stopped for session: ${state.sessionId}');
    } catch (e) {
      smPrint('Error stopping message stream: $e');
    }
  }

  /// Send typing indicator through WebSocket
  // Future<void> sendTypingIndicatorViaWebSocket(bool isTyping) async {
  //   try {
  //     final webSocketService = sl<WebSocketService>();
  //     if (webSocketService.isConnected) {
  //       webSocketService.sendTypingIndicator(isTyping: isTyping);
  //       smPrint('Typing indicator sent via WebSocket: $isTyping');
  //     } else {
  //       smPrint('WebSocket not connected, skipping typing indicator');
  //     }
  //   } catch (e) {
  //     smPrint('Error sending typing indicator: $e');
  //   }
  // }

  /// Check if WebSocket is connected
  bool get isStreamConnected {
    try {
      final webSocketService = sl<WebSocketService>();
      return webSocketService.isConnected;
    } catch (e) {
      return false;
    }
  }

  //! Media Upload Methods -----------------------------------

  /// Pick Media From Gallery and upload
  /// Automatically detects file type and category from extension
  Future<String?> pickAndUploadMedia(BuildContext context, {bool isFile = false}) async {
    try {
      final result = isFile
          ? await PickerHelper.pickFile(context)
          : await PickerHelper.pickMediaWithValidation(context);

      if (result == null) return null;

      emit(state.copyWith(uploadFileStatus: BaseStatus.loading));

      //* Upload file to storage provider using new API
      // All files now use SESSION_MEDIA category
      final String? fileUrl = await MediaUpload.uploadFile(file: result.file, sessionId: state.sessionId);

      if (fileUrl != null) {
        emit(state.copyWith(uploadFileStatus: BaseStatus.success));

        // Automatically send the media message
        await _sendMediaMessage(fileUrl);

        return fileUrl;
      } else {
        emit(state.copyWith(uploadFileStatus: BaseStatus.failure));
        primarySnackBar(context, message: 'Failed to upload file. Please try again.');
        return null;
      }
    } catch (e) {
      emit(state.copyWith(uploadFileStatus: BaseStatus.failure));
      primarySnackBar(context, message: 'Error uploading file: ${e.toString()}');
      return null;
    }
  }

  /// Pick Image From camera and upload
  Future<String?> pickAndUploadCameraImage(BuildContext context) async {
    try {
      final result = await PickerHelper.pickImageFromCameraWithCategory(context);
      if (result == null) return null;

      emit(state.copyWith(uploadFileStatus: BaseStatus.loading));

      //* Upload file to storage provider using new API
      // All files now use SESSION_MEDIA category
      final String? fileUrl = await MediaUpload.uploadFile(file: result.file, sessionId: state.sessionId);

      if (fileUrl != null) {
        emit(state.copyWith(uploadFileStatus: BaseStatus.success));

        // Automatically send the media message
        await _sendMediaMessage(fileUrl);

        return fileUrl;
      } else {
        emit(state.copyWith(uploadFileStatus: BaseStatus.failure));
        primarySnackBar(context, message: 'Failed to upload image. Please try again.');
        return null;
      }
    } catch (e) {
      emit(state.copyWith(uploadFileStatus: BaseStatus.failure));
      primarySnackBar(context, message: 'Error uploading image: ${e.toString()}');
      return null;
    }
  }

  /// Send media message after successful upload
  Future<void> _sendMediaMessage(String fileUrl) async {
    // Determine content type based on file URL
    String contentType = 'IMAGE';
    if (Utils.isImageUrl(fileUrl)) {
      contentType = 'IMAGE';
    } else if (Utils.isVideoUrl(fileUrl)) {
      contentType = 'VIDEO';
    } else if (fileUrl.endsWith('.mp3') || fileUrl.endsWith('.wav') || fileUrl.endsWith('.m4a')) {
      contentType = 'AUDIO';
    } else if (Utils.isFileUrl(fileUrl)) {
      contentType = 'FILE';
    }
    // extract file name
    final fileName = ImageUrlResolver.extractFileName(fileUrl);

    // Send the media message
    // TODO: Add fileSize metadata support when sendMessage accepts it
    await sendMessage(message: fileName, contentType: contentType);
  }

  /// Check if currently uploading a file
  bool get isUploadingFile => state.uploadFileStatus.isLoading;

  /// Check if last upload was successful
  bool get uploadFileSuccess => state.uploadFileStatus.isSuccess;

  /// Check if upload failed
  bool get uploadFileFailed => state.uploadFileStatus.isFailure;

  @override
  Future<void> close() async {
    // Stop message stream before closing cubit
    await stopMessageStream();

    // Cancel debounce timer
    _markAsReadDebounceTimer?.cancel();

    return super.close();
  }
}
