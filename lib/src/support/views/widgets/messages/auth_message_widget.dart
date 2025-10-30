import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/features/auth/views/login_by_phone.dart';

/// Authentication-related message widgets
/// Handles NEED_AUTH, AUTHORIZED, and UNAUTHORIZED message types
class AuthMessageWidget extends StatelessWidget {
  final SessionMessage message;
  final String sessionId;
  final Color? tenantColor;

  const AuthMessageWidget({
    super.key,
    required this.message,
    required this.sessionId,
    this.tenantColor,
  });

  @override
  Widget build(BuildContext context) {
    if (message.contentType.isNeedAuth) {
      return _buildNeedAuthMessage(context);
    } else if (message.contentType.isAuthorized || message.contentType.isUnauthorized) {
      return _buildAuthResultMessage();
    }
    return const SizedBox.shrink();
  }

  /// Need authentication message - prompts user to login
  Widget _buildNeedAuthMessage(BuildContext context) {
    return InkWell(
      onTap: () {
        primaryCupertinoBottomSheet(
          child: LoginByPhone(isCreateAccount: false, sessionId: sessionId),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10.rSp),
        decoration: BoxDecoration(
          color: ColorsPallets.yellow0,
          border: Border.all(color: ColorsPallets.yellow25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              SMText.confirmIdentityToCompleteTheProcess,
              style: TextStyles.s_13_400.copyWith(color: ColorsPallets.yellow300),
            ),
            SizedBox(width: 8.rw),
            DesignSystem.svgIcon('arrow-left', size: 17, color: ColorsPallets.yellow300),
          ],
        ),
      ),
    );
  }

  /// Authentication result message - shows success or failure
  Widget _buildAuthResultMessage() {
    final isAuthSuccess = message.contentType.isAuthorized;
    
    return Container(
      padding: EdgeInsets.all(10.rSp),
      decoration: BoxDecoration(
        color: isAuthSuccess ? ColorsPallets.green0 : ColorsPallets.red0,
        border: Border.all(color: isAuthSuccess ? ColorsPallets.green25 : ColorsPallets.red25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DesignSystem.svgIcon(
            isAuthSuccess ? 'check' : 'close',
            size: 17,
            color: isAuthSuccess ? ColorsPallets.green300 : ColorsPallets.red300,
          ),
          SizedBox(width: 8.rw),
          Text(
            isAuthSuccess ? SMText.identityConfirmed : SMText.identityNotConfirmed,
            style: TextStyles.s_13_400.copyWith(
              color: isAuthSuccess ? ColorsPallets.green300 : ColorsPallets.red300,
            ),
          ),
        ],
      ),
    );
  }
}

