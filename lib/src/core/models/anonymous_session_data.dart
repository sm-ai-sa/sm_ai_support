import 'package:equatable/equatable.dart';

/// Model for storing anonymous session data with metadata
/// Supports tracking multiple sessions per category with status and creation time
class AnonymousSessionData extends Equatable {
  final String sessionId;
  final int categoryId;
  final DateTime createdAt;
  final String status; // 'active', 'closed', 'failed'

  const AnonymousSessionData({
    required this.sessionId,
    required this.categoryId,
    required this.createdAt,
    required this.status,
  });

  /// Create an active session (default status)
  factory AnonymousSessionData.active({
    required String sessionId,
    required int categoryId,
  }) {
    return AnonymousSessionData(
      sessionId: sessionId,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      status: 'active',
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'categoryId': categoryId,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  /// JSON deserialization
  factory AnonymousSessionData.fromJson(Map<String, dynamic> json) {
    return AnonymousSessionData(
      sessionId: json['sessionId'] as String,
      categoryId: json['categoryId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
    );
  }

  /// Copy with method for updating status
  AnonymousSessionData copyWith({
    String? sessionId,
    int? categoryId,
    DateTime? createdAt,
    String? status,
  }) {
    return AnonymousSessionData(
      sessionId: sessionId ?? this.sessionId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  /// Check if session is active
  bool get isActive => status == 'active';

  /// Check if session is closed
  bool get isClosed => status == 'closed';

  /// Check if session has failed
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [sessionId, categoryId, createdAt, status];

  @override
  String toString() => 'AnonymousSessionData(sessionId: $sessionId, categoryId: $categoryId, '
      'createdAt: $createdAt, status: $status)';
}
