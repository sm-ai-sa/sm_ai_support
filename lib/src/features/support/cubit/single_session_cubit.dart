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
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/support/cubit/single_session_state.dart';

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

  /// Update message delivery status for a specific message
  void updateMessageDeliveryStatus(String messageId, {required bool isDelivered}) {
    final updatedMessages = state.sessionMessages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(isDelivered: isDelivered);
      }
      return msg;
    }).toList();

    emit(state.copyWith(sessionMessages: updatedMessages));
    smPrint('📬 Updated delivery status for message: $messageId to $isDelivered');
  }

  /// Update message read status for a specific message
  void updateMessageReadStatus(String messageId, {required bool isRead}) {
    final updatedMessages = state.sessionMessages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(isRead: isRead, isDelivered: true); // If read, it's also delivered
      }
      return msg;
    }).toList();

    emit(state.copyWith(sessionMessages: updatedMessages));
    smPrint('👁️ Updated read status for message: $messageId to $isRead');
  }

  /// Batch update multiple message statuses (useful after reconnection)
  void batchUpdateMessageStatuses(List<String> messageIds, {bool? isRead, bool? isDelivered}) {
    var updatedMessages = state.sessionMessages;

    for (final messageId in messageIds) {
      updatedMessages = updatedMessages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(
            isRead: isRead ?? msg.isRead,
            isDelivered: isDelivered ?? msg.isDelivered,
          );
        }
        return msg;
      }).toList();
    }

    emit(state.copyWith(sessionMessages: updatedMessages));
    smPrint('📦 Batch updated ${messageIds.length} message statuses');
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
  /// Uses optimistic UI updates - message appears immediately before API response
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

    // Get replied on message for reply functionality
    final repliedOnMessage = state.sessionMessages.firstWhereOrNull((element) => element.id == state.repliedOn);

    // Create optimistic message with temporary ID
    final tempMessageId = Utils.getTempMessageId;
    final optimisticMessage = SessionMessage(
      id: tempMessageId,
      content: message,
      contentType: SessionMessageContentType.fromString(contentType),
      senderType: SessionMessageSenderType.customer,
      isRead: false,
      isDelivered: false,
      isFailed: false,
      createdAt: DateTime.now(),
      isOptimistic: true,
      reply: state.repliedOn != null
          ? SessionMessageReply(
              message: repliedOnMessage?.content ?? '',
              messageId: state.repliedOn!,
              contentType: repliedOnMessage?.contentType.name.toUpperCase() ?? '',
            )
          : null,
    );

    smPrint('💫 Created optimistic message with temp ID: $tempMessageId');

    // Add optimistic message to UI immediately
    final List<SessionMessage> messagesWithOptimistic = List.from(state.sessionMessages);
    messagesWithOptimistic.add(optimisticMessage);
    messagesWithOptimistic.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    emit(state.copyWith(
      sendMessageStatus: BaseStatus.loading,
      sessionMessages: messagesWithOptimistic,
    ));

    smPrint('📤 Sending message to session: ${state.sessionId}');
    try {
      final NetworkResult<CustomerSendMessageResponse> result;

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

          // Replace optimistic message with real message from server
          final List<SessionMessage> updatedMessages = List.from(state.sessionMessages);
          smPrint('📋 Replacing optimistic message $tempMessageId with real message ${data.result.id}');

          // Remove the optimistic message
          updatedMessages.removeWhere((msg) => msg.id == tempMessageId);

          // Add the real message
          updatedMessages.add(data.result);

          // Sort messages by creation time
          updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          smPrint('📋 Message replacement complete. Total messages: ${updatedMessages.length}');

          emit(
            state.copyWith(
              sendMessageStatus: BaseStatus.success,
              sessionMessages: updatedMessages,
              repliedOn: null,
              isResetRepliedOn: true,
            ),
          );

          smPrint('🎯 STATE UPDATED WITH REAL MESSAGE - UI should show ${updatedMessages.length} messages');
        },
        error: (error) {
          smPrint('❌ Send Message Failed: ${error.failure.error}');

          // Mark optimistic message as failed instead of removing it
          final List<SessionMessage> updatedMessages = List.from(state.sessionMessages);
          final failedMessageIndex = updatedMessages.indexWhere((msg) => msg.id == tempMessageId);

          if (failedMessageIndex != -1) {
            updatedMessages[failedMessageIndex] = updatedMessages[failedMessageIndex].copyWith(
              isFailed: true,
              isOptimistic: false, // No longer optimistic, now a failed message
            );
            smPrint('💥 Marked message as failed: $tempMessageId');
          }

          emit(state.copyWith(
            sendMessageStatus: BaseStatus.failure,
            sessionMessages: updatedMessages,
          ));

          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
        },
      );
    } catch (e) {
      smPrint('💥 Send Message Exception: $e');

      // Mark optimistic message as failed
      final List<SessionMessage> updatedMessages = List.from(state.sessionMessages);
      final failedMessageIndex = updatedMessages.indexWhere((msg) => msg.id == tempMessageId);

      if (failedMessageIndex != -1) {
        updatedMessages[failedMessageIndex] = updatedMessages[failedMessageIndex].copyWith(
          isFailed: true,
          isOptimistic: false,
        );
      }

      emit(state.copyWith(
        sendMessageStatus: BaseStatus.failure,
        sessionMessages: updatedMessages,
      ));

      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
    }
  }

  /// Check if currently sending a message
  bool get isSendingMessage => state.sendMessageStatus.isLoading;

  /// Check if last send was successful
  bool get sendMessageSuccess => state.sendMessageStatus.isSuccess;

  /// Check if send message failed
  bool get sendMessageFailed => state.sendMessageStatus.isFailure;

  /// Retry sending a failed message
  /// Takes the failed message and attempts to resend it
  Future<void> retryFailedMessage(SessionMessage failedMessage) async {
    if (!failedMessage.isFailed) {
      smPrint('⚠️ Cannot retry message that is not marked as failed');
      return;
    }

    smPrint('🔄 Retrying failed message: ${failedMessage.id}');

    // Mark the message as sending again (optimistic)
    final List<SessionMessage> updatedMessages = List.from(state.sessionMessages);
    final messageIndex = updatedMessages.indexWhere((msg) => msg.id == failedMessage.id);

    if (messageIndex == -1) {
      smPrint('❌ Failed message not found in state');
      return;
    }

    // Update message to show it's being retried
    updatedMessages[messageIndex] = failedMessage.copyWith(
      isFailed: false,
      isOptimistic: true,
    );

    emit(state.copyWith(
      sendMessageStatus: BaseStatus.loading,
      sessionMessages: updatedMessages,
    ));

    final isAuthenticated = AuthManager.isAuthenticated;

    try {
      final NetworkResult<CustomerSendMessageResponse> result;

      if (isAuthenticated) {
        result = await sl<SupportRepo>().customerSendMessage(
          sessionId: state.sessionId,
          message: failedMessage.content,
          contentType: failedMessage.contentType.name.toUpperCase(),
          reply: failedMessage.reply,
        );
      } else {
        result = await sl<SupportRepo>().anonymousCustomerSendMessage(
          sessionId: state.sessionId,
          message: failedMessage.content,
          contentType: failedMessage.contentType.name.toUpperCase(),
          reply: failedMessage.reply,
        );
      }

      result.when(
        success: (data) {
          smPrint('✅ Retry Success: ${data.result.id}');

          // Replace failed message with real message from server
          final List<SessionMessage> finalMessages = List.from(state.sessionMessages);
          finalMessages.removeWhere((msg) => msg.id == failedMessage.id);
          finalMessages.add(data.result);
          finalMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          emit(
            state.copyWith(
              sendMessageStatus: BaseStatus.success,
              sessionMessages: finalMessages,
            ),
          );

          smPrint('🎯 Retry completed successfully');
        },
        error: (error) {
          smPrint('❌ Retry Failed: ${error.failure.error}');

          // Mark message as failed again
          final List<SessionMessage> failedMessages = List.from(state.sessionMessages);
          final failedIndex = failedMessages.indexWhere((msg) => msg.id == failedMessage.id);

          if (failedIndex != -1) {
            failedMessages[failedIndex] = failedMessages[failedIndex].copyWith(
              isFailed: true,
              isOptimistic: false,
            );
          }

          emit(state.copyWith(
            sendMessageStatus: BaseStatus.failure,
            sessionMessages: failedMessages,
          ));

          primarySnackBar(smNavigatorKey.currentContext!, message: error.failure.error);
        },
      );
    } catch (e) {
      smPrint('💥 Retry Exception: $e');

      // Mark message as failed
      final List<SessionMessage> failedMessages = List.from(state.sessionMessages);
      final failedIndex = failedMessages.indexWhere((msg) => msg.id == failedMessage.id);

      if (failedIndex != -1) {
        failedMessages[failedIndex] = failedMessages[failedIndex].copyWith(
          isFailed: true,
          isOptimistic: false,
        );
      }

      emit(state.copyWith(
        sendMessageStatus: BaseStatus.failure,
        sessionMessages: failedMessages,
      ));

      primarySnackBar(smNavigatorKey.currentContext!, message: e.toString());
    }
  }

  /// Delete a failed message from the list
  void deleteFailedMessage(String messageId) {
    final updatedMessages = state.sessionMessages.where((msg) => msg.id != messageId).toList();
    emit(state.copyWith(sessionMessages: updatedMessages));
    smPrint('🗑️ Deleted failed message: $messageId');
  }

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

    // Check if message already exists by ID to avoid duplicates
    final existingMessage = findMessageById(newMessage.id);
    if (existingMessage != null) {
      smPrint('⚠️ Message with ID already exists, checking if it needs update: ${newMessage.id}');

      // Check if existing message needs status update (e.g., delivery/read receipts)
      if (existingMessage.isRead != newMessage.isRead ||
          existingMessage.isDelivered != newMessage.isDelivered) {
        smPrint('📝 Updating message status: isRead=${newMessage.isRead}, isDelivered=${newMessage.isDelivered}');

        final updatedMessages = state.sessionMessages.map((msg) {
          if (msg.id == newMessage.id) {
            return msg.copyWith(
              isRead: newMessage.isRead,
              isDelivered: newMessage.isDelivered,
            );
          }
          return msg;
        }).toList();

        emit(state.copyWith(sessionMessages: updatedMessages));
        return;
      }

      smPrint('⏭️ Message unchanged, skipping: ${newMessage.id}');
      return;
    }

    // Check for duplicate by content and timestamp (edge case: same message sent multiple times)
    final isDuplicateByContent = state.sessionMessages.any((msg) =>
        msg.content == newMessage.content &&
        msg.senderType == newMessage.senderType &&
        msg.createdAt.difference(newMessage.createdAt).abs().inSeconds < 2 &&
        !msg.isTemporary // Don't match against temporary optimistic messages
    );

    if (isDuplicateByContent) {
      smPrint('⚠️ Duplicate message detected by content and timestamp, skipping');
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

  /// Pick Media From Gallery and upload with optimistic UI
  /// Automatically detects file type and category from extension
  Future<String?> pickAndUploadMedia(BuildContext context, {bool isFile = false}) async {
    try {
      final result = isFile
          ? await PickerHelper.pickFile(context)
          : await PickerHelper.pickMediaWithValidation(context);

      if (result == null) return null;

      // Determine content type
      String contentType = 'IMAGE';
      final filePath = result.file.path;
      if (Utils.isImageFile(result.file)) {
        contentType = 'IMAGE';
      } else if (Utils.isVideoFile(result.file)) {
        contentType = 'VIDEO';
      } else if (filePath.endsWith('.mp3') || filePath.endsWith('.wav') || filePath.endsWith('.m4a')) {
        contentType = 'AUDIO';
      } else {
        contentType = 'FILE';
      }

      final fileName = result.file.path.split('/').last;
      final localFilePath = result.file.path;

      // Create optimistic message with temporary ID showing upload in progress
      final tempMessageId = Utils.getTempMessageId;
      final optimisticMessage = SessionMessage(
        id: tempMessageId,
        content: localFilePath, // Use local file path so it can be displayed as preview
        contentType: SessionMessageContentType.fromString(contentType),
        senderType: SessionMessageSenderType.customer,
        isRead: false,
        isDelivered: false,
        isFailed: false,
        createdAt: DateTime.now(),
        isOptimistic: true,
        metadata: {
          'uploading': true,
          'progress': 0.0,
          'localPath': localFilePath,
          'fileName': fileName,
        },
      );

      // Add optimistic message to UI immediately
      final messagesWithOptimistic = List<SessionMessage>.from(state.sessionMessages);
      messagesWithOptimistic.add(optimisticMessage);
      messagesWithOptimistic.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      emit(state.copyWith(
        uploadFileStatus: BaseStatus.loading,
        uploadProgress: 0.0,
        sessionMessages: messagesWithOptimistic,
      ));

      //* Upload file to storage provider using new API
      // All files now use SESSION_MEDIA category
      // TODO: Add progress callback support to MediaUpload.uploadFile for real-time progress
      final String? fileUrl = await MediaUpload.uploadFile(
        file: result.file,
        sessionId: state.sessionId,
      );

      if (fileUrl != null) {
        emit(state.copyWith(uploadFileStatus: BaseStatus.success, uploadProgress: 1.0));

        // Remove optimistic message (will be replaced by actual message from sendMessage)
        final messagesWithoutOptimistic = state.sessionMessages.where((msg) => msg.id != tempMessageId).toList();
        emit(state.copyWith(sessionMessages: messagesWithoutOptimistic));

        // Automatically send the media message
        await _sendMediaMessage(fileUrl);

        return fileUrl;
      } else {
        // Mark optimistic message as failed
        final failedMessages = state.sessionMessages.map((msg) {
          if (msg.id == tempMessageId) {
            return msg.copyWith(isFailed: true, isOptimistic: false);
          }
          return msg;
        }).toList();

        emit(state.copyWith(
          uploadFileStatus: BaseStatus.failure,
          uploadProgress: 0.0,
          sessionMessages: failedMessages,
        ));

        primarySnackBar(context, message: 'Failed to upload file. Please try again.');
        return null;
      }
    } catch (e) {
      emit(state.copyWith(uploadFileStatus: BaseStatus.failure, uploadProgress: 0.0));
      primarySnackBar(context, message: 'Error uploading file: ${e.toString()}');
      return null;
    }
  }

  /// Pick Image From camera and upload with optimistic UI
  Future<String?> pickAndUploadCameraImage(BuildContext context) async {
    try {
      final result = await PickerHelper.pickImageFromCameraWithCategory(context);
      if (result == null) return null;

      final fileName = result.file.path.split('/').last;
      final localFilePath = result.file.path;

      // Create optimistic message with temporary ID showing upload in progress
      final tempMessageId = Utils.getTempMessageId;
      final optimisticMessage = SessionMessage(
        id: tempMessageId,
        content: localFilePath, // Use local file path for preview
        contentType: SessionMessageContentType.image,
        senderType: SessionMessageSenderType.customer,
        isRead: false,
        isDelivered: false,
        isFailed: false,
        createdAt: DateTime.now(),
        isOptimistic: true,
        metadata: {
          'uploading': true,
          'progress': 0.0,
          'localPath': localFilePath,
          'fileName': fileName,
        },
      );

      // Add optimistic message to UI immediately
      final messagesWithOptimistic = List<SessionMessage>.from(state.sessionMessages);
      messagesWithOptimistic.add(optimisticMessage);
      messagesWithOptimistic.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      emit(state.copyWith(
        uploadFileStatus: BaseStatus.loading,
        uploadProgress: 0.0,
        sessionMessages: messagesWithOptimistic,
      ));

      //* Upload file to storage provider using new API
      // All files now use SESSION_MEDIA category
      final String? fileUrl = await MediaUpload.uploadFile(file: result.file, sessionId: state.sessionId);

      if (fileUrl != null) {
        emit(state.copyWith(uploadFileStatus: BaseStatus.success, uploadProgress: 1.0));

        // Remove optimistic message (will be replaced by actual message from sendMessage)
        final messagesWithoutOptimistic = state.sessionMessages.where((msg) => msg.id != tempMessageId).toList();
        emit(state.copyWith(sessionMessages: messagesWithoutOptimistic));

        // Automatically send the media message
        await _sendMediaMessage(fileUrl);

        return fileUrl;
      } else {
        // Mark optimistic message as failed
        final failedMessages = state.sessionMessages.map((msg) {
          if (msg.id == tempMessageId) {
            return msg.copyWith(isFailed: true, isOptimistic: false);
          }
          return msg;
        }).toList();

        emit(state.copyWith(
          uploadFileStatus: BaseStatus.failure,
          uploadProgress: 0.0,
          sessionMessages: failedMessages,
        ));

        primarySnackBar(context, message: 'Failed to upload image. Please try again.');
        return null;
      }
    } catch (e) {
      emit(state.copyWith(uploadFileStatus: BaseStatus.failure, uploadProgress: 0.0));
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

    // Send the media message with the full URL (not just filename)
    // The full URL allows the image widget to display it directly without API resolution
    // TODO: Add fileSize metadata support when sendMessage accepts it
    await sendMessage(message: fileUrl, contentType: contentType);
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
