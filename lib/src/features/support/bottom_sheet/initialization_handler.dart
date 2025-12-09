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

    // Debug logging
    smPrint('=== Authentication State ===');
    smPrint('Customer data provided: ${smSupportData.customer != null}');
    smPrint('Current auth status: ${AuthManager.isAuthenticated}');
    smPrint('Has valid auth data: ${AuthManager.hasValidAuthData}');
    smPrint('Auth token: ${AuthManager.authToken != null ? "Present" : "Null"}');
    smPrint('Customer ID: ${AuthManager.currentCustomer?.id ?? "Null"}');
    smPrint('==========================');

    // Handle authentication based on customer data
    if (smSupportData.customer != null) {
      // Customer data provided - perform auto-login if not already authenticated
      if (!AuthManager.isAuthenticated) {
        smPrint('🔐 Customer data provided, user not authenticated → Performing auto-login');
        await _performAutoLogin(smSupportData.customer!);

        // Debug: Check authentication state after auto-login
        smPrint('=== Post Auto-Login State ===');
        smPrint('Is Authenticated: ${AuthManager.isAuthenticated}');
        smPrint('Has Token: ${AuthManager.authToken != null}');
        smPrint('Customer ID: ${AuthManager.currentCustomer?.id ?? "Null"}');
        smPrint('============================');

        // Trigger UI update after auto-login by emitting a state change in SMSupportCubit
        // This ensures that widgets listening to authentication state will rebuild
        _refreshAuthenticationState();
      } else {
        smPrint('✅ Customer data provided, user already authenticated → Skipping auto-login');
      }
    } else {
      // No customer data provided - maintain current authentication state
      // If already logged in, keep them logged in
      // If anonymous, keep them anonymous
      if (AuthManager.isAuthenticated) {
        smPrint('✅ No customer data provided, user is authenticated → Maintaining logged-in state');
      } else {
        smPrint('👤 No customer data provided, user not authenticated → Maintaining anonymous state');
      }
    }
  }

  /// Refresh authentication state in SMSupportCubit
  /// This triggers a UI rebuild for widgets listening to authentication state
  static void _refreshAuthenticationState() {
    try {
      final smSupportCubit = sl<SMSupportCubit>();
      // Trigger state update to notify listeners about authentication changes
      smSupportCubit.refreshAuthState();
      smPrint('✅ SMSupportCubit state refreshed after auto-login');
    } catch (e) {
      smPrint('⚠️ Error refreshing SMSupportCubit state: $e');
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
