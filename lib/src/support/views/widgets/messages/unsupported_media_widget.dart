import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

/// Unsupported media message widget
class UnsupportedMediaWidget extends StatelessWidget {
  final SessionMessage message;
  final bool isMyMessage;
  final Color? tenantColor;

  const UnsupportedMediaWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.tenantColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.rSp),
      decoration: BoxDecoration(
        color: ColorsPallets.disabled0,
        border: Border.all(color: ColorsPallets.disabled25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning icon
          DesignSystem.svgIcon(
            'warning_circle',
            size: 20.rSp,
            color: ColorsPallets.subdued400,
          ),
          SizedBox(width: 8.rw),
          // Message text
          Flexible(
            child: Text(
              SMText.unsupportedAttachment,
              style: TextStyles.s_13_400.copyWith(color: ColorsPallets.subdued400),
            ),
          ),
        ],
      ),
    );
  }
}

