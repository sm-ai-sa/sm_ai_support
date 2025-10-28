import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

/// Model for a reply within a session message
class SessionMessageReply extends Equatable {
  final String message;
  final String messageId;
  final String contentType;

  const SessionMessageReply({
    required this.message,
    required this.messageId,
    required this.contentType,
  });

  factory SessionMessageReply.fromJson(Map<String, dynamic> json) {
    return SessionMessageReply(
      message: json['message'] as String,
      messageId: json['messageId'] as String,
      contentType: json['contentType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'messageId': messageId,
      'contentType': contentType,
    };
  }

  @override
  List<Object?> get props => [message, messageId, contentType];
}

/// Model for individual message within a session
class SessionMessage extends Equatable {
  final String id;
  final String content;
  final SessionMessageContentType contentType;
  final SessionMessageSenderType senderType;
  final bool isRead;
  final bool isDelivered;
  final bool isFailed;
  final SessionMessageReply? reply;
  final DateTime createdAt;
  final dynamic admin; // Can be null or admin object
  final Map<String, dynamic>? metadata; // For file size and other metadata
  final bool isOptimistic; // For optimistic UI updates

  const SessionMessage({
    required this.id,
    required this.content,
    required this.contentType,
    required this.senderType,
    required this.isRead,
    required this.isDelivered,
    required this.isFailed,
    this.reply,
    required this.createdAt,
    this.admin,
    this.metadata,
    this.isOptimistic = false,
  });

  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    return SessionMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      contentType: SessionMessageContentType.fromString(json['contentType'] as String),
      senderType: SessionMessageSenderType.fromString(json['senderType'] as String),
      isRead: json['isRead'] as bool,
      isDelivered: json['isDelivered'] as bool,
      isFailed: json['isFailed'] as bool,
      reply: json['reply'] != null 
          ? SessionMessageReply.fromJson(json['reply'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now(),
      admin: json['admin'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      isOptimistic: json['_optimistic'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'contentType': contentType.name,
      'senderType': senderType.name,
      'isRead': isRead,
      'isDelivered': isDelivered,
      'isFailed': isFailed,
      'reply': reply?.toJson(),
      'createdAt': createdAt,
      'admin': admin,
      'metadata': metadata,
      '_optimistic': isOptimistic,
    };
  }

  /// Get file size from metadata (in bytes)
  int? get fileSize => metadata?['fileSize'] as int?;

  @override
  List<Object?> get props => [
        id,
        content,
        contentType,
        senderType,
        isRead,
        isDelivered,
        isFailed,
        reply,
        createdAt,
        admin,
        metadata,
        isOptimistic,
      ];
}

/// Model for a session messages document containing all messages for a session
class SessionMessagesDoc extends Equatable {
  final String id;
  final List<SessionMessage> messages;
  final bool isRatingRequired;

  const SessionMessagesDoc({
    required this.id,
    required this.messages,
    required this.isRatingRequired,
  });

  factory SessionMessagesDoc.fromJson(Map<String, dynamic> json) {
    return SessionMessagesDoc(
      id: json['id'] as String,
      messages: (json['messages'] as List)
          .map((e) => SessionMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      isRatingRequired: (json['isRatingRequired'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messages': messages.map((e) => e.toJson()).toList(),
      'isRatingRequired': isRatingRequired,
    };
  }

  copyWith({
    bool? isRatingRequired,
  }) {
    return SessionMessagesDoc(
      id: id,
      messages: messages,
      isRatingRequired: isRatingRequired ?? this.isRatingRequired,
    );
  }

  @override
  List<Object?> get props => [id, messages, isRatingRequired];
}

/// Response wrapper for session messages API
class SessionMessagesResponse extends Equatable {
  final List<SessionMessagesDoc> result;
  final int statusCode;

  const SessionMessagesResponse({
    required this.result,
    required this.statusCode,
  });

  factory SessionMessagesResponse.fromJson(Map<String, dynamic> json) {
    return SessionMessagesResponse(
      result: (json['result'] as List)
          .map((e) => SessionMessagesDoc.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusCode: json['statusCode'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.map((e) => e.toJson()).toList(),
      'statusCode': statusCode,
    };
  }

  @override
  List<Object?> get props => [result, statusCode];
}

/// Request model for customer send message API
class CustomerSendMessageRequest extends Equatable {
  final String sessionId;
  final String message;
  final String contentType;
  final SessionMessageReply? reply;

  const CustomerSendMessageRequest({
    required this.sessionId,
    required this.message,
    required this.contentType,
    this.reply,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'sessionId': sessionId,
      'message': message,
      'contentType': contentType,
    };
    
    if (reply != null) {
      json['reply'] = reply!.toJson();
    }
    
    return json;
  }

  @override
  List<Object?> get props => [sessionId, message, contentType, reply];
}

/// Response model for customer send message API
class CustomerSendMessageResponse extends Equatable {
  final SessionMessage result;
  final int statusCode;

  const CustomerSendMessageResponse({
    required this.result,
    required this.statusCode,
  });

  factory CustomerSendMessageResponse.fromJson(Map<String, dynamic> json) {
    return CustomerSendMessageResponse(
      result: SessionMessage.fromJson(json['result'] as Map<String, dynamic>),
      statusCode: json['statusCode'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.toJson(),
      'statusCode': statusCode,
    };
  }

  @override
  List<Object?> get props => [result, statusCode];
}
