import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

import '../../../../core/global/components/primary_bottom_sheet.dart';
import '../../../../core/global/need_auth_bs.dart';
import '../../../../core/utils/extension.dart';

class StartCallWidget extends StatelessWidget {
  final String destination;

  const StartCallWidget({required this.destination, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsPallets.white,
      padding: EdgeInsets.all(22.rw),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SMText.contactUsNow,
                      style: TextStyles.s_16_400.copyWith(color: ColorsPallets.muted600),
                    ),
                    SizedBox(height: 4.rh),
                    Text(
                      SMText.welcomeHowCanWeHelpToday,
                      style: TextStyles.s_12_400.copyWith(color: ColorsPallets.subdued400),
                    ),
                  ],
                ),
              ),

              // Avatars
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Container(color: Colors.red,width: 100,height: 100,),
                  DesignSystem.pngIcon("avatar-image-3", size: 36.rSp),
                  PositionedDirectional(end: 20.rSp, child: DesignSystem.pngIcon("avatar-image-2", size: 36.rSp)),
                  PositionedDirectional(
                    end: 40.rSp,
                    child: Stack(
                      children: [
                        DesignSystem.pngIcon("avatar-image-1", size: 36.rSp),
                        PositionedDirectional(
                          start: 2.rw,
                          bottom: 2.rw,
                          child: CircleAvatar(
                            radius: 4.rSp,
                            backgroundColor: ColorsPallets.secondaryGreen100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 20.rh),

          // Start call button
          BlocProvider.value(
            value: sl<WebRTCCubit>(),
            child: BlocConsumer<WebRTCCubit, WebRTCState>(
              listenWhen: (prev, curr) =>
                  prev.authStatus != curr.authStatus ||
                  prev.connectStatus != curr.connectStatus ||
                  prev.errorMessage != curr.errorMessage,
              listener: (context, state) {
                if (state.connectStatus.isSuccess) {
                  context.smPushFullScreen(CallScreen(destination: destination));
                  return;
                }

                // On auth/connect failure
                if (state.authStatus.isFailure || state.connectStatus.isFailure) {
                  primarySnackBar(context, message: state.errorMessage ?? "Error");
                }
                // On error (e.g. auth_rejected from Verto server)
                if (state.errorMessage != null && state.errorMessage!.contains('Auth rejected')) {
                  primarySnackBar(context, message: state.errorMessage ?? "Error");
                }
              },
              builder: (context, state) => DesignSystem.primaryButton(
                showLoading: state.authStatus.isLoading || state.connectStatus.isLoading,
                title: SMText.callNow,
                icon: "call",
                backgroundColor: ColorsPallets.violetPrimary,
                onPressed: () {
                  if (!SMConfig.smData.isVoiceEnabled) return;
                  if (!AuthManager.isAuthenticated) {
                    primaryCupertinoBottomSheet(
                      showSwipeCloseIndicator: true,
                      child: NeedAuthBS(),
                      useDynamicHeight: true,
                    );
                    return;
                  }

                  sl<WebRTCCubit>().startSessionAndConnect(destination: destination);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
