import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

class SingleSessionState extends Equatable {
  /// The ID of the current session
  final String sessionId;
  
  /// Status for getting session messages
  final BaseStatus getSessionMessagesStatus;
  
  /// Status for sending messages
  final BaseStatus sendMessageStatus;
  
  /// Status for rating session
  final BaseStatus rateSessionStatus;
  
  /// Status for uploading files
  final BaseStatus uploadFileStatus;
  
  /// ID of the message being replied to
  final String? repliedOn;
  
  /// List of messages in the current session (flattened from all docs)
  final List<SessionMessage> sessionMessages;
  
  /// Raw session message documents from API
  final List<SessionMessagesDoc> sessionMessageDocs;

  const SingleSessionState({
    required this.sessionId,
    this.getSessionMessagesStatus = BaseStatus.initial,
    this.sendMessageStatus = BaseStatus.initial,
    this.rateSessionStatus = BaseStatus.initial,
    this.uploadFileStatus = BaseStatus.initial,
    this.repliedOn,
    this.sessionMessages = const [],
    this.sessionMessageDocs = const [],
  });

  SingleSessionState copyWith({
    String? sessionId,
    BaseStatus? getSessionMessagesStatus,
    BaseStatus? sendMessageStatus,
    BaseStatus? rateSessionStatus,
    BaseStatus? uploadFileStatus,
    String? repliedOn,
    bool? isResetRepliedOn,
    List<SessionMessage>? sessionMessages,
    List<SessionMessagesDoc>? sessionMessageDocs,
  }) {
    return SingleSessionState(
      sessionId: sessionId ?? this.sessionId,
      getSessionMessagesStatus: getSessionMessagesStatus ?? this.getSessionMessagesStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      rateSessionStatus: rateSessionStatus ?? this.rateSessionStatus,
      uploadFileStatus: uploadFileStatus ?? this.uploadFileStatus,
      repliedOn: repliedOn ?? (isResetRepliedOn == true ? null : this.repliedOn),
      sessionMessages: sessionMessages ?? this.sessionMessages,
      sessionMessageDocs: sessionMessageDocs ?? this.sessionMessageDocs,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        getSessionMessagesStatus,
        sendMessageStatus,
        rateSessionStatus,
        uploadFileStatus,
        repliedOn,
        sessionMessages,
        sessionMessageDocs,
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
}
