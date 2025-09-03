import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

primarySnackBar(
  BuildContext context, {
  required String message,
  Widget? prefixWidget,
  EdgeInsetsGeometry? margin,
  bool isShowPrefixWidget = true,
  String pngIcon = 'error',
}) {
  try {
    // Try to find ScaffoldMessenger in the current context
    ScaffoldMessenger.of(context).showSnackBar(__snackBar(margin, isShowPrefixWidget, prefixWidget, pngIcon, message));
  } catch (e) {
    // Fallback: Use the root navigator context if ScaffoldMessenger is not found
    try {
      ScaffoldMessenger.of(smNavigatorKey.currentContext!).showSnackBar(__snackBar(margin, isShowPrefixWidget, prefixWidget, pngIcon, message));
    } catch (e2) {
      // Last resort: Show a simple overlay
      _showOverlaySnackBar(context, message);
    }
  }
}

void _showOverlaySnackBar(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 100.0,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 18.0),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  
  overlay.insert(overlayEntry);
  
  // Remove after 3 seconds
  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

SnackBar __snackBar(
    EdgeInsetsGeometry? margin, bool isShowPrefixWidget, Widget? prefixWidget, String pngIcon, String message) {
  return SnackBar(
      backgroundColor: ColorsPallets.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: margin ?? EdgeInsets.only(bottom: 32.rh),
      duration: Duration(seconds: 2),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DesignSystem.blurEffect(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: 12.rSp.br,
                color: ColorsPallets.black.withValues(alpha: .76),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 14.rh),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isShowPrefixWidget || prefixWidget != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: 6.rw),
                      child: prefixWidget ?? DesignSystem.pngIcon(pngIcon, size: 18.rSp),
                    ),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.s_12_400.copyWith(color: ColorsPallets.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ));
}
