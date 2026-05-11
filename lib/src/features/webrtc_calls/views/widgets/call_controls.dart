import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class CallControls extends StatelessWidget {
  final WebRTCState state;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onHangup;

  const CallControls({
    super.key,
    required this.state,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    required this.onHangup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.rw),
      child: Row(
        children: [
          // Hangup button
          _ControlButton(icon: "call-off", label: SMText.close, backgroundColor: ColorsPallets.red200, onTap: onHangup),
          // Mute button
          _ControlButton(
            icon: state.isMuted ? "mic-muted" : "mic",
            label: state.isMuted ? SMText.unmute : SMText.mute,
            backgroundColor: state.isMuted ? ColorsPallets.white : ColorsPallets.white.withValues(alpha: 0.12),
            onTap: onToggleMute,
          ),
          // Speaker button
          _ControlButton(
            icon: state.isSpeakerOn ? "speaker-filled" : "speaker",
            label: SMText.speaker,
            backgroundColor: ColorsPallets.white.withValues(alpha: 0.12),
            onTap: onToggleSpeaker,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 64.rSp,
                height: 64.rSp,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
                child: DesignSystem.svgIcon(icon, size: 22.rSp, fit: BoxFit.contain),
              ),
            ),
            SizedBox(height: 10.rh),
            Text(
              label,
              style: TextStyles.s_14_400.copyWith(color: ColorsPallets.white.withValues(alpha: 0.85)),
            ),
          ],
        ),
      ),
    );
  }
}
