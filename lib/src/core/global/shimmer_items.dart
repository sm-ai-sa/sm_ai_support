import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class ShimmerItems {
  //* Singleton __________________________________
  ShimmerItems._();
  static ShimmerItems? _instance;
  static final _lock = Completer<void>();

  static ShimmerItems get instance {
    if (_instance == null) {
      if (!_lock.isCompleted) _lock.complete();
      _instance = ShimmerItems._();
    }
    return _instance!;
  }

  static Shimmer shimmerContainer({
    double? width,
    double? height,
    double? radius,
    bool isCircle = false,
  }) {
    return Shimmer.fromColors(
      baseColor: ColorsPallets.shimmerColor,
      highlightColor: ColorsPallets.shimmerColor2,
      child: Container(
        height: height ?? 30,
        width: width ?? 150,
        decoration: BoxDecoration(
          borderRadius: !isCircle ? radius?.br ?? 10.br : null,
          color: Colors.white,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  static Widget ticketShimmer() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14.rh),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shimmerContainer(
                width: 24.rw,
                height: 24.rh,
              ),
              SizedBox(width: 14.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerContainer(
                      width: 100.rw,
                      height: 16.rh,
                    ),
                    SizedBox(height: 4.rh),
                    shimmerContainer(
                      width: 200.rw,
                      height: 20.rh,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.rw),
              shimmerContainer(
                width: 24.rw,
                height: 24.rh,
              ),
            ],
          ),
        ),
        Divider(
          color: ColorsPallets.disabled25,
          thickness: 1,
        ),
      ],
    );
  }

  /// Shimmer for category items - matches actual category structure
  static Widget categoryShimmer({bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.rh),
          child: Row(
            children: [
              // Icon shimmer
              shimmerContainer(
                width: 24.rw,
                height: 24.rh,
                radius: 8,
              ),
              SizedBox(width: 14.rw),
              // Text shimmer
              Expanded(
                child: shimmerContainer(
                  width: double.infinity,
                  height: 14.rh,
                  radius: 4,
                ),
              ),
              SizedBox(width: 14.rw),
              // Arrow shimmer
              shimmerContainer(
                width: 16.rw,
                height: 16.rh,
                radius: 4,
              ),
            ],
          ),
        ),
        // Divider (same as actual category)
        if (showDivider)
          Divider(color: ColorsPallets.disabled25, thickness: 1),
      ],
    );
  }

  /// Shimmer for logo
  static Widget logoShimmer() {
    return shimmerContainer(
      width: 48.rw,
      height: 48.rh,
      isCircle: true,
    );
  }
}
