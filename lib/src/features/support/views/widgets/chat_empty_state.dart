import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/global/components/tenant_logo.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

/// Empty state widget shown when there are no messages in chat
class ChatEmptyState extends StatelessWidget {
  final String? logoFileName;
  final String tenantId;

  const ChatEmptyState({
    super.key,
    required this.logoFileName,
    required this.tenantId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 140.rh),
        TenantLogoHelper.standard(logoFileName: logoFileName, tenantId: tenantId, size: 80),
        SizedBox(height: 20.rh),
        Text(SMText.startChat, style: TextStyles.s_20_400, textAlign: TextAlign.center),
        SizedBox(height: 8.rh),
      ],
    );
  }
}

