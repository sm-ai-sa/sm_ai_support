import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:video_player/video_player.dart';

enum VideoLoadingState { loading, loaded, failed }

// enum PlayerStatus { playing, paused }

class ViewVideo extends StatefulWidget {
  ///* Pass the video url
  final String videoUrl;

  ///* Pass the [onPressed] Callback for more icon clicked
  final VoidCallback? onPressed;

  const ViewVideo({super.key, required this.videoUrl, this.onPressed});

  @override
  State<ViewVideo> createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  ValueNotifier<VideoLoadingState> videoLoadingStateNotifier = ValueNotifier(VideoLoadingState.loading);

  final _cacheManager = DefaultCacheManager();

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  //* Initializing video player
  Future _initVideoPlayer() async {
    try {
      smPrint('⭐️⭐️ Start loading video');
      File videoFile = await _cacheManager.getSingleFile(widget.videoUrl);
      smPrint('⭐️⭐️ After CacheManager');
      _controller = VideoPlayerController.file(videoFile);
      await _controller.initialize();
      smPrint('⭐️⭐️ After Initialize Video controller');

      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: true,
        showControls: true,
        allowFullScreen: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: ColorsPallets.primaryColor,
          handleColor: ColorsPallets.primaryColor,
          backgroundColor: Colors.black,
          bufferedColor: Colors.grey[300]!,
        ),
        placeholder: DesignSystem.loadingIndicator(color: Colors.white),
        autoInitialize: true,
      );
      smPrint('⭐️⭐️ After Setting Chewie Controller');
      if (mounted) {
        smPrint('⭐️⭐️ If Mounted');
        setState(() {});
        _addListernerToController();
      }
    } catch (e) {
      smPrint("-----$e");
      videoLoadingStateNotifier.value = VideoLoadingState.failed;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }

  //* Listen to controller
  _addListernerToController() {
    smPrint('⭐️⭐️ Add Listener to Controller');
    videoLoadingStateNotifier.value = VideoLoadingState.loaded;
    _controller.play();
    // _controller.addListener(() async {
    //   //* Pause player
    //   if (_controller.value.duration == _controller.value.position) {
    //     playerStatus.value = PlayerStatus.paused;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPallets.black,
      body: Padding(
        padding: EdgeInsets.only(top: 35.rSp, bottom: 35.rSp),
        child: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: videoLoadingStateNotifier,
              builder: (context, VideoLoadingState videoLoadingState, child) {
                if (videoLoadingState == VideoLoadingState.loading) {
                  return Center(child: DesignSystem.loadingIndicator(color: Colors.white));
                } else if (videoLoadingState == VideoLoadingState.failed) {
                  return Text(SMText.somethingWentWrong, style: TextStyles.s_14_500.copyWith(color: Colors.white));
                } else {
                  return videoLoadingState == VideoLoadingState.loaded
                      ? Center(
                          child: Chewie(controller: _chewieController),
                        )
                      : Center(child: DesignSystem.loadingIndicator(color: Colors.white));
                }
              },
            ),
            IconButton(
              onPressed: widget.onPressed ?? () => context.smPop(),
              padding: EdgeInsets.symmetric(horizontal: 15.rw),
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 25.rSp,
              ),
            )
          ],
        ),
      ),
    );
  }
}
