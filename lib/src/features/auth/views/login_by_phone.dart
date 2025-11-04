import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/components/country_codes.dart';
import 'package:sm_ai_support/src/core/global/components/key_board/hard_coded_keyboard.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_cubit.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_state.dart';
import 'package:sm_ai_support/src/features/auth/views/otp_screen.dart';
import 'package:sm_ai_support/src/features/auth/views/register.dart';
import 'package:uni_country_city_picker/uni_country_city_picker.dart';

class LoginByPhone extends StatefulWidget {
  final String? sessionId;
  const LoginByPhone({super.key, this.sessionId});

  @override
  State<LoginByPhone> createState() => _LoginByPhoneState();
}

class _LoginByPhoneState extends State<LoginByPhone> {
  ValueNotifier<String> phone = ValueNotifier<String>('');
  Country country = getSaudiArabiaCountry();
  String hintText = '           ';
  bool _isOtpSheetShown = false;

  @override
  void initState() {
    super.initState();

    phone.addListener(() {
      hintListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => sl<AuthCubit>(),
      child: Column(
        children: [
          SizedBox(height: 50.rh),
          DesignSystem.avatarTitleSubtitle(
            title: SMText.loginNow2,
            subTitle: SMText.weWillSendYouAVerificationCodeInATextMessage,
          ),
          SizedBox(height: 36.rh),
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              // width: 190.rw,
              // width: 250.rw,
              height: 49.rh,
              child: Stack(
                children: [
                  Center(child: Text(phone.value, style: TextStyles.s_38_500.copyWith(letterSpacing: .15))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        hintText,
                        style: TextStyles.s_38_500.copyWith(color: ColorsPallets.neutralSolid100, letterSpacing: .15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: HardCodedKeyboard(
              textNotifier: phone,
              maxNumbers: 13,
              onCountryChanged: (country) => this.country = country,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.rw),
            child: Column(
              children: [
                BlocConsumer<AuthCubit, AuthState>(
                  listenWhen: (prevState, state) =>
                      state.sendOtpStatus != prevState.sendOtpStatus ||
                      state.verifyOtpStatus != prevState.verifyOtpStatus,
                  listener: (context, state) {
                    if (state.sendOtpStatus.isSuccess && !_isOtpSheetShown) {
                      _isOtpSheetShown = true;
                      primaryCupertinoBottomSheet(
                        child: OtpScreen(
                          isCreateAccount: false,
                          authCubit: context.read<AuthCubit>(), // Pass the parent's AuthCubit
                          countryCode: country.dialCode,
                          phoneNumber: phone.value.replaceAll(" ", ""),
                          sessionId: widget.sessionId,
                        ),
                      ).then((_) {
                        // Reset the flag when the bottom sheet is dismissed
                        _isOtpSheetShown = false;
                      });
                    }
                    if (state.verifyOtpStatus.isSuccess) {
                      // Close the login by phone bottom sheet after successful verification
                      Navigator.of(context).pop();
                    }
                  },
                  buildWhen: (prevState, state) => state.sendOtpStatus != prevState.sendOtpStatus,
                  builder: (context, state) => ValueListenableBuilder(
                    valueListenable: phone,
                    builder: (context, value, child) => DesignSystem.primaryButton(
                      borderRadius: 14,
                      title: SMText.login,
                      isDisabled: textLengthWithoutSpaces < 9,
                      showLoading: state.sendOtpStatus.isLoading,
                      onPressed: () async {
                        String phoneNumber = phone.value.replaceAll(" ", "");
                        if (phoneNumber.startsWith("0")) {
                          phoneNumber = phoneNumber.substring(1);
                        }

                        sl<AuthCubit>().sendOtp(
                          countryCode: country.dialCode,
                          phone: phoneNumber,
                          sessionId: widget.sessionId,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.rh),

                DesignSystem.noAccCreateOne(
                  onPressed: () {
                    smNavigatorKey.currentState?.pop();
                    primaryCupertinoBottomSheet(child: Register());
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 30.rh),
        ],
      ),
    );
  }

  String get phoneWithoutSpaces => phone.value.replaceAll(' ', '');

  int get textLengthWithoutSpaces => phoneWithoutSpaces.length;

  int phoneTextLength = 0;

  void hintListener() {
    bool isAddLetter = phone.value.length > phoneTextLength;
    bool isAddLetterWithSpace = phone.value.length > (phoneTextLength + 1);
    bool isRemovedLetterWithSpace = (phone.value.length + 2) == phoneTextLength;
    final text = phone.value;
    phoneTextLength = text.length;
    smPrint('phoneTextLength:$phoneTextLength');
    smPrint('isRemovedLetterWithSpace:$isRemovedLetterWithSpace');
    if (isAddLetterWithSpace) {
      if (hintText.isNotEmpty) {
        hintText = hintText.substring(1);
      }

      if (hintText.isNotEmpty) {
        hintText = hintText.substring(1);
      }
    } else if (isAddLetter) {
      smPrint('added');
      // If a letter is added, remove a letter from the beginning of hintText
      if (hintText.isNotEmpty) {
        hintText = hintText.substring(1);
      }
    } else if (isRemovedLetterWithSpace) {
      smPrint('isRemovedLetterWithSpace');
      // hintText = lastLoggedInPhone[phoneTextLength + 1] + hintText;
      // hintText = lastLoggedInPhone[phoneTextLength] + hintText;
    } else {
      // If a letter is removed, add a letter from lastLoggedInPhone to hintText
      smPrint('phoneTextLength:$phoneTextLength');
      smPrint('hintText:$hintText');
      if (phoneTextLength != 0) {
        // hintText = lastLoggedInPhone[phoneTextLength - 1] + hintText;
      }
      // hintText = lastLoggedInPhone[phoneTextLength] + hintText;
    }

    if (mounted) {
      setState(() {});
    }
  }
}
