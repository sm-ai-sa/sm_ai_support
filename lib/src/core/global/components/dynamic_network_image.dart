import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/image_url_resolver.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

/// A widget that automatically resolves and displays network images
/// Handles both direct URLs and file names that need to be resolved via the download API
class DynamicNetworkImage extends StatefulWidget {
  final String imageSource; // Can be either a file name or direct URL
  final String sessionId; // Session ID for URL resolution
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final FileUploadCategory category;
  final Widget? placeholder;
  final Widget? errorWidget;

  const DynamicNetworkImage({
    super.key,
    required this.imageSource,
    required this.sessionId,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.category = FileUploadCategory.sessionMedia,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<DynamicNetworkImage> createState() => _DynamicNetworkImageState();
}

class _DynamicNetworkImageState extends State<DynamicNetworkImage> {
  String? _resolvedUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _resolveImageUrl();
  }

  @override
  void didUpdateWidget(DynamicNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-resolve if the image source or session ID changed
    if (oldWidget.imageSource != widget.imageSource || 
        oldWidget.sessionId != widget.sessionId) {
      _resolveImageUrl();
    }
  }

  Future<void> _resolveImageUrl() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Check if the image source is already a direct URL
      if (ImageUrlResolver.isDirectDownloadUrl(widget.imageSource)) {
        smPrint('Using direct URL: ${widget.imageSource}');
        setState(() {
          _resolvedUrl = widget.imageSource;
          _isLoading = false;
        });
        return;
      }

      // Extract file name and resolve URL
      final fileName = ImageUrlResolver.extractFileName(widget.imageSource);
      smPrint('Resolving URL for file: $fileName');

      final resolvedUrl = await ImageUrlResolver.resolveImageUrl(
        fileName: fileName,
        sessionId: widget.sessionId,
        category: widget.category,
      );

      if (mounted) {
        setState(() {
          _resolvedUrl = resolvedUrl;
          _isLoading = false;
          _hasError = resolvedUrl == null;
        });
      }
    } catch (e) {
      smPrint('Error resolving image URL: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (_hasError || _resolvedUrl == null) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: DesignSystem.internetImage(
        imageUrl: _resolvedUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 20.rSp,
          height: 20.rSp,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey[400],
          size: 24.rSp,
        ),
      ),
    );
  }
}
