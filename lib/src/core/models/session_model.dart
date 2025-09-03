import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/sm_ai_support.dart';


class SessionModel extends Equatable {
  final String createdAt;
  final String updatedAt;
  final String id;
  final SessionStatus status;
  final bool isEscalated;
  final bool isReopened;
  final String? customerId;
  final int tenantId;
  final int categoryId;
  final String channel;
  final String direction;
  final String viewId;
  final String? adminId;
  final String? conversationEndedAt;
  final dynamic intakes;
  final String? deletedAt;

  const SessionModel({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.status,
    required this.isEscalated,
    required this.isReopened,
    this.customerId,
    required this.tenantId,
    required this.categoryId,
    required this.channel,
    required this.direction,
    required this.viewId,
    this.adminId,
    this.conversationEndedAt,
    this.intakes,
    this.deletedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      id: json['id'] as String,
      status: SessionStatus.fromString(json['status'] as String),
      isEscalated: json['isEscalated'] as bool,
      isReopened: json['isReopened'] as bool,
      customerId: json['customerId'] as String?,
      tenantId: json['tenantId'] as int,
      categoryId: json['categoryId'] as int,
      channel: json['channel'] as String,
      direction: json['direction'] as String,
      viewId: json['viewId'] as String,
      adminId: json['adminId'] as String?,
      conversationEndedAt: json['conversationEndedAt'] as String?,
      intakes: json['intakes'],
      deletedAt: json['deletedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'id': id,
      'status': status,
      'isEscalated': isEscalated,
      'isReopened': isReopened,
      'customerId': customerId,
      'tenantId': tenantId,
      'categoryId': categoryId,
      'channel': channel,
      'direction': direction,
      'viewId': viewId,
      'adminId': adminId,
      'conversationEndedAt': conversationEndedAt,
      'intakes': intakes,
      'deletedAt': deletedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    updatedAt,
    id,
    status,
    isEscalated,
    isReopened,
    customerId,
    tenantId,
    categoryId,
    channel,
    direction,
    viewId,
    adminId,
    conversationEndedAt,
    intakes,
    deletedAt,
  ];

  // Category model from categories list in smSupportState
  CategoryModel? get category => smCubit.state.categories.firstWhere((element) => element.id == categoryId);
}

class SessionResponse extends Equatable {
  final SessionModel result;
  final int statusCode;

  const SessionResponse({required this.result, required this.statusCode});

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      result: SessionModel.fromJson(json['result'] as Map<String, dynamic>),
      statusCode: json['statusCode'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'result': result.toJson(), 'statusCode': statusCode};
  }

  @override
  List<Object?> get props => [result, statusCode];
}

class StartSessionRequest extends Equatable {
  final int categoryId;

  const StartSessionRequest({required this.categoryId});

  Map<String, dynamic> toJson() {
    return {'categoryId': categoryId};
  }

  @override
  List<Object?> get props => [categoryId];
}

class AssignAnonymousSessionRequest extends Equatable {
  final List<String> ids;

  const AssignAnonymousSessionRequest({required this.ids});

  Map<String, dynamic> toJson() {
    return {'ids': ids};
  }

  @override
  List<Object?> get props => [ids];
}

/// Request model for rating a session
class RateSessionRequest extends Equatable {
  final String sessionId;
  final int rating;
  final String? comment;

  const RateSessionRequest({
    required this.sessionId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    };
  }

  @override
  List<Object?> get props => [sessionId, rating, comment];
}

/// Response model for session rating
class RateSessionResponse extends Equatable {
  final String message;
  final bool success;

  const RateSessionResponse({
    required this.message,
    required this.success,
  });

  factory RateSessionResponse.fromJson(Map<String, dynamic> json) {
    return RateSessionResponse(
      message: json['message'] as String? ?? 'Rating submitted successfully',
      success: json['success'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [message, success];
}

/// Request model for reopening a session
class ReopenSessionRequest extends Equatable {
  final String id;

  const ReopenSessionRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {'id': id};
  }

  @override
  List<Object?> get props => [id];
}
