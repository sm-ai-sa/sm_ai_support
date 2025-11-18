import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class SingleSessionState extends Equatable {
  /// The ID of the current session
  final String sessionId;
  
  /// Status for getting session messages
  final BaseStatus getSessionMessagesStatus;

  /// Status for loading more (older) messages via pagination
  final BaseStatus loadMoreMessagesStatus;

  /// Status for sending messages
  final BaseStatus sendMessageStatus;

  /// Status for rating session
  final BaseStatus rateSessionStatus;

  /// Status for uploading files
  final BaseStatus uploadFileStatus;

  /// Upload progress percentage (0.0 to 1.0)
  final double uploadProgress;

  /// Status for creating a new session
  final BaseStatus createSessionStatus;

  /// Whether there are more messages to load (false when API returns empty list)
  final bool hasMoreMessages;
  
  /// ID of the message being replied to
  final String? repliedOn;
  
  /// List of messages in the current session (flattened from all docs)
  final List<SessionMessage> sessionMessages;
  
  /// Raw session message documents from API
  final SessionMessagesDoc sessionMessageDoc;
  
  /// Category for new sessions that haven't been created yet
  final CategoryModel? categoryForNewSession;
  
  /// Whether rating is currently required for this session (from WebSocket)
  final bool isRatingRequiredFromSocket;

  const SingleSessionState({
    required this.sessionId,
    this.getSessionMessagesStatus = BaseStatus.initial,
    this.loadMoreMessagesStatus = BaseStatus.initial,
    this.sendMessageStatus = BaseStatus.initial,
    this.rateSessionStatus = BaseStatus.initial,
    this.uploadFileStatus = BaseStatus.initial,
    this.uploadProgress = 0.0,
    this.createSessionStatus = BaseStatus.initial,
    this.hasMoreMessages = true,
    this.repliedOn,
    this.sessionMessages = const [],
    this.sessionMessageDoc = const SessionMessagesDoc(id: '', messages: [], isRatingRequired: false),
    this.categoryForNewSession,
    this.isRatingRequiredFromSocket = false,
  });

  SingleSessionState copyWith({
    String? sessionId,
    BaseStatus? getSessionMessagesStatus,
    BaseStatus? loadMoreMessagesStatus,
    BaseStatus? sendMessageStatus,
    BaseStatus? rateSessionStatus,
    BaseStatus? uploadFileStatus,
    double? uploadProgress,
    BaseStatus? createSessionStatus,
    bool? hasMoreMessages,
    String? repliedOn,
    bool? isResetRepliedOn,
    List<SessionMessage>? sessionMessages,
    SessionMessagesDoc? sessionMessageDoc,
    CategoryModel? categoryForNewSession,
    bool? isResetCategory,
    bool? isRatingRequiredFromSocket,
  }) {
    return SingleSessionState(
      sessionId: sessionId ?? this.sessionId,
      getSessionMessagesStatus: getSessionMessagesStatus ?? this.getSessionMessagesStatus,
      loadMoreMessagesStatus: loadMoreMessagesStatus ?? this.loadMoreMessagesStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      rateSessionStatus: rateSessionStatus ?? this.rateSessionStatus,
      uploadFileStatus: uploadFileStatus ?? this.uploadFileStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      createSessionStatus: createSessionStatus ?? this.createSessionStatus,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      repliedOn: repliedOn ?? (isResetRepliedOn == true ? null : this.repliedOn),
      sessionMessages: sessionMessages ?? this.sessionMessages,
      sessionMessageDoc: sessionMessageDoc ?? this.sessionMessageDoc,
      categoryForNewSession: categoryForNewSession ?? (isResetCategory == true ? null : this.categoryForNewSession),
      isRatingRequiredFromSocket: isRatingRequiredFromSocket ?? this.isRatingRequiredFromSocket,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        getSessionMessagesStatus,
        loadMoreMessagesStatus,
        sendMessageStatus,
        rateSessionStatus,
        uploadFileStatus,
        uploadProgress,
        createSessionStatus,
        hasMoreMessages,
        repliedOn,
        sessionMessages,
        sessionMessageDoc,
        categoryForNewSession,
        isRatingRequiredFromSocket,
      ];

  /// Convenience getters
  bool get isLoading => getSessionMessagesStatus.isLoading;
  bool get hasError => getSessionMessagesStatus.isFailure;
  bool get hasMessages => sessionMessages.isNotEmpty;
  bool get isEmpty => sessionMessages.isEmpty;

  /// Get unread messages count
  int get unreadCount {
    return sessionMessages
        .where((message) => !message.isRead && message.senderType != 'CUSTOMER')
        .length;
  }

  /// Get customer messages
  List<SessionMessage> get customerMessages {
    return sessionMessages
        .where((message) => message.senderType == 'CUSTOMER')
        .toList();
  }

  /// Get admin messages
  List<SessionMessage> get adminMessages {
    return sessionMessages
        .where((message) => message.senderType != 'CUSTOMER')
        .toList();
  }

  /// Get failed messages
  List<SessionMessage> get failedMessages {
    return sessionMessages.where((message) => message.isFailed).toList();
  }

  /// Get last message
  SessionMessage? get lastMessage {
    if (sessionMessages.isEmpty) return null;
    return sessionMessages.last;
  }

  /// Get first message
  SessionMessage? get firstMessage {
    if (sessionMessages.isEmpty) return null;
    return sessionMessages.first;
  }

  /// Check if session has any failed messages
  bool get hasFailedMessages => failedMessages.isNotEmpty;

  /// Check if session has unread messages
  bool get hasUnreadMessages => unreadCount > 0;
  
  /// Check if this is a new session that hasn't been created yet
  bool get isNewSession => sessionId.isEmpty && categoryForNewSession != null;
  
  /// Check if session creation is in progress
  bool get isCreatingSession => createSessionStatus.isLoading;
  
  /// Check if session creation was successful
  bool get sessionCreated => createSessionStatus.isSuccess;
  
  /// Check if session creation failed
  bool get sessionCreationFailed => createSessionStatus.isFailure;
  
  /// Check if rating is required based on session message docs or WebSocket response
  bool get isRatingRequired {
    smPrint('isRatingRequired: ${sessionMessageDoc.isRatingRequired} || $isRatingRequiredFromSocket');
    return sessionMessageDoc.isRatingRequired || isRatingRequiredFromSocket;
  }
}
