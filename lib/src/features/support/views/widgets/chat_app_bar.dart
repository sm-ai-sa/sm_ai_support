import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/need_auth_bs.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

/// Custom AppBar for chat page with blur effect
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SingleSessionCubit sessionCubit;
  final String? categoryId;
  final String? sessionId;
  final String destination;

  const ChatAppBar({
    super.key,
    required this.sessionCubit,
    this.categoryId,
    this.sessionId,
    this.destination = "human",
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      actions: [
        if (SMConfig.smData.isVoiceEnabled)
          BlocProvider.value(
            value: sl<WebRTCCubit>(),
            child: BlocConsumer<WebRTCCubit, WebRTCState>(
              listenWhen: (prev, curr) =>
                  prev.authStatus != curr.authStatus ||
                  prev.connectStatus != curr.connectStatus ||
                  prev.errorMessage != curr.errorMessage,
              listener: (context, state) {
                if (!state.fromActiveSession) return;
                if (state.connectStatus.isSuccess) {
                  context.smPushReplacementFullScreen(CallScreen(destination: destination));
                  return;
                }

                if (state.authStatus.isFailure || state.connectStatus.isFailure) {
                  primarySnackBar(context, message: state.errorMessage ?? "Error");
                }
                if (state.errorMessage != null && state.errorMessage!.contains('Auth rejected')) {
                  primarySnackBar(context, message: state.errorMessage ?? "Error");
                }
              },
              builder: (context, state) {
                final isLoading = state.authStatus.isLoading || state.connectStatus.isLoading;
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: 24.rw),
                  child: isLoading
                      ? SizedBox(width: 24.rSp, height: 24.rSp, child: DesignSystem.loadingIndicator())
                      : DesignSystem.svgIcon(
                          "call",
                          color: ColorsPallets.primaryColor,
                          onTap: () {
                            if (!SMConfig.smData.isVoiceEnabled) return;
                            if (!AuthManager.isAuthenticated) {
                              primaryCupertinoBottomSheet(
                                showSwipeCloseIndicator: true,
                                child: NeedAuthBS(),
                                useDynamicHeight: true,
                              );
                              return;
                            }
                            sl<WebRTCCubit>().startSessionAndConnect(
                              destination: destination,
                              categoryId: categoryId ?? '1',
                              sessionId: sessionId ?? sessionCubit.state.sessionId,
                              fromActiveSession: true,
                            );
                          },
                        ),
                );
              },
            ),
          ),
      ],
      leading: Row(
        children: [
          SizedBox(width: 22.rw),
          DesignSystem.backButton(color: ColorsPallets.loud900),
        ],
      ),
      leadingWidth: 50.rw,
      centerTitle: false,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 100, tileMode: TileMode.mirror),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(SMText.supportAndHelpTitle, style: TextStyles.s_16_400),
          Text(SMText.online, style: TextStyles.s_12_400.copyWith(color: ColorsPallets.secondaryGreen100)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
