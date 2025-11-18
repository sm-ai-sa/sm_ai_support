import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/primary_bottom_sheet.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/features/support/bottom_sheet/sm_support_bottom_sheet.dart';

/// Wrapper for the bottom sheet with custom styling and dismissal handling
class BottomSheetWrapper {
  /// Show the support bottom sheet using the parent app's context
  static Future<void> show({
    required BuildContext context,
    required SMSupportData smSupportData,
  }) async {
    return primaryCupertinoBottomSheet(
      context: context,
      backgroundColor: ColorsPallets.white,
      isDismissible: true,
      enableDragDismiss: true,
      child: SMSupportBottomSheet(smSupportData: smSupportData),
    );
  }
}
