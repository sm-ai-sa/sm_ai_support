import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class SMConfig {
  SMConfig._();

  static late BuildContext parentContext;

  /// Here the Support related data will be stored
  static SMSupportData? _smSupportData;



  ///* SM Support Data to be used for Support request
  static SMSupportData get smData {
    if (_smSupportData == null) {
      throw Exception("SMSupport has not been initialized yet! ;)");
    }
    return _smSupportData!;
  }

  ///* Set SMSupportData
  static Future<void> initSMSupportData({required SMSupportData data, required BuildContext appContext}) async {
    smPrint('initSMSupportData ---------------: ${data.locale.localeCode}');
    _smSupportData = data;
    parentContext = appContext;
    smCubit.initializeData(data.locale.localeCode);
  }
}
