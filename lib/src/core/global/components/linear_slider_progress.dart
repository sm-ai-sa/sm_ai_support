import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';

import '../../theme/colors.dart';
import '../../utils/extension/size_extension.dart';

class LinearSliderProgress extends StatelessWidget {
  /// (_,val,__) val is percentValue
  final Function(int, dynamic, dynamic) onDrag;

  final Color? color;
  final Color? backgroundColor;
  final double? lineHeight;
  final double percentValue;
  final double maxValue;
  final double? handlerSize;
  final double? widgetHeight;
  final Widget? centerWidget;
  final bool isBufferingProgress;
  final bool isRtl;
  const LinearSliderProgress({
    super.key,
    required this.onDrag,
    this.color,
    this.backgroundColor,
    this.lineHeight,
    required this.percentValue,
    required this.maxValue,
    this.handlerSize,
    this.widgetHeight,
    this.centerWidget,
    this.isBufferingProgress = false,
    this.isRtl = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height:
            //  handlerSize ??
            widgetHeight ?? 20.rSp,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        color: Colors.transparent,
        child: FlutterSlider(
          values: [percentValue],
          max: maxValue,
          min: 0,
          trackBar: FlutterSliderTrackBar(
            activeTrackBar: BoxDecoration(color: color ?? (ColorsPallets.primaryColor), borderRadius: 10.rSp.br),
            activeDisabledTrackBarColor: color ?? (ColorsPallets.primaryColor),
            activeTrackBarHeight: lineHeight ?? 3.rh,
            inactiveTrackBar:
                BoxDecoration(color: backgroundColor ?? ColorsPallets.black.withOpacity(.3), borderRadius: 10.rSp.br),
            inactiveTrackBarHeight: lineHeight ?? 3.rh,
          ),
          handlerWidth: handlerSize ?? 20.rSp,
          handlerHeight: handlerSize ?? 20.rSp,
          handler: FlutterSliderHandler(
            decoration: const BoxDecoration(),
            child: isBufferingProgress
                ? const SizedBox()
                : Container(
                    height: handlerSize ?? 20.rSp,
                    width: handlerSize ?? 20.rSp,
                    // margin: EdgeInsets.all(3.rSp),
                    // padding: EdgeInsets.all(3.rSp),
                    decoration: BoxDecoration(
                      color: color ?? (ColorsPallets.secondaryGreen100),
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
          tooltip: FlutterSliderTooltip(
            custom: (value) {
              return SizedBox(
                height:
                    // handlerSize ??
                    20.rSp,
                width:
                    // handlerSize ??
                    20.rSp,
              );
            },
          ),
          onDragging: onDrag,
          // disabled: isBufferingProgress,
          rtl: isRtl,
        ),
      );
    });
    //  Directionality(
    //   textDirection: isArabic
    //       ? ui.TextDirection.ltr
    //       : ui.TextDirection.ltr,
    //   child: LinearPercentIndicator(
    //     width: width ?? constraints.maxWidth,
    //     isRTL: isArabic ? true : false,
    //     //* put it false if wantes to start animation from begining with every percent change
    //     animateFromLastPercent: true,
    //     animation: true,
    //     lineHeight: lineHeight ?? 3.rh,
    //     animationDuration: duration?.inMilliseconds ?? 300,
    //     percent: percentValue,
    //     center: centerWidget,
    //     barRadius: 10.rSp.rBr,
    //     fillColor: backgroundColor ?? ColorsPallets.grey20,
    //     progressColor: color ?? ColorsPallets.primaryGreen,
    //   ),
    // )
    // ;
  }
}
