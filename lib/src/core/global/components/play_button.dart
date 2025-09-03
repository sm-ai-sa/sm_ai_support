import 'dart:ui';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/aniamations/fade_in.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class PlayButton extends StatefulWidget {
  final CachedVideoPlayerPlusController videoController;

  const PlayButton({required this.videoController, super.key});

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  @override
  Widget build(BuildContext context) {
    return FadeIn(
      isShow: widget.videoController.value.isPlaying == false && widget.videoController.value.isInitialized,
      child: InkWell(
        onTap: () {
          widget.videoController.play();
          setState(() {});
        },
        child: Material(
          elevation: 0,
          clipBehavior: Clip.hardEdge,
          color: ColorsPallets.transparent,
          shape: const CircleBorder(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 64.rSp,
              width: 64.rSp,
              decoration: BoxDecoration(shape: BoxShape.circle, color: ColorsPallets.neutral900.withOpacity(.16)),
              child: Center(
                child: DesignSystem.svgIcon('play', size: 32.rSp),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
