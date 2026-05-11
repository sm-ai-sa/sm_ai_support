import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/models/webrtc_call_model.dart';
import 'package:sm_ai_support/src/core/services/webrtc_service.dart';
import 'package:sm_ai_support/src/core/utils/enums.dart';
import 'package:sm_ai_support/src/features/webrtc_calls/cubit/webrtc_state.dart';
import 'package:sm_ai_support/src/features/webrtc_calls/data/webrtc_repo.dart';

class WebRTCCubit extends Cubit<WebRTCState> {
  WebRTCCubit() : super(const WebRTCState());

  StreamSubscription<WebRTCCallPhase>? _callPhaseSubscription;
  StreamSubscription<String>? _errorSubscription;
  Timer? _callDurationTimer;

  void _subscribeToStreams() {
    final service = sl<WebRTCService>();

    _callPhaseSubscription?.cancel();
    _callPhaseSubscription = service.callPhaseStream.listen(_onCallPhaseChanged);

    _errorSubscription?.cancel();
    _errorSubscription = service.errorStream.listen(_onError);
  }

  void _onCallPhaseChanged(WebRTCCallPhase phase) {
    emit(state.copyWith(
      call: state.call.copyWith(phase: phase),
    ));

    if (phase == WebRTCCallPhase.active) {
      _startCallDurationTimer();
    } else if (phase == WebRTCCallPhase.idle || phase == WebRTCCallPhase.ending) {
      _stopCallDurationTimer();
    }
  }

  void _onError(String error) {
    emit(state.copyWith(errorMessage: error));
  }

  /// Full flow: startCallSession → configure service → connect to Verto
  Future<void> startSessionAndConnect({required String destination}) async {
    // Reset state for a fresh call flow
    emit(const WebRTCState(authStatus: BaseStatus.loading));
    _subscribeToStreams();

    final repo = sl<WebRTCRepo>();

    // Step 1: Call in-app/start-call-session to get credentials
    final authResult = await repo.startCallSession();
    final authResponse = authResult.when(
      success: (data) {
        emit(state.copyWith(
          authStatus: BaseStatus.success,
          smSessionId: data.callSession.sessionId,
        ));
        return data;
      },
      error: (e) {
        emit(state.copyWith(authStatus: BaseStatus.failure, errorMessage: e.failure.error));
        return null;
      },
    );

    if (authResponse == null) return;

    // Step 2: Configure the service with credentials from the API
    final service = sl<WebRTCService>();
    service.configure(
      jwtToken: authResponse.token,
      callId: authResponse.callSession.id,
      smSessionId: authResponse.callSession.sessionId,
      vertoCatchallPassword: authResponse.vertoPassword,
      vertoUrl: authResponse.vertoUrl ?? '',
      destination: destination,
      iceServers: authResponse.iceServers.map((e) => e.toWebRTCConfig()).toList(),
    );

    // Step 3: Connect to Verto WebSocket
    emit(state.copyWith(connectStatus: BaseStatus.loading));
    final connectResult = await repo.connect();
    connectResult.when(
      success: (connected) {
        if (connected) {
          emit(state.copyWith(connectStatus: BaseStatus.success));
        } else {
          emit(state.copyWith(connectStatus: BaseStatus.failure, errorMessage: 'Connection failed'));
        }
      },
      error: (e) => emit(state.copyWith(connectStatus: BaseStatus.failure, errorMessage: e.failure.error)),
    );
  }

  /// Make a call to a destination
  Future<void> makeCall(String destination) async {
    emit(state.copyWith(
      callStatus: BaseStatus.loading,
      clearError: true,
      call: state.call.copyWith(destination: destination, phase: WebRTCCallPhase.connecting),
    ));

    final result = await sl<WebRTCRepo>().makeCall(destination);
    result.when(
      success: (_) => emit(state.copyWith(callStatus: BaseStatus.success)),
      error: (e) => emit(state.copyWith(callStatus: BaseStatus.failure, errorMessage: e.failure.error)),
    );
  }

  /// Hang up the current call
  Future<void> hangup() async {
    emit(state.copyWith(hangupStatus: BaseStatus.loading));

    final result = await sl<WebRTCRepo>().hangup();
    result.when(
      success: (_) {
        emit(state.copyWith(
          hangupStatus: BaseStatus.success,
          call: const WebRTCCallModel(),
          callDuration: Duration.zero,
          isMuted: false,
          isSpeakerOn: false,
        ));
      },
      error: (e) => emit(state.copyWith(hangupStatus: BaseStatus.failure, errorMessage: e.failure.error)),
    );
  }

  /// Disconnect from Verto server entirely
  Future<void> disconnectFromServer() async {
    await sl<WebRTCRepo>().disconnect();
    emit(const WebRTCState());
  }

  /// Toggle mute on/off for local audio
  void toggleMute() {
    sl<WebRTCService>().toggleMute();
    emit(state.copyWith(isMuted: !state.isMuted));
  }

  /// Toggle speaker on/off for audio output
  Future<void> toggleSpeaker() async {
    await sl<WebRTCService>().toggleSpeaker();
    emit(state.copyWith(isSpeakerOn: !state.isSpeakerOn));
  }

  void _startCallDurationTimer() {
    _stopCallDurationTimer();
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(
        callDuration: state.callDuration + const Duration(seconds: 1),
      ));
    });
  }

  void _stopCallDurationTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
  }

  @override
  Future<void> close() {
    _callPhaseSubscription?.cancel();
    _errorSubscription?.cancel();
    _stopCallDurationTimer();
    return super.close();
  }
}
