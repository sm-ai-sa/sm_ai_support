import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class AppBarWithGradient extends StatelessWidget {
  final String? title;
  final Widget? suffix;
  const AppBarWithGradient({
    super.key,
    this.title,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168.rh,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          ColorsPallets.black.withOpacity(.72),
          ColorsPallets.black.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
      padding: const EdgeInsets.only(top: 60, left: 22, right: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DesignSystem.closeButton(
            iconColor: Colors.white,
            onTap: () {
              context.smPop();
            },
          ),
          if (suffix != null) ...[
            Spacer(),
            suffix!,
          ],
        ],
      ),
    );
  }
}
