import 'package:flutter/material.dart';

class ColorsPallets {
  static Color primaryColor = Colors.black;
  static Color primary0 = const Color(0xFFF1F3FE);
  static Color primary25 = const Color(0xFFE3E6FD);
  static Color primary300 = const Color(0xFF0B1A7F);
  static const Color black = Colors.black;
  static Color transparent = Colors.transparent;
  static Color white = Colors.white;
  static Color greyTextColor = const Color(0xFF808080);
  static const Color pressed100 = Color(0xFFE4E3E2);
  static const Color yellow0 = Color(0xFFFFF5E1);
  static const Color yellow300 = Color(0xFF795101);
  static const Color yellow25 = Color(0xFFFEECC7);
  static const Color green0 = Color(0xFFF2FBF9);
  static const Color green300 = Color(0xFF174F41);
  static const Color green25 = Color(0xFFDBF5EE);

  static const Color red0 = Color(0xFFFEF1F1);
  static const Color red25 = Color(0xFFFDD8D8);
  static const Color red300 = Color(0xFF780707);

  static WidgetStatePropertyAll<Color> transparentMaterialColor = WidgetStatePropertyAll<Color>(
    ColorsPallets.transparent,
  );
  static const Color neutralSolid300 = Color(0xFFB3AFAA);
  static const Color secondaryRed0 = Color(0xFFFEF1F1);
  static const Color secondaryRed25 = Color(0xFFFBDADA);
  static Color fillColor = const Color(0xFFF5F5F5);
  static const Color loud900 = Color(0xFF0F0F10);
  static const Color normal500 = Color(0xFF6C6C7A);
  static const Color subdued400 = Color(0xFF858593);
  static const Color normal25 = Color(0xFFF8F8F8);
  static const Color disabled0 = Color(0xFFFAFAFA);
  static const Color disabled25 = Color(0xFFF8F8F8);
  static const Color disabled300 = Color(0xFFAAAAB3);
  static const Color secondaryGreen100 = Color(0xFF10BC97);
  static const Color muted600 = Color(0xFF3C3C44);
  static const Color borderColor = Color(0xFFF4F4F5);
  static const Color shimmerColor = Color(0xFFFEFEFF);
  static const Color shimmerColor2 = Color(0xFFBDBDBD);
  static const Color secondaryRed100 = Color(0xFFEF5D70);
  static const Color neutral900 = Color(0xFF101828);
  static const Color warning500 = Color(0xFFF79009);
  static const Color neutral100 = Color(0xFFF2F4F7);
  static const Color solid200 = Color(0xFFC5C5CC);
  static const Color solid600 = Color(0xFF3C3C44);
  static const Color hover50 = Color(0xFFEFEFF0);
  static const Color neutralSolid100 = Color(0xFFE1E1E5);
  static const Color darkGreen = Color(0xFF484D46);
}

class SMSupportTheme {
  SMSupportTheme._();
  static const String fontFamily = 'HacenMaghreb';
  static const String sansFamily = 'DMSans';

  static ThemeData theme = ThemeData(
    fontFamily: fontFamily,
    scaffoldBackgroundColor: Colors.white,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(overlayColor: WidgetStateProperty.all<Color>(Colors.transparent)),
    ),
    appBarTheme: AppBarTheme(elevation: 0, backgroundColor: ColorsPallets.white),
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
  );
}
