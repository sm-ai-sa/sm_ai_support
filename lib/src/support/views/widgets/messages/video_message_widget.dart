import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/models/upload_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/image_url_resolver.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/support/views/video_player_page.dart';
import 'package:video_player/video_player.dart';

/// Video message widget with actual video thumbnail and play button
class VideoMessageWidget extends StatefulWidget {
  final SessionMessage message;
  final bool isMyMessage;
  final String sessionId;
  final Color? tenantColor;

  const VideoMessageWidget({
    super.key,
    required this.message,
    required this.isMyMessage,
    required this.sessionId,
    this.tenantColor,
  });

  @override
  State<VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoThumbnail();
  }

  Future<void> _initializeVideoThumbnail() async {
    if (widget.message.isOptimistic) return;

    try {
      String? videoUrl = widget.message.content;

      // Resolve URL if needed
      if (!ImageUrlResolver.isDirectDownloadUrl(widget.message.content)) {
        final fileName = ImageUrlResolver.extractFileName(widget.message.content);
        videoUrl = await ImageUrlResolver.resolveMediaUrl(
          fileName: fileName,
          sessionId: widget.sessionId,
          category: FileUploadCategory.sessionMedia,
        );
      }

      if (videoUrl == null || !mounted) return;

      smPrint('🎬 Loading video thumbnail for: $videoUrl');

      // For thumbnail, check cache first, otherwise download in background
      final fileInfo = await DefaultCacheManager().getFileFromCache(videoUrl);

      if (fileInfo != null && fileInfo.file.existsSync()) {
        smPrint('✅ Using cached video for thumbnail');
        _videoController = VideoPlayerController.file(fileInfo.file);

        await _videoController!.initialize();
        await _videoController!.seekTo(Duration.zero);
        await _videoController!.pause();

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
        smPrint('✅ Video thumbnail loaded from cache');
      } else {
        // Video not cached - start background download but don't wait
        smPrint('📥 Video not cached, downloading in background...');
        DefaultCacheManager().getSingleFile(videoUrl).then((file) {
          smPrint('✅ Video downloaded to cache');
        }).catchError((e) {
          smPrint('⚠️ Failed to cache video: $e');
        });

        // Show placeholder instead of trying to load thumbnail from network
        if (mounted) {
          setState(() {
            _hasError = false;
            _isInitialized = false; // Keep showing loading state
          });
        }
        smPrint('ℹ️ Thumbnail will be available after video is cached');
      }
    } catch (e) {
      smPrint('❌ Error loading video thumbnail: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminBgColor = (widget.tenantColor ?? ColorsPallets.primaryColor).withValues(alpha: .1);
    final adminBorderColor = (widget.tenantColor ?? ColorsPallets.primaryColor).withValues(alpha: .25);

    return InkWell(
      onTap: () => _openVideoPlayer(context),
      child: Container(
        // padding: EdgeInsets.all(8.rSp),
        decoration: BoxDecoration(
          color: widget.isMyMessage ? ColorsPallets.normal25 : adminBgColor,
          border: Border.all(color: widget.isMyMessage ? ColorsPallets.borderColor : adminBorderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video thumbnail or placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 200.rw, height: 150.rh, child: _buildThumbnail()),
            ),
            // Play button overlay with glassy effect
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(12.rSp),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.1)],
                    ),
                    borderRadius: BorderRadius.circular(100),

                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: Offset(0, 8)),
                      BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, -2)),
                    ],
                  ),

                  child: DesignSystem.svgIcon('play', size: 17.rSp, fit: BoxFit.contain),
                ),
              ),
            ),
            // Optimistic loading indicator
            if (widget.message.isOptimistic)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                  child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (widget.message.isOptimistic) {
      return Container(
        color: Colors.black12,
        child: Icon(Icons.videocam, size: 48.rSp, color: ColorsPallets.subdued400),
      );
    }

    if (_hasError) {
      return Container(
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 32.rSp, color: ColorsPallets.subdued400),
            SizedBox(height: 4.rh),
            Text(SMText.video, style: TextStyles.s_12_400.copyWith(color: ColorsPallets.subdued400)),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black12,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(widget.tenantColor ?? ColorsPallets.primary300),
          ),
        ),
      );
    }

    // Show video first frame as thumbnail
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  /// Open video player with resolved URL
  Future<void> _openVideoPlayer(BuildContext context) async {
    if (widget.message.isOptimistic) return; // Don't play optimistic videos

    String? videoUrl = widget.message.content;

    // Resolve URL if needed
    if (!ImageUrlResolver.isDirectDownloadUrl(widget.message.content)) {
      final fileName = ImageUrlResolver.extractFileName(widget.message.content);
      videoUrl = await ImageUrlResolver.resolveMediaUrl(
        fileName: fileName,
        sessionId: widget.sessionId,
        category: FileUploadCategory.sessionMedia,
      );
    }

    if (videoUrl != null && context.mounted) {
      context.smPush(VideoPlayerPage(videoUrl: videoUrl));
    }
  }
}
