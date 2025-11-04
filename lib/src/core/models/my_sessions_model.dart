import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/sm_ai_support.dart';

/// Model for individual session in my sessions list
class MySessionModel extends Equatable {
  final String id;
  final SessionStatus status;
  final String createdAt;
  final bool isRatingRequired;
  final CategoryModel category;
  final MySessionMetadata metadata;

  const MySessionModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.isRatingRequired,
    required this.category,
    required this.metadata,
  });

  factory MySessionModel.fromJson(Map<String, dynamic> json) {
    return MySessionModel(
      id: json['id'] as String,
      status: SessionStatus.fromString(json['status'] as String),
      createdAt: json['createdAt'] as String,
      isRatingRequired: json['isRatingRequired'] as bool? ?? false,
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      metadata: MySessionMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'createdAt': createdAt,
      'isRatingRequired': isRatingRequired,
      'category': category.toJson(),
      'metadata': metadata.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, status, createdAt, category, metadata];

  // copy with
  MySessionModel copyWith({
    String? id,
    SessionStatus? status,
    String? createdAt,
    bool? isRatingRequired,
    CategoryModel? category,
    MySessionMetadata? metadata,
  }) {
    return MySessionModel(
      id: id ?? this.id,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isRatingRequired: isRatingRequired ?? this.isRatingRequired,
      category: category ?? this.category,
      metadata:
          metadata?.copyWith(
            id: metadata.id,
            lastMessageContent: metadata.lastMessageContent,
            unreadCount: metadata.unreadCount,
          ) ??
          this.metadata,
    );
  }

  // Convert MySessionModel to SessionModel for compatibility
  SessionModel toSessionModel() {
    return SessionModel(
      id: id,
      createdAt: createdAt,
      updatedAt: createdAt, // Use createdAt as fallback
      status: status,
      isEscalated: false, // Default values for missing fields
      isReopened: false,
      customerId: null,
      tenantId: int.tryParse(smCubit.state.currentTenant?.tenantId ?? '0') ?? 0,
      categoryId: category.id,
      channel: 'WEB', // Default channel
      direction: 'INBOUND', // Default direction
      viewId: '', // Default viewId
      adminId: null,
      conversationEndedAt: null,
      intakes: null,
      deletedAt: null,
    );
  }
}

/// Metadata for a session containing last message and unread count
class MySessionMetadata extends Equatable {
  final String id;
  final String lastMessageContent;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const MySessionMetadata({
    required this.id,
    required this.lastMessageContent,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory MySessionMetadata.fromJson(Map<String, dynamic> json) {
    return MySessionMetadata(
      id: json['id'] ?? '',
      lastMessageContent: json['lastMessageContent'] ?? '',
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt'] as String) : null,
      unreadCount: json['customerUnreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastMessageContent': lastMessageContent,
      'lastMessageAt': lastMessageAt,
      'customerUnreadCount': unreadCount,
    };
  }

  @override
  List<Object?> get props => [id, lastMessageContent, lastMessageAt, unreadCount];

  MySessionMetadata copyWith({String? id, String? lastMessageContent, DateTime? lastMessageAt, int? unreadCount}) {
    return MySessionMetadata(
      id: id ?? this.id,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Response wrapper for my sessions API
class MySessionsResponse extends Equatable {
  final List<MySessionModel> result;
  final int statusCode;

  const MySessionsResponse({required this.result, required this.statusCode});

  factory MySessionsResponse.fromJson(Map<String, dynamic> json) {
    return MySessionsResponse(
      result: json['result'] != null
          ? (json['result'] as List).map((e) => MySessionModel.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      statusCode: json['statusCode'] != null ? json['statusCode'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'result': result.map((e) => e.toJson()).toList(), 'statusCode': statusCode};
  }

  @override
  List<Object?> get props => [result, statusCode];
}

/// Response for unread sessions count
class UnreadSessionsResponse extends Equatable {
  final int result;
  final int statusCode;

  const UnreadSessionsResponse({required this.result, required this.statusCode});

  factory UnreadSessionsResponse.fromJson(Map<String, dynamic> json) {
    return UnreadSessionsResponse(result: json['result'] as int, statusCode: json['statusCode'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'result': result, 'statusCode': statusCode};
  }

  @override
  List<Object?> get props => [result, statusCode];
}
