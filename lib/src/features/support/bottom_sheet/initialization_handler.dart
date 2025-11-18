// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/config/sm_support_config.dart';
import 'package:sm_ai_support/src/core/di/injection_container.dart';
import 'package:sm_ai_support/src/core/global/components/country_codes.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_cubit.dart';

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

    // Perform auto-login if customer data is provided
    if (smSupportData.customer != null && !AuthManager.isAuthenticated) {
      await _performAutoLogin(smSupportData.customer!);
    }
  }

  /// Perform auto-login with customer data
  static Future<void> _performAutoLogin(CustomerData customer) async {
    try {
      await sl<AuthCubit>().autoLogin(customer: customer);
    } catch (e) {
      // Log error but don't block initialization
      smPrint('Auto-login failed: $e');
    }
  }
}
