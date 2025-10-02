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

  ///* Set SMSupportData and store SMSecret securely
  static Future<void> initSMSupportData({required SMSupportData data, required BuildContext appContext}) async {
    smPrint('initSMSupportData ---------------: ${data.locale.localeCode}');
    smPrint('🔐 SMSecret provided: ${data.smSecret.isNotEmpty ? "✅ Yes (${data.smSecret.length} chars)" : "❌ Empty"}');
    
    _smSupportData = data;
    parentContext = appContext;
    
    // Store SMSecret securely
    try {
      await SecureStorageHelper.setSMSecret(data.smSecret);
      smPrint('🔐 SMSecret stored successfully');
      
      // Verify storage by reading it back
      final storedSecret = await SecureStorageHelper.getSMSecret();
      smPrint('🔐 SMSecret verification: ${storedSecret != null && storedSecret.isNotEmpty ? "✅ Stored correctly" : "❌ Storage failed"}');
    } catch (e) {
      smPrint('🔐 Error storing SMSecret: $e');
    }
    
    smCubit.initializeData(data.locale.localeCode);
  }

  ///* Get SMSecret from secure storage
  static Future<String?> getSMSecret() async {
    return await SecureStorageHelper.getSMSecret();
  }

  ///* Check if SMSecret exists
  static Future<bool> hasSMSecret() async {
    return await SecureStorageHelper.hasSMSecret();
  }

  ///* Clear SMSecret (useful for logout or reset)
  static Future<void> clearSMSecret() async {
    await SecureStorageHelper.clearSMSecret();
  }
}
