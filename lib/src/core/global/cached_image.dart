import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/global/shimmer_items.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final int? memCacheWidth;
  final BoxFit? fit;
  final Widget Function(ImageProvider)? child;
  final bool isCircleShape;
  final BorderRadiusGeometry? borderRadius;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    required this.url,
    this.child,
    this.width,
    this.height,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.memCacheWidth,
    this.fit,
    this.isCircleShape = false,
    this.borderRadius,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache,
      placeholder: (_, __) => ShimmerItems.shimmerContainer(
        width: width,
        height: height,
        isCircle: isCircleShape,
        radius: 12,
        // radius: borderRadius.,
      ),
      errorWidget: (_, url, ___) {
        // printMeLog("Error while downloading this image: $url");
        return errorWidget ??
            DesignSystem.svgIcon(
              'warning_circle',
              height: height,
              width: width,
              fit: BoxFit.contain,
            );
      },
      imageBuilder: child != null ? (_, image) => child!.call(image) : null,
    );
  }
}
