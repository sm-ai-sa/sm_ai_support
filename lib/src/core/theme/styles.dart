import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/constant/path.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

class TextStyles {
  //* Singleton __________________________________
  TextStyles._();
  static TextStyles? _instance;
  static final _lock = Completer<void>();

  static TextStyles get instance {
    if (_instance == null) {
      if (!_lock.isCompleted) _lock.complete();
      _instance = TextStyles._();
    }
    return _instance!;
  }
  //* _____________________________________________

  static TextStyle get s_57_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 57.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_57_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 57.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_57_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 57.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_57_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 57.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_57_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 57.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_45_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 45.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_45_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 45.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_45_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 45.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_45_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 45.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_45_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 45.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_38_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 38.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_38_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 38.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_38_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 38.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_38_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 38.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_36_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 36.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_36_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 36.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_36_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 36.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_36_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 36.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_36_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 36.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_32_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 32.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_32_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 32.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_32_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 32.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_32_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 32.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_32_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 32.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_30_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 30.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_30_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 30.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_30_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 30.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_30_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 30.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_30_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 30.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_28_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 28.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_28_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 28.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_28_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 28.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_28_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 28.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_28_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 28.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_26_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 26.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_26_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 26.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_26_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 26.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_26_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 26.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_26_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 26.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_24_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 24.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_24_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 24.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_24_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 24.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_24_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 24.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_24_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 24.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************
  static TextStyle get s_23_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 23.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_23_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 23.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_23_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 23.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_23_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 23.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_23_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 23.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_22_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 22.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_22_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 22.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_22_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 22.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_22_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 22.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_22_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 22.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_20_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 20.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_20_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 20.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_20_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 20.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_20_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 20.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_20_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 20.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_19_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 19.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_19_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 19.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_19_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 19.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_19_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 19.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_19_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 19.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************
  static TextStyle get s_18_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 18.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_18_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 18.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_18_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 18.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_18_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 18.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_18_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 18.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_17_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 17.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_17_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 17.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_17_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 17.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_17_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 17.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_17_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 17.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_16_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 16.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_16_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 16.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_16_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 16.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_16_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 16.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_16_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 16.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************
  static TextStyle get s_15_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 15.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_15_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 15.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_15_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 15.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_15_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 15.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_15_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 15.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_14_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 14.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_14_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 14.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_14_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 14.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_14_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 14.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_14_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 14.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_13_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 13.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_13_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 13.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_13_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 13.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_13_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 13.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_13_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 13.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_12_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 12.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_12_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 12.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_12_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 12.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_12_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 12.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_12_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 12.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_11_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 11.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_11_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 11.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_11_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 11.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_11_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 11.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_11_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 11.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_10_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 10.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_10_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 10.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_10_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 10.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_10_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 10.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_10_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 10.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_9_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 9.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_9_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 9.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );
  static TextStyle get s_9_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 9.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_9_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 9.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_9_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 9.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );

  ///************************************

  static TextStyle get s_8_400 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 8.rSp,
        fontWeight: FontWeight.w400,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_8_500 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 8.rSp,
        fontWeight: FontWeight.w500,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_8_600 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 8.rSp,
        fontWeight: FontWeight.w600,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_8_700 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 8.rSp,
        fontWeight: FontWeight.w700,
        fontFamily: SMSupportTheme.fontFamily,
      );

  static TextStyle get s_8_800 => TextStyle(
        package: SMAssetsPath.packageName,
        color: ColorsPallets.loud900,
        fontSize: 8.rSp,
        fontWeight: FontWeight.w800,
        fontFamily: SMSupportTheme.fontFamily,
      );
}
