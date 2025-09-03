import 'package:flutter/material.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';

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
  void smPop() => Navigator.of(this).pop();

  ///* Back to the parent view tree
  void smParentPop() {
    if (mounted) {
      Navigator.of(this).pop();
    }
  }

  ///* Go to next view
  void smPush(Widget widget) => Navigator.of(this).push(MaterialPageRoute(builder: (_) => widget));

  ///* Go to next view and remove current view from tree
  void smPushReplacement(Widget widget) => Navigator.pushReplacement(this, MaterialPageRoute(builder: (_) => widget));
}
