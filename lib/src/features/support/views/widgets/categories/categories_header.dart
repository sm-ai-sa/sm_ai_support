import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

/// Header section with GIF, title and description
class CategoriesHeader extends StatelessWidget {
  const CategoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 18.rh),
        DesignSystem.chatGif(),
        SizedBox(height: 10.rh),
        Text(SMText.supportAndHelp, style: TextStyles.s_20_500),
        SizedBox(height: 8.rh),
        Text(
          SMText.supportAndHelpDescription,
          style: TextStyles.s_14_400.copyWith(color: ColorsPallets.subdued400),
        ),
        SizedBox(height: 24.rh),
      ],
    );
  }
}
