import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/constant/locale.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/theme/colors.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_cubit.dart';
import 'package:sm_ai_support/src/features/support/cubit/sm_support_state.dart';

extension NumExt on num {
  ///* Vat amount 15% of total amount
  num get vat => (this * 0.15).formattedValue;

  ///* Return [BorderRadius] for widget
  BorderRadius get br => BorderRadius.circular(toDouble());

  ///* Return [Radius] for widget
  Radius get rBr => Radius.circular(toDouble());

  ///* Get value like `50.90999 to 50.90` or `50.00 to 50`
  num get formattedValue {
    if (this % 1 == 0) {
      return toInt();
    } else {
      return double.parse(toStringAsFixed(2));
    }
  }

  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get milliseconds => Duration(milliseconds: toInt());

  ///* Format to String
  String get formattedString => formattedValue.toString();

  //* Is success
  bool get isSuccess => this == 200 || this == 201;

  ///* Convert to halala
  int get amountInHalala => (this * 100).formattedValue.toInt();

  ///* Convert to amount
  num get halalaToAmount => (this / 100).formattedValue;
  Widget get vs => SizedBox(height: rSp);
  Widget get hs => SizedBox(width: rSp);
}

extension IntExt on int {
  bool get isSuccess => this == 200 || this == 201 || this == 204;
}

extension StringExt on String {
  String get firstName {
    final name = split(" ");
    return name.first;
  }

  String get lastName {
    final name = split(" ");
    String lastName = "";
    if (name.length > 1) {
      name.removeAt(0);
      lastName = name.join(" ");
    }
    return lastName;
  }

  /// To Num
  num get toNum => num.tryParse(this) ?? 0;
}

extension BuildContextExt on BuildContext {
  ///* Go previous view
  void smPop() => Navigator.of(SMConfig.parentContext).pop();
  void smPopSheet({bool? isSuccess}) => smNavigatorKey.currentState?.pop(isSuccess);

  ///* Back to the parent view tree
  void smParentPop() {
    if (mounted) {
      Navigator.of(SMConfig.parentContext).pop();
    }
  }

  ///* Go to next view (within bottom sheet navigator)
  void smPush(Widget widget) => Navigator.of(SMConfig.parentContext).push(MaterialPageRoute(builder: (_) => widget));

  ///* Push a full-screen page using the parent app's context
  /// This is useful for chat pages and other screens that need full screen
  void smPushFullScreen(Widget widget) {
    if (!mounted) return;

    // Use the parent context to push a full-screen route
    Navigator.of(SMConfig.parentContext).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenWrapper(child: widget),
      ),
    );
  }

  ///* Go to next view and remove current view from tree
  void smPushReplacement(Widget widget) =>
      Navigator.pushReplacement(SMConfig.parentContext, MaterialPageRoute(builder: (_) => widget));
}

/// Wrapper widget for full-screen routes that provides necessary context
class _FullScreenWrapper extends StatelessWidget {
  final Widget child;

  const _FullScreenWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    // Get text direction and locale from config
    final textDirection = SMConfig.smData.locale.isEnglish ? TextDirection.ltr : TextDirection.rtl;
    final locale = SMConfig.smData.locale.currentLocale;

    return BlocProvider.value(
      value: smCubit,
      child: BlocListener<SMSupportCubit, SMSupportState>(
        listener: (context, state) {
          // Update primary color when tenant data is loaded
          if (state.currentTenant != null) {
            ColorsPallets.primaryColor = state.currentTenant?.primaryColor ?? ColorsPallets.primaryColor;
          }
        },
        child: Directionality(
          textDirection: textDirection,
          child: Localizations(
            locale: locale,
            delegates: LocalizationsData.localizationsDelegate,
            child: child,
          ),
        ),
      ),
    );
  }
}
