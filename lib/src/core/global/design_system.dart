import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gif/gif.dart';
import 'package:lottie/lottie.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/constant/path.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/global/cached_image.dart';
import 'package:sm_ai_support/src/core/global/shimmer_items.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/theme/styles.dart';
import 'package:sm_ai_support/src/core/utils/extension.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class DesignSystem {
  static Widget closeButton({Function()? onTap, bool isWithCircle = false, Color? iconColor, double? size}) {
    return InkWell(
      onTap:
          onTap ??
          () {
            smNavigatorKey.currentContext!.smParentPop();
          },
      child: Container(
        padding: isWithCircle ? EdgeInsets.all(10.rSp) : EdgeInsets.zero,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isWithCircle ? ColorsPallets.black.withOpacity(.35) : null,
        ),
        child: DesignSystem.svgIcon(
          'close',
          color: isWithCircle ? ColorsPallets.white : (iconColor ?? ColorsPallets.normal500),
          size: size ?? 24.rSp,
        ),
      ),
    );
  }

  static Widget arrowLeftOrRight({Color? color}) {
    return Transform.rotate(
      angle: SMConfig.smData.locale.isArabic ? 0 : pi,
      child: DesignSystem.svgIcon('arrow-left', color: color),
    );
  }

  static Widget backButton({Function()? onBackPressed, Color? color, double? size}) {
    return InkWell(
      onTap:
          onBackPressed ??
          () {
            smNavigatorKey.currentContext!.smParentPop();
          },
      child: DesignSystem.svgIcon(
        'arrow-right-white',
        size: size ?? 22.rSp,
        isDirectional: true,
        isFliped: true,
        color: color ?? ColorsPallets.loud900,
      ),
    );
  }

  static Widget primaryDivider() {
    return Divider(color: ColorsPallets.disabled25, thickness: 1, height: 1);
  }

  static Widget svgIcon(
    String iconName, {
    bool isExternalSvg = false,
    Function()? onTap,
    bool isDirectional = false,
    double? width,
    double? height,
    double? size,
    Color? color,
    BoxFit? fit,
    bool isFliped = false,
    double borderRadius = 0,
    String? path, // Custom path for icon subdirectories
  }) {
    return InkWell(
      onTap: onTap,
      child: Transform.flip(
        flipX: isFliped,
        child: Container(
          width: size ?? (width ?? 24.rSp),
          height: size ?? (height ?? 24.rSp),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: borderRadius.br),
          child: SvgPicture.asset(
            path != null ? '$path$iconName.svg' : '${SMAssetsPath.icons}/$iconName.svg',
            matchTextDirection: isDirectional,
            package: isExternalSvg ? null : SMAssetsPath.packageName,
            colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
            fit: fit ?? BoxFit.cover,
          ),
        ),
      ),
    );
  }

  static Widget networkSvgIcon(
    String iconName, {
    bool isExternalSvg = false,
    Function()? onTap,
    bool isDirectional = false,
    double? width,
    double? height,
    double? size,
    Color? color,
    BoxFit? fit,
    bool isFliped = false,
    double borderRadius = 0,
  }) {
    return InkWell(
      onTap: onTap,
      child: Transform.flip(
        flipX: isFliped,
        child: Container(
          width: size ?? (width ?? 24.rSp),
          height: size ?? (height ?? 24.rSp),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: borderRadius.br),
          child: SvgPicture.network(
            iconName,
            matchTextDirection: isDirectional,
            colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
            fit: fit ?? BoxFit.cover,
            placeholderBuilder: (_) => ShimmerItems.shimmerContainer(width: width, height: height, radius: 6),
            errorBuilder: (_, __, ___) => svgIcon('category/warning'),
          ),
        ),
      ),
    );
  }

  static Widget categorySvg(
    String icon, {
    double? width,
    double? height,
    double? size,
    Color? color,
    BoxFit? fit,
    bool isFliped = false,
    double borderRadius = 0,
  }) {
    return networkSvgIcon(
      icon,
      width: width,
      height: height,
      size: size,
      color: color ?? ColorsPallets.normal500,
      fit: fit,
      isFliped: isFliped,
      borderRadius: borderRadius,
    );
  }

  static Widget networkSvg(
    String url, {
    Function()? onTap,
    bool isDirectional = false,
    double? width,
    double? height,
    double? size,
    Color? color,
    BoxFit? fit,
    bool isFliped = false,
    double borderRadius = 0,
  }) {
    return InkWell(
      onTap: onTap,
      child: Transform.flip(
        flipX: isFliped,
        child: Container(
          width: size ?? (width ?? 24.rSp),
          height: size ?? (height ?? 24.rSp),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: borderRadius.br),
          child: SvgPicture.network(
            url,
            matchTextDirection: isDirectional,
            colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
            fit: fit ?? BoxFit.cover,
            placeholderBuilder: (_) => ShimmerItems.shimmerContainer(width: width, height: height, radius: 6),
          ),
        ),
      ),
    );
  }

  ///* Loading Indicator
  static Widget loadingIndicator({Color? color}) =>
      Center(child: CupertinoActivityIndicator(color: color ?? Colors.black));

  ///* Error View
  static Widget errorView({String? title, dynamic subTitle}) => Container(
    padding: const EdgeInsets.all(30),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title ?? SMText.somethingWentWrong, style: TextStyles.s_14_500, textAlign: TextAlign.center),
        if (subTitle != null) ...[
          10.vs,
          Text(
            subTitle.toString(),
            textAlign: TextAlign.center,
            style: TextStyles.s_14_500.copyWith(color: ColorsPallets.greyTextColor),
          ),
        ],
      ],
    ),
  );

  ///* Radio button checkbox
  static Widget checkBox({required bool status, ValueChanged<bool>? onChange, required Color activeColor}) =>
      Transform.scale(
        scale: 1.5,
        child: Checkbox(
          activeColor: activeColor,
          value: status,
          shape: const CircleBorder(),
          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
          onChanged: (v) => onChange?.call(v ?? false),
          overlayColor: ColorsPallets.transparentMaterialColor,
        ),
      );

  ///* Primary button
  static Widget primaryButton({
    required String title,
    VoidCallback? onPressed,
    bool showLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    double marginBottom = 0,
    bool isBottomBarButton = false,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    bool isButtonDisabled = (isDisabled || showLoading);
    return InkWell(
      onTap: isButtonDisabled ? null : onPressed,
      child: Container(
        width: width ?? 100.w,
        height: height ?? 50.rSp,
        margin: EdgeInsets.only(bottom: isBottomBarButton ? 25.rh : marginBottom),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isButtonDisabled ? ColorsPallets.fillColor : (backgroundColor ?? ColorsPallets.primaryColor),
          borderRadius: (borderRadius ?? 14).br,
        ),
        child: Visibility(
          visible: showLoading,
          replacement: Text(
            title,
            style: TextStyles.s_14_500.copyWith(
              color: isButtonDisabled ? ColorsPallets.greyTextColor : ColorsPallets.white,
            ),
          ),
          child: DesignSystem.loadingIndicator(),
        ),
      ),
    );
  }

  static blurEffect({required Widget child}) {
    return Material(
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      // shape: const CircleBorder(),
      color: ColorsPallets.transparent,
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7), child: child),
    );
  }

  static Widget pngIcon(
    String iconName, {
    Function()? onTap,
    bool isDirectional = false,
    double? size,
    double? height,
    double? width,
    Color? color,
    BoxFit? fit,
    bool isRotated = false,
    double borderRadius = 0,
    bool isExternalSvg = false,
  }) => InkWell(
    onTap: onTap,
    child: Transform.rotate(
      angle: isRotated ? pi : 0,
      child: Container(
        height: height ?? size ?? 24.rSp,
        width: width ?? size ?? 24.rSp,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: borderRadius.br),
        child: Image.asset(
          '${SMAssetsPath.icons}/$iconName.png',
          matchTextDirection: isDirectional,
          package: isExternalSvg ? null : SMAssetsPath.packageName,
          color: color,
          fit: fit ?? BoxFit.cover,
        ),
      ),
    ),
  );

  static Widget internetImage({
    Widget? child,
    Function()? onTap,
    required String? imageUrl,
    double? size,
    double? height,
    double? width,
    BoxFit? fit,
    Widget? errorWidget,
    bool isCircleShape = false,
    BorderRadiusGeometry? borderRadius,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
  }) {
    Widget content;

    if (imageUrl == null) {
      content = Container(
        height: height ?? size,
        width: width ?? size,
        decoration: BoxDecoration(
          shape: isCircleShape ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
        ),
        child: DesignSystem.svgIcon('warning_circle', height: height, width: width, fit: BoxFit.contain),
      );
    } else {
      content = CachedImage(
        url: imageUrl,
        height: height ?? size,
        width: width ?? size,
        isCircleShape: isCircleShape,
        borderRadius: borderRadius,
        child: (imageProvider) => Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: isCircleShape ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: borderRadius,
            image: DecorationImage(image: imageProvider, fit: fit ?? BoxFit.contain),
          ),
          child: child,
        ),
      );
    }

    return InkWell(onTap: onTap, child: content);
  }

  // static Widget starsRating({
  //   bool isOnlyShow = true,
  //   double? value,
  //   double? starSize,
  //   Color? starOffColor,
  //   Function(double)? onRateChanged,
  // }) {
  //   return RatingStars(
  //     value: value ?? 5,
  //     onValueChanged: (v) {
  //       if (onRateChanged != null) {
  //         onRateChanged(v);
  //       }
  //     },
  //     starBuilder: (index, color) => DesignSystem.svgIcon('star', size: 12.rSp, color: color),
  //     starCount: 5,
  //     starSize: starSize ?? 12.rSp,
  //     maxValue: 5,
  //     starSpacing: 8,
  //     maxValueVisibility: false,
  //     valueLabelVisibility: false,
  //     animationDuration: Duration(milliseconds: 100),
  //     valueLabelPadding: EdgeInsets.zero,
  //     valueLabelMargin: EdgeInsets.zero,
  //     starOffColor: starOffColor ?? ColorsPallets.warning500.withValues(alpha: .4),
  //     starColor: ColorsPallets.warning500,
  //     valueLabelTextStyle: TextStyles.s_12_400.copyWith(color: ColorsPallets.warning500),
  //     valueLabelColor: ColorsPallets.warning500,
  //     valueLabelRadius: 0,
  //    axis: Axis.horizontal,
  //   );
  // }

  static Widget starsRating({
    bool isOnlyShow = true,
    double? value,
    double? starSize,
    Color? starOffColor,
    Function(double)? onRateChanged,
  }) {
    return RatingBar.builder(
      initialRating: value ?? 5,
      onRatingUpdate: (v) {
        if (onRateChanged != null) {
          onRateChanged(v);
        }
      },
      itemBuilder: (c, index) => DesignSystem.svgIcon(
        'star',
        size: 12.rSp,
        color: index < (value ?? 5) ? ColorsPallets.warning500 : ColorsPallets.warning500.withValues(alpha: .4),
      ),
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 2.rw),
      itemSize: starSize ?? 12.rSp,
      maxRating: 5,
      glow: false,
      tapOnlyMode: true,
    );
  }

  static Widget avatarTitleSubtitle({String? pngAvatar, String? title, String? subTitle}) {
    return Column(
      children: [
        userAvatar(pngAvatar: pngAvatar),
        SizedBox(height: 16.rh),
        Text(title ?? SMText.loginNow, style: TextStyles.s_20_400),
        SizedBox(height: 4.rh),
        Text(
          subTitle ?? SMText.weWillSendYouAVerificationCodeInATextMessage,
          style: TextStyles.s_13_400.copyWith(color: ColorsPallets.subdued400),
        ),
      ],
    );
  }

  static Widget userAvatar({String? pngAvatar, double? size, Color? imageColor}) {
    return DesignSystem.pngIcon(pngAvatar ?? 'user-avatar', size: size ?? 64.rSp, color: imageColor);
  }

  ///* `Animated Cross Fade` Widget for switch child
  static Widget animatedCrossFadeWidget({
    required bool animationStatus,
    required Widget shownIfFalse,
    required Widget shownIfTrue,
    VoidCallback? onPressed,
    Duration? duration,
    Curve firstCurve = Curves.easeIn,
    Curve sizeCurve = Curves.easeInOut,
  }) {
    return InkWell(
      onTap: onPressed,
      child: AnimatedCrossFade(
        firstChild: shownIfFalse,
        secondChild: shownIfTrue,
        crossFadeState: animationStatus ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: duration ?? 100.milliseconds,
        alignment: Alignment.center,
        firstCurve: firstCurve,
        sizeCurve: sizeCurve,
      ),
    );
  }

  static Widget noAccCreateOne({String? title, String? richText, VoidCallback? onPressed}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title ?? SMText.noAccount,
            style: TextStyles.s_13_500.copyWith(color: ColorsPallets.subdued400),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: richText ?? SMText.createNewAccount,
            style: TextStyles.s_13_500.copyWith(color: ColorsPallets.primaryColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onPressed?.call();
              },
          ),
        ],
      ),
    );
  }

  static Widget thereIsAnAccount({String? title, String? richText, VoidCallback? onPressed}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title ?? SMText.thereIsAnAccount,
            style: TextStyles.s_13_500.copyWith(color: ColorsPallets.subdued400),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: richText ?? SMText.loginToYourAccount,
            style: TextStyles.s_13_500.copyWith(color: ColorsPallets.primaryColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onPressed?.call();
              },
          ),
        ],
      ),
    );
  }

  static Widget errorOTPButton({required Function() onClose}) {
    bool isHide = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Visibility(
          visible: !isHide,
          child: Container(
            decoration: BoxDecoration(
              color: ColorsPallets.secondaryRed0,
              borderRadius: 12.rSp.br,
              border: Border.all(color: ColorsPallets.secondaryRed25, width: 1.rSp),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 11.rh),
            child: Row(
              children: [
                DesignSystem.svgIcon('alert'),
                SizedBox(width: 8.rw),
                Expanded(
                  child: Text(
                    SMText.wrongVerificationCode,
                    style: TextStyles.s_12_400.copyWith(color: const Color.fromRGBO(238, 83, 83, 1)),
                  ),
                ),
                SizedBox(width: 8.rw),
                DesignSystem.svgIcon(
                  'close',
                  size: 16.rSp,
                  onTap: () {
                    setState(() {
                      isHide = true;
                    });
                    // authBloc.changeErrorOTPState(isError: false);
                    onClose();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static chatGif() {
    return Gif(
      height: 50.rh,
      width: 48.rw,
      image: AssetImage("${SMAssetsPath.gif}/chat.gif", package: SMAssetsPath.packageName),
      autostart: Autostart.loop,
      placeholder: (context) => const SizedBox(),
    );
  }

  static Widget lottieIcon({required String icon, double? height, double? width, double? size}) {
    return Lottie.asset(
      '${SMAssetsPath.lottie}/$icon.json',
      width: size ?? (width ?? 24.rSp),
      height: size ?? (height ?? 24.rSp),
      package: SMAssetsPath.packageName,
    );
  }
}

class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double sigmaVal;
  const GlassMorphism({super.key, required this.child, this.sigmaVal = 10});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaVal, sigmaY: sigmaVal),
        child: child,
      ),
    );
  }
}
