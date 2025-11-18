import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/models/session_messages_model.dart';
import 'package:sm_ai_support/src/core/models/upload_model.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/image_url_resolver.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/support/views/video_player_page.dart';
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

  @override
  void didUpdateWidget(VideoMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize if the message content changed
    if (oldWidget.message.content != widget.message.content) {
      _disposeController();
      _initializeVideoThumbnail();
    }
  }

  void _disposeController() {
    _videoController?.dispose();
    _videoController = null;
    _isInitialized = false;
    _hasError = false;
  }

  Future<void> _initializeVideoThumbnail() async {
    try {
      String? videoSource = widget.message.content;

      // For optimistic messages with local file path
      if (widget.message.isOptimistic && videoSource.startsWith('/')) {
        smPrint('🎬 Initializing local video thumbnail for optimistic message: $videoSource');
        _videoController = VideoPlayerController.file(File(videoSource));

        await _videoController!.initialize();
        await _videoController!.seekTo(const Duration(seconds: 1)); // Seek to 1 second for better thumbnail
        await _videoController!.pause();

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          smPrint('✅ Local video thumbnail initialized');
        }
        return;
      }

      // For non-optimistic messages
      if (widget.message.isOptimistic) return;

      // Resolve URL if needed
      if (!ImageUrlResolver.isDirectDownloadUrl(widget.message.content)) {
        final fileName = ImageUrlResolver.extractFileName(widget.message.content);
        videoSource = await ImageUrlResolver.resolveMediaUrl(
          fileName: fileName,
          sessionId: widget.sessionId,
          category: FileUploadCategory.sessionMedia,
        );
      }

      if (videoSource == null || !mounted) return;

      smPrint('🎬 Initializing video thumbnail for: $videoSource');

      // Download and cache the video first (same as VideoPlayerPage)
      smPrint('📥 Downloading video to cache...');
      final file = await DefaultCacheManager().getSingleFile(videoSource);

      if (!file.existsSync()) {
        throw Exception('Failed to download video file');
      }

      smPrint('✅ Video downloaded - initializing player');
      _videoController = VideoPlayerController.file(file);

      await _videoController!.initialize();
      await _videoController!.seekTo(const Duration(seconds: 1)); // Seek to 1 second for better thumbnail
      await _videoController!.pause();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        smPrint('✅ Video thumbnail initialized');
      }
    } catch (e) {
      smPrint('❌ Error initializing video thumbnail: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _disposeController();
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
            // if (widget.message.isOptimistic)
            //   Positioned.fill(
            //     child: Container(
            //       decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            //       child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    // Show error state
    if (_hasError) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.error_outline,
            size: 32.rSp,
            color: ColorsPallets.subdued400,
          ),
        ),
      );
    }

    // Show loading state while initializing (for both optimistic and regular videos)
    if (!_isInitialized || _videoController == null) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.video_library,
              size: 32.rSp,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Show actual video thumbnail (first frame) - works for both optimistic and regular videos
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
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
