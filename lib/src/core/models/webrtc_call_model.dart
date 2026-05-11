import 'package:equatable/equatable.dart';

/// Represents the phase of a WebRTC call
enum WebRTCCallPhase {
  idle,
  connecting,
  ringing,
  active,
  ending;

  bool get isIdle => this == WebRTCCallPhase.idle;
  bool get isConnecting => this == WebRTCCallPhase.connecting;
  bool get isRinging => this == WebRTCCallPhase.ringing;
  bool get isActive => this == WebRTCCallPhase.active;
  bool get isEnding => this == WebRTCCallPhase.ending;

  bool get isInProgress => this != WebRTCCallPhase.idle;
}

/// Model representing the current state of a WebRTC call
class WebRTCCallModel extends Equatable {
  final String? callId;
  final String? sessionId;
  final String? destination;
  final WebRTCCallPhase phase;
  final DateTime? startedAt;
  final String? errorMessage;

  const WebRTCCallModel({
    this.callId,
    this.sessionId,
    this.destination,
    this.phase = WebRTCCallPhase.idle,
    this.startedAt,
    this.errorMessage,
  });

  WebRTCCallModel copyWith({
    String? callId,
    String? sessionId,
    String? destination,
    WebRTCCallPhase? phase,
    DateTime? startedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WebRTCCallModel(
      callId: callId ?? this.callId,
      sessionId: sessionId ?? this.sessionId,
      destination: destination ?? this.destination,
      phase: phase ?? this.phase,
      startedAt: startedAt ?? this.startedAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [callId, sessionId, destination, phase, startedAt, errorMessage];
}
