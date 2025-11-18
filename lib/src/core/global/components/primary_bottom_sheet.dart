import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

// ** Takes the height of the passed child ** //
// ** Resizing the bottom sheet height if widget is hidden ** //
// ** Pushes child widget when keyboard opens ** //

Future primaryBottomSheet({
  bool showLeadingContainer = false,
  required Widget child,
  bool isDismissible = true,
  bool isPreventPop = false,
  bool enableDrag = true,
  bool enableKeyBoardMargin = true,
  bool isTransparentBarrierColor = false,
  bool isShowToLine = false,
  Widget? alignedWidget,
  EdgeInsets? containerPadding,
  EdgeInsetsGeometry? bottomSheetPadding,
  double? bottomSheetHeight,
  bool isAbleToScroll = true,
}) async {
  return await showModalBottomSheet(
    elevation: 0,
    context: smNavigatorKey.currentContext!,
    isScrollControlled: true,
    isDismissible: isPreventPop ? false : isDismissible,
    enableDrag: isPreventPop ? false : enableDrag,
    backgroundColor: ColorsPallets.transparent,
    barrierColor: isTransparentBarrierColor ? ColorsPallets.transparent : const Color(0xff000000).withOpacity(.4),
    builder: (context) {
      return Padding(
        padding: bottomSheetPadding ?? EdgeInsets.zero,
        child: PopScope(
          canPop: !isPreventPop,
          child: SizedBox(
            height: bottomSheetHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: isShowToLine,
                      child: Container(
                        height: 5.rh,
                        width: 100.rw,
                        margin: EdgeInsets.only(bottom: 8.rh),
                        decoration: BoxDecoration(color: ColorsPallets.white, borderRadius: 20.rSp.br),
                      ),
                    ),
                    bottomSheetHeight != null
                        ? Expanded(
                            child: containerOfPrimaryBottomSheet(
                              isAbleToScroll: isAbleToScroll,
                              isExpand: true,
                              child: child,
                              enableKeyBoardMargin: enableKeyBoardMargin,
                              showLeadingContainer: showLeadingContainer,
                              containerPadding: containerPadding,
                            ),
                          )
                        : containerOfPrimaryBottomSheet(
                            isAbleToScroll: isAbleToScroll,
                            isExpand: false,
                            child: child,
                            enableKeyBoardMargin: enableKeyBoardMargin,
                            showLeadingContainer: showLeadingContainer,
                            containerPadding: containerPadding,
                          ),
                  ],
                ),
                if (alignedWidget != null) alignedWidget,
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget containerOfPrimaryBottomSheet({
  required Widget child,
  bool enableKeyBoardMargin = true,
  bool showLeadingContainer = false,
  EdgeInsets? containerPadding,
  bool isAbleToScroll = true,
  bool isExpand = false,
}) {
  return Container(
    margin: enableKeyBoardMargin ? MediaQuery.of(smNavigatorKey.currentContext!).viewInsets : null,
    padding: containerPadding,
    constraints: BoxConstraints(maxHeight: 92.h),
    decoration: BoxDecoration(
      color: ColorsPallets.white,
      borderRadius: BorderRadius.only(topLeft: 16.rSp.rBr, topRight: 16.rSp.rBr),
    ),
    child: isAbleToScroll
        ? SingleChildScrollView(child: columnOfLeadingNotchAndChild(isExpand: false, showLeadingContainer, child))
        : columnOfLeadingNotchAndChild(isExpand: isExpand, showLeadingContainer, child),
  );
}

Column columnOfLeadingNotchAndChild(bool showLeadingContainer, Widget child, {bool isExpand = false}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Visibility(
        visible: showLeadingContainer,
        child: Container(
          padding: EdgeInsets.only(top: 12.rh),
          alignment: Alignment.center,
          child: Container(
            width: 26.rSp,
            height: 3.rSp,
            decoration: BoxDecoration(color: ColorsPallets.pressed100, borderRadius: 50.rSp.br),
          ),
        ),
      ),
      isExpand ? Expanded(child: child) : child,
    ],
  );
}

Future primaryCupertinoBottomSheet({
  required Widget child,
  BuildContext? context,
  bool isShowCloseIcon = false,
  bool haveBarrierColor = false,
  bool enableDragDismiss = true,
  bool showSwipeCloseIndicator = false,
  double? height,
  bool useDynamicHeight = false,
  EdgeInsets? padding,
  Widget? bottomBarWidget,
  Color? backgroundColor,
  Widget? backButtonWidget,
  Function()? onClosePressed,
  Function()? onBackPressed,
  bool? isDismissible,
}) async {
  return await showCupertinoModalBottomSheet(
    barrierColor: haveBarrierColor ? Colors.black.withValues(alpha: 0.8) : null,
    context: context ?? smNavigatorKey.currentContext!,
    backgroundColor: backgroundColor ?? ColorsPallets.white,
    topRadius: 14.rSp.rBr,
    isDismissible: isDismissible ?? true,
    duration: const Duration(milliseconds: 300),
    enableDrag: enableDragDismiss,
    expand: !useDynamicHeight,
    builder: (context) {
      final Widget content = Column(
        mainAxisSize: useDynamicHeight ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Visibility(
            visible: showSwipeCloseIndicator,
            child: Container(
              width: 24.rw,
              height: 4.rh,
              margin: EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: 100.br,
                color: ColorsPallets.neutralSolid100,
              ),
            ),
          ),
          if (useDynamicHeight) child else Expanded(child: child),
        ],
      );

      return useDynamicHeight
          ? MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                padding: padding ?? EdgeInsets.zero,
                decoration: BoxDecoration(color: backgroundColor ?? ColorsPallets.white),
                child: Stack(
                  children: [
                    content,
                    if (isShowCloseIcon)
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(start: 20.rw, top: 31.rh),
                          child: DesignSystem.closeButton(onTap: onClosePressed),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : SizedBox(
              height: height ?? MediaQuery.of(context).size.height,
              child: Scaffold(
                backgroundColor: backgroundColor ?? ColorsPallets.white,
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: padding ?? EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(color: backgroundColor ?? ColorsPallets.white),
                  child: Stack(
                    children: [
                      content,
                      if (isShowCloseIcon)
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(start: 20.rw, top: 31.rh),
                            child: DesignSystem.closeButton(onTap: onClosePressed),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
    },
  );
}
