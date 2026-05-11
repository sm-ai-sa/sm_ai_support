import 'package:equatable/equatable.dart';
import 'package:sm_ai_support/src/core/models/webrtc_call_model.dart';
import 'package:sm_ai_support/src/core/utils/enums.dart';

class WebRTCState extends Equatable {
  final BaseStatus authStatus;
  final BaseStatus connectStatus;
  final BaseStatus callStatus;
  final BaseStatus hangupStatus;
  final WebRTCCallModel call;
  final String? errorMessage;
  final Duration callDuration;
  final bool isMuted;
  final bool isSpeakerOn;
  final String? smSessionId;
  final bool fromActiveSession;

  const WebRTCState({
    this.authStatus = BaseStatus.initial,
    this.connectStatus = BaseStatus.initial,
    this.callStatus = BaseStatus.initial,
    this.hangupStatus = BaseStatus.initial,
    this.call = const WebRTCCallModel(),
    this.errorMessage,
    this.callDuration = Duration.zero,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.smSessionId,
    this.fromActiveSession = false,
  });

  WebRTCState copyWith({
    BaseStatus? authStatus,
    BaseStatus? connectStatus,
    BaseStatus? callStatus,
    BaseStatus? hangupStatus,
    WebRTCCallModel? call,
    String? errorMessage,
    bool clearError = false,
    Duration? callDuration,
    bool? isMuted,
    bool? isSpeakerOn,
    String? smSessionId,
    bool? fromActiveSession,
  }) {
    return WebRTCState(
      authStatus: authStatus ?? this.authStatus,
      connectStatus: connectStatus ?? this.connectStatus,
      callStatus: callStatus ?? this.callStatus,
      hangupStatus: hangupStatus ?? this.hangupStatus,
      call: call ?? this.call,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      callDuration: callDuration ?? this.callDuration,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      smSessionId: smSessionId ?? this.smSessionId,
      fromActiveSession: fromActiveSession ?? this.fromActiveSession,
    );
  }

  /// Whether a call is currently active (media flowing)
  bool get isCallActive => call.phase == WebRTCCallPhase.active;

  /// Whether any call activity is in progress (connecting, ringing, or active)
  bool get isCallInProgress => call.phase.isInProgress;

  /// Whether connected to the Verto server
  bool get isConnectedToServer => connectStatus.isSuccess;

  @override
  List<Object?> get props => [
        authStatus,
        connectStatus,
        callStatus,
        hangupStatus,
        call,
        errorMessage,
        callDuration,
        isMuted,
        isSpeakerOn,
        smSessionId,
        fromActiveSession,
      ];
}
