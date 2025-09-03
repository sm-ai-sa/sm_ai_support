// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/components/hidden_otp/hidden_otp_progress.dart';
import 'package:sm_ai_support/src/core/global/components/key_board/hard_coded_keyboard.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_cubit.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_state.dart';

// ignore: must_be_immutable
class OtpScreen extends StatefulWidget {
  final bool isCreateAccount;
  String? phoneNumber;
  String? countryCode;
  String? sessionId;

  OtpScreen({super.key, required this.isCreateAccount, this.phoneNumber, this.countryCode, this.sessionId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  Timer? _timer;
  final ValueNotifier<int> seconds = ValueNotifier<int>(60);
  final ValueNotifier<String> otp = ValueNotifier<String>("");
  String sms = "";

  @override
  void initState() {
    super.initState();
    startTimer();
    otp.addListener(otpListener);
  }

  void startTimer() {
    seconds.value = 60;
    _timer = Timer.periodic(1.seconds, (_) {
      if (seconds.value < 1) {
        _timer?.cancel();
      } else {
        seconds.value = seconds.value - 1;
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopTimer();
    otp.removeListener(otpListener);
    super.dispose();
  }

  void otpListener() {
    if (otp.value.length == 6) {
      sl<AuthCubit>().verifyOtp(
        otp: otp.value,
        sessionId: widget.sessionId,
      );
    }
  }

  /// Refresh the support state to update authentication status
  void _refreshSupportState() {
    // Trigger a refresh by calling getMySessions if authenticated
    // This will cause the support cubit to emit a new state and refresh the UI
    if (AuthManager.isAuthenticated) {
      smCubit.getMySessions();
      smCubit.getMyUnreadSessions();
      smCubit.startUnreadSessionsCountStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prevState, state) => 
          state.verifyOtpStatus != prevState.verifyOtpStatus ||
          state.sendOtpStatus != prevState.sendOtpStatus,
      listener: (context, state) {
        if (state.verifyOtpStatus.isSuccess) {
          // Close the OTP screen and trigger auth refresh
          Navigator.of(context).pop();
          
          // Trigger refresh of support state to update authentication status
          _refreshSupportState();
        } else if (state.verifyOtpStatus.isFailure) {
          // Clear OTP input on failure to allow retry
          otp.value = '';
        } else if (state.sendOtpStatus.isSuccess) {
          // Restart timer when OTP is resent successfully
          startTimer();
        }
      },
      buildWhen: (prevState, state) =>
          prevState.verifyOtpStatus != state.verifyOtpStatus || 
          prevState.sendOtpStatus != state.sendOtpStatus,
      builder: (context, state) {
        return Column(
          children: [
            SizedBox(height: 50.rh),
            DesignSystem.avatarTitleSubtitle(
              pngAvatar: 'code',
              title: SMText.confirmIdentity,
              subTitle: SMText.enterTheVerificationCodeSentToYourPhone,
            ),
            SizedBox(height: 36.rh),
            ValueListenableBuilder<String>(
              valueListenable: otp,
              builder: (context, otp, child) => HiddenOtpProgress(
                totalCount: 6,
                progressCount: otp.length,
                isErrorStyle: state.verifyOtpStatus.isFailure,
              ),
            ),
            Expanded(
              child: HardCodedKeyboard(
                textNotifier: otp,
                enabled: !state.verifyOtpStatus.isLoading,
                isWithSpaces: false,
                maxNumbers: 6,
                isWithCountryButton: false,
              ),
            ),
            DesignSystem.animatedCrossFadeWidget(
              animationStatus: state.sendOtpStatus.isLoading || state.verifyOtpStatus.isLoading,
              shownIfFalse: ValueListenableBuilder(
                valueListenable: seconds,
                builder: (_, seconds, __) => RichText(
                  text: TextSpan(
                    children: [
                      if (seconds == 0) ...{
                        TextSpan(
                          text: SMText.didNotReceiveTheCode,
                          style: TextStyles.s_13_400.copyWith(color: ColorsPallets.subdued400),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: SMText.sendNewCode,
                          style: TextStyles.s_13_400.copyWith(color: ColorsPallets.primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              sl<AuthCubit>().sendOtp(
                                phone: widget.phoneNumber!,
                                countryCode: widget.countryCode ?? '+966',
                              );
                            },
                        ),
                      } else ...{
                        TextSpan(
                          text: SMText.remainingTime,
                          style: TextStyles.s_13_400.copyWith(color: ColorsPallets.subdued400),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: '$seconds ${SMText.second}',
                          style: TextStyles.s_13_400.copyWith(color: ColorsPallets.muted600),
                        ),
                      },
                    ],
                  ),
                ),
              ),
              shownIfTrue: DesignSystem.loadingIndicator(color: ColorsPallets.black),
            ),
            SizedBox(height: 40.rh),
            DesignSystem.animatedCrossFadeWidget(
              animationStatus: state.verifyOtpStatus.isFailure,
              shownIfTrue: Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.rw),
                child: DesignSystem.errorOTPButton(onClose: () => otp.value = ''),
              ),
              shownIfFalse: Text(
                SMText.ensuringProtectionAndSafetyForASafeUsageExperience,
                style: TextStyles.s_13_400.copyWith(color: ColorsPallets.neutralSolid300),
              ),
            ),
            SizedBox(height: 55.rh),
          ],
        );
      },
      ),
    );
  }
}
