import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/need_auth_bs.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';
import 'package:sm_ai_support/src/features/support/views/my_all_sessions.dart';

/// My Chats button with unread count badge
class MyChatsButton extends StatelessWidget {
  final bool isDisposed;

  const MyChatsButton({super.key, required this.isDisposed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SMSupportCubit, SMSupportState>(
      buildWhen: (previous, current) {
        if (isDisposed) return false;
        // Rebuild if unread count changes or if authentication state might have changed
        return previous.myUnreadSessionsCount != current.myUnreadSessionsCount ||
            previous.getMyUnreadSessionsStatus != current.getMyUnreadSessionsStatus ||
            previous != current; // Rebuild on any state change to catch auth updates
      },
      builder: (context, state) {
        return InkWell(
          onTap: () {
            smPrint('🔍 MyChatsButton tapped - Checking auth state:');
            smPrint('  state.isAuthenticated: ${state.isAuthenticated}');
            smPrint('  AuthManager.isAuthenticated: ${AuthManager.isAuthenticated}');
            smPrint('  AuthManager.authToken: ${AuthManager.authToken != null ? "Present" : "Null"}');

            if (state.isAuthenticated) {
              smPrint('✅ User is authenticated - Navigating to MySessions');
              context.smPush(MySessions());
            } else {
              smPrint('❌ User is NOT authenticated - Showing auth bottom sheet');
              primaryCupertinoBottomSheet(
                showSwipeCloseIndicator: true,
                child: NeedAuthBS(),
                useDynamicHeight: true,
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 16.rh),
            decoration: BoxDecoration(color: ColorsPallets.primaryColor.withValues(alpha: .05), borderRadius: 12.br),
            child: Row(
              children: [
                DesignSystem.svgIcon(
                  'chat4',
                  color: state.currentTenant?.primaryColor ?? ColorsPallets.primaryColor,
                  size: 22.rSp,
                ),
                SizedBox(width: 6.rw),
                Expanded(
                  child: Text(
                    SMText.myMessages,
                    style: TextStyles.s_14_400.copyWith(color: ColorsPallets.primaryColor),
                  ),
                ),
                if (state.getMyUnreadSessionsStatus.isLoading) ...[
                  DesignSystem.loadingIndicator(),
                ] else if (state.myUnreadSessionsCount != 0) ...[
                  CircleAvatar(
                    radius: 12.rw,
                    backgroundColor: state.currentTenant?.primaryColor ?? ColorsPallets.primaryColor,
                    child: Text(
                      state.myUnreadSessionsCount.toString(),
                      style: TextStyles.s_12_600.copyWith(color: ColorsPallets.white),
                    ),
                  ),
                ] else ...[
                  DesignSystem.arrowLeftOrRight(color: ColorsPallets.primaryColor),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
