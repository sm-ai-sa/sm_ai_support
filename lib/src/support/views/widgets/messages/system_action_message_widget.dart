import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';

/// System action message widget (close session, reopen, etc.)
class SystemActionMessageWidget extends StatelessWidget {
  final SessionMessage message;
  final Color? tenantColor;

  const SystemActionMessageWidget({super.key, required this.message, this.tenantColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      _getMessage(),
      style: TextStyles.s_13_400.copyWith(color: (tenantColor ?? ColorsPallets.primaryColor)),
      textAlign: TextAlign.center,
    );
  }

  String _getMessage() {
    if (message.contentType.isCloseSession) {
      return SMText.closedSessions;
    } else if (message.contentType.isReopenSession) {
      return SMText.reopenSession;
    } else if (message.contentType.isCloseSessionBySystem) {
      return SMText.sessionClosedBySystem;
    }
    return '';
  }
}
