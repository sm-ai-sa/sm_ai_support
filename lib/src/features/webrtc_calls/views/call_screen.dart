import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/models/webrtc_call_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/features/support/views/chat_page.dart';
import 'package:sm_ai_support/src/features/webrtc_calls/cubit/webrtc_cubit.dart';
import 'package:sm_ai_support/src/features/webrtc_calls/cubit/webrtc_state.dart';
import 'package:sm_ai_support/src/features/webrtc_calls/views/widgets/call_controls.dart';
import 'package:sm_ai_support/src/features/webrtc_calls/views/widgets/voice_wave_visualizer.dart';

class CallScreen extends StatefulWidget {
  final String destination;

  const CallScreen({required this.destination, super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _wasCallInProgress = false;
  bool _didHandleCallEnd = false;

  @override
  void initState() {
    super.initState();
    sl<WebRTCCubit>().makeCall(widget.destination);
  }

  /// Replace the call screen with the chat page for [smSessionId].
  ///
  /// When the call ends we pop this screen and push the chat page in its place
  /// so the user lands directly on the conversation tied to the call. If the
  /// [smSessionId] is missing for any reason, we fall back to a plain pop.
  void _replaceWithChatPage(BuildContext context, String? smSessionId) {
    if (!mounted) return;

    if (smSessionId == null || smSessionId.isEmpty) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      return;
    }

    // Refresh the user's sessions list so the chat page can resolve the full
    // session model (status, category, etc.) for this sessionId.
    smCubit.getMySessions();

    context.smPushReplacementFullScreen(
      ChatPage(providedSessionId: smSessionId, autoShowRating: true),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<WebRTCCubit>(),
      child: BlocListener<WebRTCCubit, WebRTCState>(
        listenWhen: (prev, curr) => prev.call.phase != curr.call.phase,
        listener: (context, state) {
          // Track if call was ever in progress
          if (state.call.phase.isInProgress) _wasCallInProgress = true;

          // When the call ends (user hangup OR remote verto.bye), replace the
          // call screen with the chat page for the same sm session so the user
          // can see the conversation and the rating bottom sheet can auto-show.
          if (state.call.phase == WebRTCCallPhase.idle && _wasCallInProgress && !_didHandleCallEnd) {
            _didHandleCallEnd = true;
            _replaceWithChatPage(context, state.smSessionId);
          }
        },
        child: PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: ColorsPallets.mutedBlack,
            body: SafeArea(
              child: BlocBuilder<WebRTCCubit, WebRTCState>(
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.rh),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DesignSystem.pngIcon("call-avatar", size: 84.rSp, borderRadius: 200.rSp),
                        SizedBox(height: 16.rh),
                        Text(
                          state.call.phase.isRinging || state.call.phase.isConnecting
                              ? SMText.calling
                              : SMText.listening,
                          style: TextStyles.s_13_400.copyWith(color: ColorsPallets.subdued400),
                        ),
                        SizedBox(height: 10.rh),
                        Text(
                          _formatDuration(state.callDuration),
                          style: TextStyles.s_20_600.copyWith(color: ColorsPallets.white),
                        ),
                        SizedBox(height: 60.rh),
                        const VoiceWaveVisualizer(),
                        SizedBox(height: 100.rh),
                        CallControls(
                          state: state,
                          onToggleMute: () => sl<WebRTCCubit>().toggleMute(),
                          onToggleSpeaker: () => sl<WebRTCCubit>().toggleSpeaker(),
                          onHangup: () => sl<WebRTCCubit>().hangup(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
