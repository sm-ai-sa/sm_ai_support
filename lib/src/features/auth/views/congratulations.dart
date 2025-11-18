import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class Congratulations extends StatefulWidget {
  const Congratulations({super.key});

  @override
  State<Congratulations> createState() => _CongratulationsState();
}

class _CongratulationsState extends State<Congratulations> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto close after 2 seconds and return to categories bottom sheet
    _timer = Timer(2.seconds, () {
      if (mounted) {
        context.smPopSheet();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPallets.secondaryGreen100,
      body: Stack(
        children: [
          Container(
            // decoration: RepeatedWidgets.backgroundShadowDecoration,
            padding: EdgeInsets.symmetric(horizontal: 30.rw),
            child: InkWell(
              onTap: () {},
              child: Column(
                children: [
                  const Row(),
                  SizedBox(height: 172.rh),
                  DesignSystem.lottieIcon(icon: 'check-circle', height: 72.rh, width: 76.rw),
                  SizedBox(height: 80.rh),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 5.rh),
                    decoration: BoxDecoration(
                      borderRadius: 9.rSp.br,
                      color: ColorsPallets.white.withValues(alpha: .15),
                      border: Border.all(width: 1.rSp, color: ColorsPallets.white.withValues(alpha: .15)),
                    ),
                    child: Text(
                      SMText.enjoyableExperience,
                      style: TextStyles.s_14_400.copyWith(color: ColorsPallets.white),
                    ),
                  ),
                  SizedBox(height: 20.rh),
                  Text(
                    SMText.congratulationsYourAccountIsNowReadyForUse,
                    textAlign: TextAlign.center,
                    style: TextStyles.s_32_400.copyWith(color: ColorsPallets.white),
                  ),
                  SizedBox(height: 8.rh),
                  Text(
                    SMText.yourAccountHasBeenCreatedOnSmPlatform,
                    textAlign: TextAlign.center,
                    style: TextStyles.s_14_400.copyWith(color: ColorsPallets.white.withValues(alpha: .7)),
                  ),
                  // const Spacer(),
                  // DesignSystem.primaryButton(
                  //   text: SMText.chooseYourInterests,
                  //   isWhiteStyle: true,
                  //   onTap: () {
                  //     context.pushTo(const ChooseInterests());
                  //   },
                  // ),
                  // SizedBox(height: 20.rh),
                  // PrimaryButton(
                  //   onTap: () {},
                  //   backgroundColor: ColorsPallets.transparent,
                  //   isCenterContent: true,
                  //   centeralWidget: RichText(
                  //     text: TextSpan(
                  //       children: [
                  //         TextSpan(
                  //           text: '${SMText.chooseInterestsLaterQuestion} ',
                  //           style: TextStyles.s_13_400.copyWith(color: ColorsPallets.white.withValues(alpha:.7)),
                  //         ),
                  //         const TextSpan(text: ' '),
                  //         TextSpan(
                  //           text: SMText.later,
                  //           style: TextStyles.s_13_400.copyWith(color: ColorsPallets.white),
                  //           recognizer: TapGestureRecognizer()
                  //             ..onTap = () {
                  //               context.pushTo(const MainScreen());
                  //             },
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 30.rh),
                ],
              ),
            ),
          ),
          // Align(
          //   alignment: AlignmentDirectional.topStart,
          //   child: Padding(
          //     padding: EdgeInsetsDirectional.only(start: 22.rw, top: 59.rh),
          //     child: DesignSystem.svgIcon(
          //       'close',
          //       onTap: () {
          //         context.smPop();
          //       },
          //       color: ColorsPallets.white,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
