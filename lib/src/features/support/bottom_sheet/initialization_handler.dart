// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/components/country_codes.dart';

/// Handles all initialization tasks before showing the bottom sheet
class InitializationHandler {
  /// Initialize all required services and configurations
  static Future<void> initialize({
    required BuildContext context,
    required SMSupportData smSupportData,
  }) async {
    // Critical initialization BEFORE showing UI - must complete to avoid errors
    await initSL(); // Register all services including SMSupportCubit
    await SMConfig.initSMSupportData(
      appContext: context,
      data: smSupportData,
    );
    await AuthManager.init(); // Initialize SharedPreferences

    // Initialize device ID for anonymous user tracking
    // This must happen before any API calls to ensure device-id header is present
    await sl<DeviceIdManager>().initialize();

    // Set text language
    SMText.isEnglish = smSupportData.locale.isEnglish;

    // Initialize countries (can be async)
    initializeDefaultCountry();
    getCountries();
  }
}
