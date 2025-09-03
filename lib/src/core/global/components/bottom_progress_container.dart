import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/components/linear_slider_progress.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class BottomProgressContainer extends StatefulWidget {
  final bool isPreview;
  final double totalDuration;
  final double progressValue;
  final CachedVideoPlayerPlusController videoController;

  const BottomProgressContainer({
    super.key,
    this.isPreview = false,
    required this.totalDuration,
    required this.videoController,
    required this.progressValue,
  });

  @override
  State<BottomProgressContainer> createState() => _BottomProgressContainerState();
}

class _BottomProgressContainerState extends State<BottomProgressContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearSliderProgress(
          onDrag: (_, percentDuration, __) {
            if (widget.totalDuration != 0) {
              widget.videoController
                  .seekTo(Duration(milliseconds: (widget.totalDuration * (percentDuration / 100)).toInt()));
            }
          },
          percentValue: widget.progressValue * 100,
          maxValue: 100,
          color: ColorsPallets.primaryColor,
          backgroundColor: ColorsPallets.primaryColor.withOpacity(0.3),
          handlerSize: 4.rSp,
          widgetHeight: 4.rSp,
        ),
        SizedBox(height: 50.rh),
        // Container(
        //   color: widget.isPreview ? ColorsPallets.white : ColorsPallets.neutral900,
        //   height: widget.isPreview ? 84.rh : 65.rh,
        //   padding: EdgeInsets.only(top: 12.rh, bottom: 32.rh, right: 20.rw, left: 20.rw),
        //   child: widget.isPreview
        //       ? Row(
        //           children: [
        //             Expanded(
        //               child: PrimaryButton(
        //                 isBorderStyle: true,
        //                 text: LocaleKeys.addRevision.tr(),
        //                 onTap: () {
        //                   primaryBottomSheet(child: const AddRevisionBottomSheet());
        //                 },
        //               ),
        //             ),
        //             horizontalSpace(12.rw),
        //             Expanded(
        //               child: PrimaryButton(
        //                 text: LocaleKeys.approve.tr(),
        //               ),
        //             ),
        //           ],
        //         )
        //       : Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             DesignSystem.svgIcon('circle-double-up', size: 18.rSp),
        //             horizontalSpace(8.rw),
        //             Text(
        //               LocaleKeys.swipeUpToSeeNextProject.tr(),
        //               style: TextStyles.s_14_400.copyWith(color: ColorsPallets.neutral300),
        //             )
        //           ],
        //         ),
        // ),
      ],
    );
  }
}
