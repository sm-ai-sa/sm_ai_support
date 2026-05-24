import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

/// Manages the Android foreground service that keeps a WebRTC voice call
/// alive when the screen is off or the app is backgrounded.
///
/// On iOS, the equivalent behavior comes from the `audio` + `voip` background
/// modes declared in Info.plist — no runtime work is required, so this class
/// is a no-op on iOS.
class CallForegroundService {
  CallForegroundService._();

  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized || !Platform.isAndroid) return;
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'sm_ai_support_call',
        channelName: 'Voice call',
        channelDescription: 'Keeps the voice call alive while the screen is off.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
    _initialized = true;
  }

  static Future<bool> _ensureNotificationPermission() async {
    try {
      final status = await FlutterForegroundTask.checkNotificationPermission();
      if (status == NotificationPermission.granted) return true;
      final result = await FlutterForegroundTask.requestNotificationPermission();
      return result == NotificationPermission.granted;
    } catch (e) {
      smLog('CallForegroundService: notification permission check failed: $e');
      return false;
    }
  }

  /// Start the foreground service. Call when a call enters connecting/active.
  static Future<void> start({
    String title = 'Voice call in progress',
    String body = 'Tap to return to the call.',
  }) async {
    if (!Platform.isAndroid) return;
    _ensureInitialized();

    final granted = await _ensureNotificationPermission();
    if (!granted) {
      smLog('CallForegroundService: notification permission denied — FGS may not stay alive');
    }

    try {
      final ServiceRequestResult result;
      if (await FlutterForegroundTask.isRunningService) {
        result = await FlutterForegroundTask.restartService();
      } else {
        result = await FlutterForegroundTask.startService(
          serviceId: 1001,
          notificationTitle: title,
          notificationText: body,
        );
      }
      if (result is ServiceRequestSuccess) {
        smLog('CallForegroundService: started');
      } else if (result is ServiceRequestFailure) {
        smLog('CallForegroundService: start failed: ${result.error}');
      }
    } catch (e) {
      smLog('CallForegroundService: start threw: $e');
    }
  }

  /// Stop the foreground service. Call when the call ends.
  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      if (!await FlutterForegroundTask.isRunningService) return;
      final result = await FlutterForegroundTask.stopService();
      if (result is ServiceRequestSuccess) {
        smLog('CallForegroundService: stopped');
      } else if (result is ServiceRequestFailure) {
        smLog('CallForegroundService: stop failed: ${result.error}');
      }
    } catch (e) {
      smLog('CallForegroundService: stop threw: $e');
    }
  }
}
