import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/models/webrtc_call_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';

class CallStatusChip extends StatelessWidget {
  final WebRTCCallPhase phase;

  const CallStatusChip({super.key, required this.phase});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (phase) {
      WebRTCCallPhase.idle => ('Idle', ColorsPallets.neutralSolid300),
      WebRTCCallPhase.connecting => ('Connecting', ColorsPallets.warning500),
      WebRTCCallPhase.ringing => ('Ringing', Colors.blue),
      WebRTCCallPhase.active => ('Active', ColorsPallets.secondaryGreen100),
      WebRTCCallPhase.ending => ('Ending', ColorsPallets.secondaryRed100),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorsPallets.loud900,
          ),
        ),
      ],
    );
  }
}
