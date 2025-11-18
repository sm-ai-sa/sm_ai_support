// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/hidden_otp/hidden_otp_progress.dart';
import 'package:sm_ai_support/src/core/global/components/key_board/hard_coded_keyboard.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_cubit.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_state.dart';

// ignore: must_be_immutable
class OtpScreen extends StatefulWidget {
  final bool isCreateAccount;
  String? phoneNumber;
  String? countryCode;
  String? sessionId;
  final AuthCubit authCubit; // Receive AuthCubit from parent

  OtpScreen(
      {super.key,
      required this.isCreateAccount,
      required this.authCubit, // Required parameter
      this.phoneNumber,
      this.countryCode,
      this.sessionId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? _timer;
  final ValueNotifier<int> seconds = ValueNotifier<int>(60);
  final ValueNotifier<String> otp = ValueNotifier<String>("");
  String sms = "";

  // Use the AuthCubit from the widget (passed from parent)
  AuthCubit get _authCubit => widget.authCubit;

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
    if (otp.value.length == 6 && mounted) {
      // Check if the cubit is still open before calling methods on it
      if (!_authCubit.isClosed) {
        _authCubit.verifyOtp(
          otp: otp.value,
          sessionId: widget.sessionId,
        );
      } else {
        smPrint('AuthCubit is closed, cannot verify OTP');
      }
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
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: _authCubit, // Use the cubit passed from parent
      listenWhen: (prevState, state) =>
          state.verifyOtpStatus != prevState.verifyOtpStatus || state.sendOtpStatus != prevState.sendOtpStatus,
      listener: (context, state) async {
        if (state.verifyOtpStatus.isSuccess) {
          if (widget.isCreateAccount) {
            // For registration flow: Return success to Register screen
            if (!mounted) return;

            // Pop OTP bottom sheet with success result (true)
            // This signals Register screen to close itself and show Congratulations
            // Navigator.of(SMConfig.parentContext).pop(true);
            context.smPopSheet(isSuccess: true);
            // Trigger refresh of support state to update authentication status
            _refreshSupportState();
          } else {
            // For login flow: Close the OTP screen and trigger auth refresh
            if (!mounted) return;
            context.smPopSheet();

            // Trigger refresh of support state to update authentication status
            _refreshSupportState();
          }
        } else if (state.verifyOtpStatus.isFailure) {
          // Clear OTP input on failure to allow retry
          otp.value = '';
        } else if (state.sendOtpStatus.isSuccess) {
          // Restart timer when OTP is resent successfully
          startTimer();
        }
      },
      buildWhen: (prevState, state) =>
          prevState.verifyOtpStatus != state.verifyOtpStatus || prevState.sendOtpStatus != state.sendOtpStatus,
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
                              // Check if cubit is still valid before sending OTP
                              if (!_authCubit.isClosed) {
                                _authCubit.sendOtp(
                                  phone: widget.phoneNumber!,
                                  countryCode: widget.countryCode ?? '+966',
                                );
                              }
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
    );
  }
}
