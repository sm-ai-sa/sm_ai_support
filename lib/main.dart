import 'package:flutter/material.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/features/support/bottom_sheet/bottom_sheet_wrapper.dart';
import 'package:sm_ai_support/src/features/support/bottom_sheet/initialization_handler.dart';

/// Main SM Support class - Bottom Sheet Mode (Recommended)
///
/// This is the recommended way to integrate SM Support into your app.
/// It opens as a bottom sheet (94% screen height) within your app's context.
///
/// For legacy full-screen mode, use SMSupportLegacy from:
/// 'package:sm_ai_support/src/support/legacy/sm_support_legacy.dart'

final smNavigatorKey = GlobalKey<NavigatorState>();

class SMSupport extends StatefulWidget {
  ///* Provide the context of the app
  final BuildContext parentContext;

  ///* SM Support Data to be used in the SM Support
  final SMSupportData smSupportData;

  const SMSupport({
    super.key,
    required this.parentContext,
    required this.smSupportData,
  });

  /// Show SM Support as a bottom sheet within the parent app's context
  ///
  /// This method allows opening the support interface without creating a new MaterialApp.
  /// The bottom sheet is dismissible by tapping outside or dragging down.
  ///
  /// Example:
  /// ```dart
  /// await SMSupport.show(
  ///   context: context,
  ///   smSupportData: SMSupportData(
  ///     appName: 'Your App',
  ///     locale: SMSupportLocale.en,
  ///     tenantId: '1',
  ///     apiKey: 'your-api-key',
  ///     secretKey: 'your-secret-key',
  ///     baseUrl: 'https://api.example.com',
  ///     socketBaseUrl: 'wss://socket.example.com',
  ///   ),
  /// );
  /// ```
  static Future<void> show({
    required BuildContext context,
    required SMSupportData smSupportData,
  }) async {
    // Initialize all services before showing UI
    await InitializationHandler.initialize(
      context: context,
      smSupportData: smSupportData,
    );

    // Show the bottom sheet - remaining initialization happens inside
    if (context.mounted) {
      await BottomSheetWrapper.show(
        context: context,
        smSupportData: smSupportData,
      );
    }
  }

  @override
  State<SMSupport> createState() => _SMSupportState();
}

class _SMSupportState extends State<SMSupport> {
  @override
  Widget build(BuildContext context) {
    // This widget is kept for backward compatibility
    // Most apps should use SMSupport.show() instead of pushing this widget
    return const SizedBox.shrink();
  }
}
