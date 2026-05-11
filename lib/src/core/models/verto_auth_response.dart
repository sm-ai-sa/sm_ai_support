import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/src/core/models/ice_server_model.dart';

/// Model representing the authentication response from `in-app/start-call-session`
class VertoAuthResponse extends Equatable {
  final String token;
  final String vertoPassword;
  final String? vertoUrl;
  final CallSession callSession;
  final List<IceServerModel> iceServers;

  const VertoAuthResponse({
    required this.token,
    required this.vertoPassword,
    required this.callSession,
    required this.iceServers,
    this.vertoUrl,
  });

  factory VertoAuthResponse.fromJson(Map<String, dynamic> json) {
    return VertoAuthResponse(
      token: json['token'] as String,
      vertoPassword: json['vertoPassword'] as String,
      vertoUrl: json['vertoUrl'] as String?,
      callSession: CallSession.fromJson(json['callSession'] as Map<String, dynamic>),
      iceServers:
          (json['iceServers'] as List?)?.map((e) => IceServerModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'vertoPassword': vertoPassword,
        'callSession': callSession.toJson(),
        'iceServers': iceServers.map((e) => e.toJson()).toList(),
        if (vertoUrl != null) 'vertoUrl': vertoUrl,
      };

  VertoAuthResponse copyWith({
    String? token,
    String? vertoPassword,
    CallSession? callSession,
    List<IceServerModel>? iceServers,
    String? vertoUrl,
  }) {
    return VertoAuthResponse(
      token: token ?? this.token,
      vertoPassword: vertoPassword ?? this.vertoPassword,
      callSession: callSession ?? this.callSession,
      iceServers: iceServers ?? this.iceServers,
      vertoUrl: vertoUrl ?? this.vertoUrl,
    );
  }

  @override
  List<Object?> get props => [token, vertoPassword, callSession, iceServers, vertoUrl];
}

class CallSession extends Equatable {
  final String id;
  final String sessionId;

  const CallSession({
    required this.id,
    required this.sessionId,
  });

  factory CallSession.fromJson(Map<String, dynamic> json) {
    return CallSession(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
      };

  CallSession copyWith({
    String? id,
    String? sessionId,
  }) {
    return CallSession(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [id, sessionId];
}
