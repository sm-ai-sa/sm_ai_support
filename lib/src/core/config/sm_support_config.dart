import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/security/hmac_signature_helper.dart';
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
    smPrint('🔐 API Key provided: ${data.apiKey.isNotEmpty ? "✅ Yes (${data.apiKey.length} chars)" : "❌ Empty"}');
    
    _smSupportData = data;
    parentContext = appContext;
    
    // Store API Key securely
    try {
      await SecureStorageHelper.setAPIKey(data.apiKey);
      smPrint('🔐 API Key stored successfully');
      
      // Verify storage by reading it back
      final storedApiKey = await SecureStorageHelper.getAPIKey();
      smPrint('🔐 API Key verification: ${storedApiKey != null && storedApiKey.isNotEmpty ? "✅ Stored correctly" : "❌ Storage failed"}');
    } catch (e) {
      smPrint('🔐 Error storing API Key: $e');
    }

    // Store secret key securely (required)
    if (data.secretKey.isNotEmpty) {
      try {
        await HmacSignatureHelper.setSecretKey(data.secretKey);
        smPrint('🔐 Secret Key stored successfully');
        
        // Verify storage by reading it back
        final storedSecretKey = await HmacSignatureHelper.getSecretKey();
        smPrint('🔐 Secret Key verification: ${storedSecretKey != null && storedSecretKey.isNotEmpty ? "✅ Stored correctly" : "❌ Storage failed"}');
      } catch (e) {
        smPrint('🔐 Error storing Secret Key: $e');
      }
    } else {
      smPrint('🔐 Warning: Empty Secret Key provided, HMAC signature may not work properly');
    }
    
    smCubit.initializeData(data.locale.localeCode);
  }

  ///* Get API Key from secure storage
  static Future<String?> getAPIKey() async {
    return await SecureStorageHelper.getAPIKey();
  }

  ///* Check if API Key exists
  static Future<bool> hasAPIKey() async {
    return await SecureStorageHelper.hasAPIKey();
  }

  ///* Clear API Key (useful for logout or reset)
  static Future<void> clearAPIKey() async {
    await SecureStorageHelper.clearAPIKey();
  }

  ///* Get Secret Key from secure storage
  static Future<String?> getSecretKey() async {
    return await HmacSignatureHelper.getSecretKey();
  }

  ///* Check if Secret Key exists
  static Future<bool> hasSecretKey() async {
    return await HmacSignatureHelper.hasSecretKey();
  }

  ///* Clear Secret Key (useful for logout or reset)
  static Future<void> clearSecretKey() async {
    await HmacSignatureHelper.clearSecretKey();
  }

  ///* Clear all secure data (API Key and Secret Key)
  static Future<void> clearAllSecureData() async {
    await clearAPIKey();
    await clearSecretKey();
    smPrint('🔐 All secure data cleared');
  }

  /// Logout from the package and return to anonymous mode
  ///
  /// This method:
  /// 1. Clears authentication data (token, customer info) but preserves device_id
  /// 2. Clears anonymous session mappings (user will start fresh sessions)
  /// 3. Reconnects WebSocket with anonymous headers
  ///
  /// Call this from the parent app when the user logs out to ensure
  /// the support package returns to anonymous mode properly.
  ///
  /// Example:
  /// ```dart
  /// // In your app's logout flow:
  /// await SMConfig.logout();
  /// ```
  static Future<void> logout() async {
    smPrint('🚪 SMConfig.logout() - Starting logout process...');

    // Ensure SharedPreferences is initialized
    await SharedPrefHelper.init();

    // 1. Clear authentication data (preserves device_id)
    await AuthManager.logout();
    smPrint('🚪 Auth data cleared');

    // 2. Clear anonymous session mappings (fresh start for anonymous mode)
    await SharedPrefHelper.clearAnonymousSessionCategoryMap();
    smPrint('🚪 Anonymous session mappings cleared');

    // 3. Reconnect WebSocket with anonymous headers
    await WebSocketService.instance.reconnectWithNewAuth();
    smPrint('🚪 WebSocket reconnected as anonymous');

    smPrint('🚪 SMConfig.logout() - Logout completed successfully');
  }
}
