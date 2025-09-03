import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class HiddenOtpProgress extends StatelessWidget {
  final int totalCount;
  final int progressCount;
  final bool isErrorStyle;

  const HiddenOtpProgress({
    super.key,
    required this.progressCount,
    required this.totalCount,
    this.isErrorStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      textDirection: TextDirection.ltr,
      alignment: WrapAlignment.center,
      direction: Axis.horizontal,
      spacing: 20.rw,
      children: List.generate(totalCount, (index) {
        return point(isActive: (index + 1) <= progressCount);
      }),
    );
  }

  Widget point({bool isActive = false}) {
    return AnimatedContainer(
      duration: 300.milliseconds,
      width: 11.rSp,
      height: 11.rSp,
      decoration: BoxDecoration(
        color: isActive && isErrorStyle
            ? ColorsPallets.secondaryRed100
            : isActive
            ? ColorsPallets.primaryColor
            : null,
        gradient: !isActive && !isErrorStyle
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffE9E8E7), Color(0x00fff8f8)],
              )
            : null,
        border: (isActive && !isErrorStyle) ? null : Border.all(width: 1.rSp, color: const Color(0xffF8F8F7)),
        shape: BoxShape.circle,
      ),
    );
  }
}
