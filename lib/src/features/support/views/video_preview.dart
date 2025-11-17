import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/app_bar_with_gradient.dart';
import 'package:sm_ai_support/src/core/global/components/bottom_progress_container.dart';
import 'package:sm_ai_support/src/core/global/components/play_button.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/primary_snack_bar.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  const VideoPreview({required this.url, super.key});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late CachedVideoPlayerPlusController videoController;
  double totalDuration = 0.0;
  double currentProgressDuration = 0.0;
  double progressValue = 0.0;
  bool isShowDetails = false;

  @override
  void initState() {
    videoController = CachedVideoPlayerPlusController.networkUrl(Uri.parse(widget.url));
    videoController.initialize().then((value) {
      videoController.play();
      setState(() {});

      videoController.addListener(checkVideo);
      videoController.addListener(checkVideoProgress);
    }).catchError((error) {
      smPrint('Error initializing video player: $error');
      primarySnackBar(context, message: SMText.somethingWentWrong);
    });

    super.initState();
  }

  void checkVideo() {
    if (videoController.value.position == videoController.value.duration) {
      videoController.seekTo(const Duration(seconds: 0)).then((v) {
        videoController.pause().then((v) {
          setState(() {});
        });
      });
    }
  }

  void checkVideoProgress() {
    // smPrint('>>>>>>>>> checkVideo_________');
    totalDuration = videoController.value.duration.inMilliseconds.toDouble();
    currentProgressDuration = videoController.value.position.inMilliseconds.toDouble();
    progressValue = currentProgressDuration / totalDuration;
    setState(() {});
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    videoController.removeListener(checkVideo);
    videoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    bool isOrientationLanscape = (orientation == Orientation.landscape);
    return Scaffold(
      backgroundColor: ColorsPallets.transparent,
      body: Stack(
        children: [
          //* Video Section ____________________________

          Stack(
            children: [
              Center(
                child: videoController.value.isInitialized
                    ? InkWell(
                        onTap: () {
                          videoController.pause();
                          setState(() {});
                        },
                        child: LayoutBuilder(
                          builder: (_, constraints) {
                            return AspectRatio(
                                aspectRatio: videoController.value.aspectRatio,
                                child: CachedVideoPlayerPlus(videoController));
                          },
                        ),
                      )
                    : DesignSystem.loadingIndicator(),
              ),
              //* Bottom Section With progress bar ____________________________
              if (!isOrientationLanscape)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomProgressContainer(
                    progressValue: progressValue,
                    totalDuration: totalDuration,
                    videoController: videoController,
                  ),
                ),

              //* View When Lanscape Orientation ____________________________
              if (isOrientationLanscape) ...{
                Align(
                  alignment: Alignment.centerRight,
                  child: landscapeRightSideShadow(),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.rh, right: 30.rw, left: 30.rw),
                    child: DesignSystem.svgIcon('flipped_corners', size: 32.rSp, onTap: () {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]);
                    }),
                  ),
                )
              },
              Align(
                alignment: Alignment.center,
                child: PlayButton(videoController: videoController),
              ),
            ],
          ),
          if (!isOrientationLanscape)
            AppBarWithGradient(
              suffix: DesignSystem.svgIcon('corners', size: 32.rSp, onTap: () {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                ]);
              }),
            ),
        ],
      ),
    );
  }

  Widget landscapeRightSideShadow() {
    return Container(
      height: double.infinity,
      width: 117,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          ColorsPallets.black.withOpacity(.64),
          ColorsPallets.black.withOpacity(0.0),
        ],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      )),
    );
  }

  BoxDecoration bottomGradientDecoration() {
    return BoxDecoration(
        gradient: LinearGradient(
      colors: [
        ColorsPallets.black.withOpacity(.80),
        ColorsPallets.black.withOpacity(0.0),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ));
  }
}
