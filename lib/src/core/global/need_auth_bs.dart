import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/features/auth/views/login_by_phone.dart';
import 'package:sm_ai_support/src/features/auth/views/register.dart';

class NeedAuthBS extends StatelessWidget {
  const NeedAuthBS({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.rw, vertical: 20.rh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top spacing
          // SizedBox(height: 20.rh),

          // Lock icon
          Center(child: DesignSystem.svgIcon('warning', size: 56.rSp)),

          // Spacing
          SizedBox(height: 24.rh),

          // Title
          Text(
            SMText.loginRequired,
            style: TextStyles.s_20_600.copyWith(color: ColorsPallets.loud900),
            textAlign: TextAlign.center,
          ),

          // Spacing
          SizedBox(height: 6.rh),

          // Description
          Text(
            SMText.loginRequiredMessage,
            style: TextStyles.s_13_400.copyWith(color: ColorsPallets.subdued400),
            textAlign: TextAlign.center,
          ),

          // Spacing
          SizedBox(height: 30.rh),

          // Login button
          DesignSystem.primaryButton(
            borderRadius: 14,
            title: SMText.login,
            onPressed: () {
              smNavigatorKey.currentState?.pop();
              primaryCupertinoBottomSheet(child: LoginByPhone());
            },
            backgroundColor: ColorsPallets.primaryColor,
            width: double.infinity,
            height: 48.rh,
          ),

          // Bottom spacing
          SizedBox(height: 16.rh),

          // Rich text
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: SMText.dontHaveAccount,
                  style: TextStyles.s_12_400.copyWith(color: ColorsPallets.subdued400),
                ),
                TextSpan(
                  text: ' ',
                  style: TextStyles.s_12_400.copyWith(color: ColorsPallets.subdued400),
                ),

                TextSpan(
                  text: SMText.createNewAccount,
                  style: TextStyles.s_12_400.copyWith(color: ColorsPallets.primaryColor),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      smNavigatorKey.currentState?.pop();
                      primaryCupertinoBottomSheet(child: Register());
                    },
                ),
              ],
            ),
          ),

          SizedBox(height: 20.rh),
        ],
      ),
    );
  }
}
