import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sm_ai_support/src/constant/texts.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:video_player/video_player.dart';

/// Video player page for viewing video messages with caching support
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final bool allowFullscreen;
  final bool autoPlay;

  const VideoPlayerPage({super.key, required this.videoUrl, this.allowFullscreen = true, this.autoPlay = true});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      smPrint('🎬 Initializing video player for: ${widget.videoUrl}');

      // Always download and cache first to avoid byte-range issues with R2/presigned URLs
      // This ensures the video player works with a local file
      smPrint('📥 Downloading video to cache...');
      final file = await DefaultCacheManager().getSingleFile(widget.videoUrl);

      if (file.existsSync()) {
        smPrint('✅ Video downloaded successfully - playing from local file');
        _videoPlayerController = VideoPlayerController.file(file);
      } else {
        throw Exception('Failed to download video file');
      }

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: false,
        allowFullScreen: widget.allowFullscreen,
        allowMuting: true,
        showControls: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(SMText.failedToLoadVideo, style: TextStyle(color: Colors.white)),
                SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      smPrint('✅ Video player initialized - ready to stream');
    } catch (e) {
      smPrint('❌ Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => context.smPop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 20), // Add bottom padding for controls
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(SMText.loadingVideo, style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(SMText.failedToLoadVideo, style: TextStyle(color: Colors.white, fontSize: 18)),
              SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _initializePlayer();
                },
                icon: Icon(Icons.refresh),
                label: Text(SMText.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null) {
      return Center(child: Chewie(controller: _chewieController!));
    }

    return Center(
      child: Text(SMText.videoPlayerNotAvailable, style: TextStyle(color: Colors.white)),
    );
  }
}
