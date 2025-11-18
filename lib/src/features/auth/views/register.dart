// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/enums.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_cubit.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_state.dart';
import 'package:sm_ai_support/src/features/auth/views/congratulations.dart';
import 'package:sm_ai_support/src/features/auth/views/login_by_phone.dart';
import 'package:sm_ai_support/src/features/auth/views/otp_screen.dart';
import 'package:sm_ai_support/src/features/auth/views/register_form.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SingleTickerProviderStateMixin {
  bool _isOtpSheetShown = false;
  late final AuthCubit authCubit;

  @override
  void initState() {
    super.initState();
    authCubit = sl<AuthCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: authCubit..reset(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prevState, state) => state.registerStatus != prevState.registerStatus,
        listener: (context, state) async {
          if (state.registerStatus.isSuccess && !_isOtpSheetShown) {
            _isOtpSheetShown = true;

            // No need to sync - using the same global instance
            final result = await primaryCupertinoBottomSheet(
              child: OtpScreen(
                isCreateAccount: true,
                authCubit: authCubit, // Use the global instance directly
                phoneNumber: state.registrationBody?.phoneNumber,
                countryCode: state.registrationBody?.countryCode ?? '+966',
                sessionId: state.sessionId,
              ),
            );

            _isOtpSheetShown = false;

            // If OTP verification was successful (result == true), show Congratulations and close Register
            if (result == true && mounted) {
              // Close the Register bottom sheet first
              context.smPopSheet();

              // Small delay for animation
              await Future.delayed(const Duration(milliseconds: 150));

              if (!mounted) return;

              // Show Congratulations page using the bottom sheet navigator
              // This ensures when it pops, it returns to the categories bottom sheet
              context.smPushFullScreen(const Congratulations());
            }
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 62.rh,
                padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 6.rh),
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: DesignSystem.svgIcon(
                    "close",
                    color: ColorsPallets.normal500,
                    size: 26.rSp,
                    onTap: () => context.smPopSheet(),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.rw),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20.rh),
                        DesignSystem.avatarTitleSubtitle(
                          pngAvatar: 'user-avatar',
                          title: SMText.createNewAccount,
                          subTitle: SMText.pleaseEnterAllDetailsToCreateYourAccount,
                        ),
                        SizedBox(height: 45.rh),
                        RegisterForm(),
                        SizedBox(height: 24.rh),
                        DesignSystem.thereIsAnAccount(
                          onPressed: () {
                            context.smPopSheet();
                            primaryCupertinoBottomSheet(child: LoginByPhone());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
